#!/bin/bash
MIN_ARGS=1

if [ "$#" -lt "$MIN_ARGS" ]; then
    echo "Error：1 parameter required!"
    exit 1
fi

echo "KM-Name: $1"

helm install single-solution-import single-solution-import-578.tgz --set namespace=helix,registryhost=srsvratv0004351.khanbank.local,imagePullSecrets.name=bmc-dtrhub,job.initContainers.containers.container1.registryhost=srsvratv0004351.khanbank.local,job.initContainers.containers.container1.org=bmc/lp0mz,job.container.org=bmc/lp0mz:,job.container.tag=6c6aa1bc-5,job.volumes[0].persistentVolumeClaim.claimName=poc-helix-nfs-pvc,job.volumes[0].name=repo-volume,job.container.envMap.env.TENANT_NAME=268240459,job.container.envMap.env.REPOSITORY_NAME="$1",job.initContainers.enabled=false,job.volumes[1].name=gcpcert1,job.volumes[1].secret.secretName=kafka-pem,job.volumes[2].name=gcpcert2,job.volumes[2].secret.secretName=kafka-pem,job.volumes[1].secret.optional=true,job.volumes[2].secret.optional=true,job.serviceAccount=helix-onprem-sa -n helix

