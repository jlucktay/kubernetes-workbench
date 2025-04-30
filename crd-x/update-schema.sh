#!/usr/bin/env bash
set -euo pipefail

declare script_dir
script_dir="$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")"

cd "$script_dir"

# Build the worker image.
readonly worker_image="ghcr.io/jlucktay/crd-x"
docker build --tag "$worker_image" .

# Create a cluster with K3D, if not already running.
if ! k3d cluster list --output=json | jq --exit-status '.[] | select(.name == "aok")' &> /dev/null; then
  k3d cluster create --config="./k3d-config.yaml"
fi

# Wait for cluster OK, i.e. Deployments available.
for deployment in coredns local-path-provisioner metrics-server traefik; do
  printf "🚧 %22s " "$deployment"

  until kubectl --context="k3d-aok" get deployments "$deployment" --namespace=kube-system &> /dev/null; do
    echo -n .
    sleep 1
  done

  until kubectl --context="k3d-aok" wait deployments "$deployment" --for=condition=Available --namespace=kube-system --timeout=0 &> /dev/null; do
    echo -n +
    sleep 1
  done

  echo " ✅ OK"
done

# Set name/IP of server container.
readonly k3d_server="https://k3d-aok-server-0:6443"

# Transform kubeconfig with K3D server address.
k3d_kubeconfig="$(mktemp)"
kubectl --context="k3d-aok" config view --minify --raw | yq ".clusters[].cluster.server = \"$k3d_server\"" > "$k3d_kubeconfig"

# Apply the AdventPuzzle CRD to the cluster.
declare crd_yaml
crd_yaml=$(realpath "../adventofcode/yaml/crd.yaml")
kubectl --context="k3d-aok" apply --filename="$crd_yaml"

# Set up the schema output directory.
declare schema_dir
schema_dir=$(realpath "../adventofcode/schema/")

# Load yq output into worker container as its kubeconfig, and save the JSON Schema output.
docker run --network="k3d-aok" --rm --volume="$k3d_kubeconfig:/root/.kube/config:ro" --volume="$schema_dir:/schema/:rw" "$worker_image"
