#!/bin/bash

MIN_ARGS=1

if [ "$#" -lt "$MIN_ARGS" ]; then
    echo "Error：1 parameters required!"
    exit 1
fi

kubectl -n helix exec -it $1 -- bash
