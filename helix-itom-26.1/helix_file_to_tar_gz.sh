#!/bin/bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <image_list_file>"
  exit 1
fi

IMAGELIST="$1"

# 目录名 = 输入文件名（去掉扩展名）
BASE_NAME="$(basename "${IMAGELIST}")"
BASE_DIR="${BASE_NAME%.*}"

mkdir -p "${BASE_DIR}"

TOTAL=$(grep -c . "${IMAGELIST}" || true)
COUNT=0

while read -r IMAGE; do
  [[ -z "${IMAGE}" ]] && continue

  COUNT=$((COUNT + 1))

  echo "================================================"
  echo "[${COUNT}/${TOTAL}] Processing image:"
  echo "  ${IMAGE}"
  echo "================================================"

  # 安全文件名
  SAFE_NAME=$(echo "${IMAGE}" | sed 's|/|_|g; s|:|_|g')
  TAR_PATH="${BASE_DIR}/${SAFE_NAME}.tar"
  TAR_GZ_PATH="${TAR_PATH}.gz"

  echo "[1/4] docker pull"
  docker pull "${IMAGE}"

  echo "[2/4] docker save -> ${TAR_PATH}"
  docker save "${IMAGE}" -o "${TAR_PATH}"

  echo "[3/4] compress -> ${TAR_GZ_PATH}"
  gzip -f "${TAR_PATH}"

  echo "[4/4] docker rmi"
  docker rmi "${IMAGE}"

  echo "[done]"
  echo

done < "${IMAGELIST}"

echo "All images in ${IMAGELIST} have been processed."

