#!/bin/bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <image_list_file> <harbor_project>"
  echo "Example: $0 all_images.txt harbor.local/bmc"
  exit 1
fi

IMAGELIST="$1"
HARBOR_PROJECT="$2"

BASE_NAME="$(basename "${IMAGELIST}")"
IMAGE_DIR="${BASE_NAME%.*}"

if [[ ! -d "${IMAGE_DIR}" ]]; then
  echo "Image directory not found: ${IMAGE_DIR}"
  exit 1
fi

TOTAL=$(grep -c . "${IMAGELIST}" || true)
COUNT=0

while read -r IMAGE; do
  [[ -z "${IMAGE}" ]] && continue
  COUNT=$((COUNT + 1))

  echo "================================================"
  echo "[${COUNT}/${TOTAL}] Processing image:"
  echo "  ${IMAGE}"
  echo "================================================"

  SAFE_NAME=$(echo "${IMAGE}" | sed 's|/|_|g; s|:|_|g')
  TAR_GZ="${IMAGE_DIR}/${SAFE_NAME}.tar.gz"

  if [[ ! -f "${TAR_GZ}" ]]; then
    echo "ERROR: archive not found: ${TAR_GZ}"
    exit 1
  fi

  echo "[1/5] docker load from ${TAR_GZ}"
  LOADED_IMAGES=$(docker load -i "${TAR_GZ}" | grep 'Loaded image:' | awk '{print $3}')

  for LOADED_IMAGE in ${LOADED_IMAGES}; do
    TARGET_IMAGE="${HARBOR_PROJECT}/${LOADED_IMAGE#bmchelix/}"
    #TARGET_IMAGE="${HARBOR_PROJECT}/${LOADED_IMAGE#containers.bmc.com/bmc/}"

    echo "[2/5] tag ${LOADED_IMAGE} -> ${TARGET_IMAGE}"
    docker tag "${LOADED_IMAGE}" "${TARGET_IMAGE}"

    echo "[3/5] push ${TARGET_IMAGE}"
    docker push "${TARGET_IMAGE}"

    echo "[4/5] cleanup local images"
    docker rmi "${LOADED_IMAGE}" "${TARGET_IMAGE}"
  done

  echo "[5/5] done"
  echo

done < "${IMAGELIST}"

echo "All images loaded and pushed to ${HARBOR_PROJECT} successfully."

