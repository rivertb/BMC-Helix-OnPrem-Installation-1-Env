#!/bin/bash

MIN_ARGS=1

if [ "$#" -lt "$MIN_ARGS" ]; then
    echo "Error：1 parameter required!"
    exit 1
fi

echo "POD-Name: $1"
kubectl logs -f $1 -n helix
