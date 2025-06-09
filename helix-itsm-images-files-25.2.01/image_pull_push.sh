#!/bin/bash
#set -x
EACH_LINE="$1"
TARGET_REGISTRY_HOST="$2"
TARGET_REGISTRY_PROJECT="$3"
CURRENT_IMAGE=$(echo "$EACH_LINE" | cut -d/ -f3)
REPO=$(echo "$CURRENT_IMAGE" | cut -d: -f1)
IMAGE_TAG=$(echo "$CURRENT_IMAGE" | cut -d: -f2)

echo "docker pull $EACH_LINE"
docker pull "$EACH_LINE" >/dev/null 2>>error.log
[[ $? -ne 0 ]] && echo "$EACH_LINE" >> pull_skiped.txt && exit 0
echo "docker tag $EACH_LINE ${TARGET_REGISTRY_HOST}/${TARGET_REGISTRY_PROJECT}/$REPO:$IMAGE_TAG"
docker tag "$EACH_LINE" "${TARGET_REGISTRY_HOST}/${TARGET_REGISTRY_PROJECT}/$REPO:$IMAGE_TAG"
echo "docker push ${TARGET_REGISTRY_HOST}/${TARGET_REGISTRY_PROJECT}/$REPO:$IMAGE_TAG"
docker push "${TARGET_REGISTRY_HOST}/${TARGET_REGISTRY_PROJECT}/$REPO:$IMAGE_TAG" >/dev/null 2>>error.log
[[ $? -ne 0 ]] && echo "${TARGET_REGISTRY_HOST}/${TARGET_REGISTRY_PROJECT}/$REPO:$IMAGE_TAG" >> push_skiped.txt
docker rmi "${TARGET_REGISTRY_HOST}/${TARGET_REGISTRY_PROJECT}/$REPO:$IMAGE_TAG" >/dev/null 2>>error.log
docker rmi "$EACH_LINE" >/dev/null 2>>error.log
