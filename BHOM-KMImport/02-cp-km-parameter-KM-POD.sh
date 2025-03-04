#!/bin/bash
MIN_ARGS=2
if [ "$#" -lt "$MIN_ARGS" ]; then
    echo "Error：2 parameters required!"
    exit 1
fi
echo "KM-Name: $1"
echo "POD-Name: $2"
kubectl -n helix cp $1 $2:/opt/bmc/bmc-repo
