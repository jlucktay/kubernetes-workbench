#!/usr/bin/env bash

export CLOUD="aws"
export CLUSTER_NAME="jlucktay.aws.crlabs.cloud"
export KOPS_STATE_STORE="s3://cr-jlucktay-kops-state"
export ZONES="eu-west-2a,eu-west-2b,eu-west-2c"

# X nodes per zone
ZONE_COUNT_INTERMEDIATE="${ZONES//[^,]}"
NODES_PER_ZONE=2

export NODE_COUNT=$(( ( ${#ZONE_COUNT_INTERMEDIATE} + 1 ) * NODES_PER_ZONE ))
