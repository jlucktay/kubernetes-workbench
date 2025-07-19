#!/usr/bin/env bash
set -euo pipefail

k3d cluster create --config="${GIT_ROOT:?}/k3d-config.yaml"

# Prime the new cluster with the images it will use.
declare -a k3d_images=(
  rancher/klipper-helm:v0.9.7-build20250616
  rancher/klipper-lb:v0.4.13
  rancher/local-path-provisioner:v0.0.31
  rancher/mirrored-coredns-coredns:1.12.1
  rancher/mirrored-library-traefik:2.11.24
  rancher/mirrored-metrics-server:v0.7.2
)

for ki in "${k3d_images[@]}"; do
  if ! docker image inspect "$ki" &> /dev/null; then
    echo "🚧 image '$ki' not found locally, pulling..."
    docker pull "$ki"
  fi

  (
    set -x
    k3d image import "$ki" --cluster="${K3D_CLUSTER_NAME:?}" --mode=auto
  )
done
