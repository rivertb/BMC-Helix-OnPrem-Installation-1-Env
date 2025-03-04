#!/bin/bash

#Source repo details containers.bmc.com
SOURCE_REGISTRY_HOST="containers.bmc.com"
SOURCE_REGISTRY_USER="peng_li@bmc.com"
SOURCE_REGISTRY_PASSWORD="a0a959a1-d0f2-40dc-aea9-62180c270c07"

#Target repo details
IMAGE_REGISTRY_HOST="helix-harbor.bmc.local"
IMAGE_REGISTRY_USERNAME="admin"
IMAGE_REGISTRY_PASSWORD="bmcAdm1n"
IMAGE_REGISTRY_PROJECT="bmc"
#IMAGE_REGISTRY_REPO=""
#if podman is used create a alias for docker
docker login ${SOURCE_REGISTRY_HOST}  -u ${SOURCE_REGISTRY_USER} -p ${SOURCE_REGISTRY_PASSWORD}
[[ $? -ne 0 ]] && echo "please check credential for SOURCE_REGISTRY_HOST ${SOURCE_REGISTRY_HOST}" && exit 0
docker login ${IMAGE_REGISTRY_HOST}  -u ${IMAGE_REGISTRY_USERNAME} -p ${IMAGE_REGISTRY_PASSWORD}
[[ $? -ne 0 ]] && echo "please check credential for IMAGE_REGISTRY_HOST ${IMAGE_REGISTRY_HOST}" && exit 0
#set -x

rm -f error.log pull_skiped.txt push_skiped.txt

i_BACKGROUND_PROCESS_MAX_COUNT=1

append_pid_into_list_of_background_processes()
{
        if [ -n "$str_BACKGROUND_PROCESS_PIDS" ]
        then
                str_BACKGROUND_PROCESS_PIDS=`UNIX95=  ps -p "$str_BACKGROUND_PROCESS_PIDS,$1" -o pid | tail -n +2 | tr '\n' ','`
                str_BACKGROUND_PROCESS_PIDS=`echo "$str_BACKGROUND_PROCESS_PIDS" |sed -e 's/,$//' -e 's/^,//' -e 's/ //g'`
                if [ $i_BACKGROUND_PROCESS_MAX_COUNT -ne 0 ]
                then
                        wait_for_find_processes_to_exit `expr $i_BACKGROUND_PROCESS_MAX_COUNT`
                fi
        else
                str_BACKGROUND_PROCESS_PIDS="$1"
        fi
}

wait_for_find_processes_to_exit ()
{
        if [ -z "$1" ]
        then
                i_PROC_COUNT=1
        else
                i_PROC_COUNT="$1"
        fi
        if [ -n "$str_BACKGROUND_PROCESS_PIDS" ]
        then
                while [ `UNIX95=  ps -p "$str_BACKGROUND_PROCESS_PIDS" | grep -v defunct | wc -l` -gt "$i_PROC_COUNT" ]
                do
                        echo "===========================================waiting on $str_BACKGROUND_PROCESS_PIDS"
                        sleep 3
                done
        fi
}

IFS=$'\n'
for EACH_LINE in $(cat images.txt)
do
        ./image_pull_push.sh  "$EACH_LINE" "${IMAGE_REGISTRY_HOST}" "${IMAGE_REGISTRY_PROJECT}" &
                append_pid_into_list_of_background_processes "$!"
        echo "===========================================IMAGE=$EACH_LINE---starting on pids $str_BACKGROUND_PROCESS_PIDS"

done
wait_for_find_processes_to_exit
echo "===========================================done"
docker logout ${SOURCE_REGISTRY_HOST}
docker logout ${IMAGE_REGISTRY_HOST}
