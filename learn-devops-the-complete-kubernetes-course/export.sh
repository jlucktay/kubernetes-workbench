#!/usr/bin/env bash

export CLOUD="gce"
export CLUSTER_NAME="simple.k8s.local"
export KOPS_STATE_STORE="gs://k8s-kops-state"
export PROJECT="cr-lab-jlucktaylor-1707191144"
export ZONES="europe-west2-c,europe-west2-b,europe-west2-a"

# X nodes per zone
ZONE_COUNT_INTERMEDIATE="${ZONES//[^,]}"
NODES_PER_ZONE=3

export NODE_COUNT=$(( ( ${#ZONE_COUNT_INTERMEDIATE} + 1 ) * NODES_PER_ZONE ))

# Unlock the GCE features
export KOPS_FEATURE_FLAGS="AlphaAllowGCE"
