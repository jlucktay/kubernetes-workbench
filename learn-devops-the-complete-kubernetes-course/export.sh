export CLUSTER_NAME="simple.k8s.local"
export KOPS_STATE_STORE="gs://k8s-kops-state-0105193546/"
export PROJECT="cr-lab-jlucktaylor-0105193546"
export ZONES="europe-west2-c,europe-west2-b,europe-west2-a"
export NODE_COUNT="2"

# Unlock the GCE features
export KOPS_FEATURE_FLAGS="AlphaAllowGCE"
