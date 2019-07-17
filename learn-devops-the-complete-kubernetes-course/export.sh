export CLUSTER_NAME="simple.k8s.local"
export KOPS_STATE_STORE="gs://k8s-kops-state"
export PROJECT="cr-lab-jlucktaylor-1707191144"
export ZONES="europe-west2-c,europe-west2-b,europe-west2-a"
export NODE_COUNT="2"

# Unlock the GCE features
export KOPS_FEATURE_FLAGS="AlphaAllowGCE"
