#!/bin/bash

MIN_ARGS=3
if [ "$#" -lt "$MIN_ARGS" ]; then
    echo "Error：KM-Name, TenantID and NameSpace parameter required!"
    exit 1
fi

KM=$1
TenantID=$2
NS=$3

echo $KM

POD=`kubectl get pods -n $NS | grep deployment | awk '{print $1}' `

echo "KM:" $KM
echo "POD:" $POD

kubectl -n $NS cp $KM $POD:/opt/bmc/bmc-repo

echo "===========KM Copied to POD============="
kubectl -n $NS exec  $POD -- ls /opt/bmc/bmc-repo

echo "===========Check single-solution-import-job POD============="
kubectl get job -n $NS | grep single

echo "===========Delete single-solution-import-job POD============="
kubectl delete job single-solution-import-job -n $NS

echo "===========Uninstall single-solution-import============="
helm uninstall single-solution-import -n $NS

echo "===========Install single-solution-import============="
helm install single-solution-import single-solution-import-578.tgz --set namespace=$NS,registryhost=helix-harbor.bmc.local,imagePullSecrets.name=bmc-dtrhub,job.initContainers.containers.container1.registryhost=helix-harbor.bmc.local,job.initContainers.containers.container1.org=bmc/lp0mz,job.container.org=bmc/lp0mz:,job.container.tag=6c6aa1bc-5,job.volumes[0].persistentVolumeClaim.claimName=poc-helix-nfs-pvc,job.volumes[0].name=repo-volume,job.container.envMap.env.TENANT_NAME="$TenantID",job.container.envMap.env.REPOSITORY_NAME="$KM",job.initContainers.enabled=false,job.volumes[1].name=gcpcert1,job.volumes[1].secret.secretName=kafka-pem,job.volumes[2].name=gcpcert2,job.volumes[2].secret.secretName=kafka-pem,job.volumes[1].secret.optional=true,job.volumes[2].secret.optional=true,job.serviceAccount=helix-onprem-sa -n $NS

echo "===========Waite for single-solution-import POD to Startup============="
sleep 10s

echo "===========Check log of single-solution-import ============="
POD2=`kubectl get pod -n $NS | grep single  | awk '{print $1}' `

echo "POD-Name: $POD2"
kubectl logs -f $POD2 -n $NS
