#!/bin/bash

#Source repo details containers.bmc.com
SOURCE_DOCKER_REPO="containers.bmc.com"
SOURCE_DOCKER_PASSWORD="xxxx-xxxx-xxxx-xxxx-xxxx"
SOURCE_DOCKER_USER="peng_li@bmc.com"

IMAGE_REGISTRY_ORG="$1"
IMAGE_REGISTRY_PROJECT="bmc"

images="helix-images-$IMAGE_REGISTRY_ORG.tar.gz"

#if podman is used create a alias for docker
docker login ${SOURCE_DOCKER_REPO}  -u ${SOURCE_DOCKER_USER} -p ${SOURCE_DOCKER_PASSWORD}
[[ $? -ne 0 ]] && echo "please check credential for SOURCE_DOCKER_REPO ${SOURCE_DOCKER_REPO}" && exit 0
#set -x

rm -f error.log pull_skiped.txt 

#set -x
IFS=$'\n'
IMAGES_FILE="${IMAGE_REGISTRY_ORG}_images.txt"
if [ -f ${IMAGES_FILE} ]
then
  echo "Preparing to start pulling images......"
  pulled=""
  for EACH_LINE in $(cat ${IMAGES_FILE})
  do
        echo "===========================================IMAGE=$EACH_LINE---starting on pids $str_BACKGROUND_PROCESS_PIDS"

        #######################################################################
        CURRENT_IMAGE=$(echo "$EACH_LINE" | cut -d/ -f3)
        ORG=$(echo "$CURRENT_IMAGE" | cut -d: -f1)
        IMAGE=$(echo "$CURRENT_IMAGE" | cut -d: -f2)
        echo "docker pull $EACH_LINE"
        docker pull "$EACH_LINE" >/dev/null 2>>${IMAGE_REGISTRY_ORG}_error.log
        [[ $? -ne 0 ]] && echo "$EACH_LINE" >> ${IMAGE_REGISTRY_ORG}_pull_skiped.txt && exit 0

        pulled="${pulled} ${SOURCE_DOCKER_REPO}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG:$IMAGE"
        #######################################################################
  done
else
 echo "File not found: ${IMAGES_FILE}"
 exit 1
fi

#set +x

echo "pulled: ---$pulled---"
echo "Creating ${images} with $(echo ${pulled} | wc -w | tr -d '[:space:]') images"
docker save $(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${SOURCE_DOCKER_REPO}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG) | gzip > $images
echo "docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${SOURCE_DOCKER_REPO}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG) > ${IMAGE_REGISTRY_ORG}_error.log"
docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${SOURCE_DOCKER_REPO}/${IMAGE_REGISTRY_PROJECT}/$IMAGE_REGISTRY_ORG) > ${IMAGE_REGISTRY_ORG}_error.log

echo "===========================================done"
docker logout ${SOURCE_DOCKER_REPO}
