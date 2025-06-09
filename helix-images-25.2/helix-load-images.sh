#!/bin/bash

#Target repo details
IMAGE_REGISTRY_HOST="helix-harbor.bmc.local"
IMAGE_REGISTRY_PASSWORD="bmcAdm1n"
IMAGE_REGISTRY_USERNAME="admin"
IMAGE_REGISTRY_ORG="$1"
IMAGE_REGISTRY_PROJECT="bmc"
images="helix-images-$IMAGE_REGISTRY_ORG.tar.gz"

#if podman is used create a alias for docker
docker login ${IMAGE_REGISTRY_HOST}  -u ${IMAGE_REGISTRY_USERNAME} -p ${IMAGE_REGISTRY_PASSWORD}
[[ $? -ne 0 ]] && echo "please check credential for IMAGE_REGISTRY_HOST ${IMAGE_REGISTRY_HOST}" && exit 0
#set -x

rm -f ${IMAGE_REGISTRY_ORG}_error.log ${IMAGE_REGISTRY_ORG}_push_skiped.txt

echo "Preparing to start load images......"
docker load --input ${images}

#set -x
IFS=$'\n'
IMAGES_FILE="${IMAGE_REGISTRY_ORG}_images.txt"

echo "image file: $IMAGES_FILE"
if [ -f ${IMAGES_FILE} ]
then
  echo "Preparing to start pushing images......"
  for EACH_LINE in $(cat ${IMAGES_FILE})
  do
        echo "===========================================IMAGE=$EACH_LINE---starting on pids $str_BACKGROUND_PROCESS_PIDS"
        CURRENT_IMAGE=$(echo "$EACH_LINE" | cut -d/ -f3)
        ORG=$(echo "$CURRENT_IMAGE" | cut -d: -f1)
        IMAGE=$(echo "$CURRENT_IMAGE" | cut -d: -f2)
        echo "docker push $EACH_LINE"
  
        echo "docker tag $EACH_LINE ${IMAGE_REGISTRY_HOST}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG:$IMAGE"
        docker tag "$EACH_LINE" "${IMAGE_REGISTRY_HOST}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG:$IMAGE"
        echo "docker push ${IMAGE_REGISTRY_HOST}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG:$IMAGE"
        docker push "${IMAGE_REGISTRY_HOST}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG:$IMAGE" >/dev/null 2>>${IMAGE_REGISTRY_ORG}_error.log
        [[ $? -ne 0 ]] && echo "${IMAGE_REGISTRY_HOST}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG:$IMAGE" >> ${IMAGE_REGISTRY_ORG}_push_skiped.txt
#        docker rmi "${IMAGE_REGISTRY_HOST}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG:$IMAGE" >/dev/null 2>>${IMAGE_REGISTRY_ORG}_error.log
#        docker rmi "$EACH_LINE" >/dev/null 2>>${IMAGE_REGISTRY_ORG}_error.log
  done
else
 echo "File not found: ${IMAGES_FILE}"
 exit 1
fi

#set +x

docker logout ${IMAGE_REGISTRY_HOST}
