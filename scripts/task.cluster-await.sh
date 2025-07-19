#!/usr/bin/env bash
set -euo pipefail

readonly context="k3d-${K3D_CLUSTER_NAME:?}"

# Wait for cluster OK, i.e. all Deployments are available.
for deployment in coredns local-path-provisioner metrics-server traefik; do
  printf "🚧 %22s " "$deployment"

  until kubectl --context="$context" get deployments "$deployment" --namespace=kube-system &> /dev/null; do
    echo -n .
    sleep 1
  done

  until kubectl --context="$context" wait deployments "$deployment" --for=condition=Available --namespace=kube-system --timeout=0 &> /dev/null; do
    echo -n +
    sleep 1
  done

  echo "= ✅ OK"
done
