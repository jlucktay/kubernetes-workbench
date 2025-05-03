#!/usr/bin/env bash
set -euo pipefail

declare script_dir
script_dir="$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")"

cd "$script_dir"

# Set cluster name throughout this script.
# Note that it is also set in the K3D config file.
readonly k3d_cluster_name="aok"

# Build the worker image.
readonly worker_image="ghcr.io/jlucktay/crd-x"
docker build --tag "$worker_image" .

# Create a cluster with K3D, if not already running.
if ! k3d cluster list --output=json | jq --arg kcn "$k3d_cluster_name" --exit-status '.[] | select(.name == $kcn)' &> /dev/null; then
  k3d cluster create --config="./k3d-config.yaml"

  # Prime the new cluster with the images it will use.
  declare -a k3d_images=(
    rancher/klipper-helm:v0.9.4-build20250113
    rancher/klipper-lb:v0.4.13
    rancher/local-path-provisioner:v0.0.31
    rancher/mirrored-coredns-coredns:1.12.0
    rancher/mirrored-library-traefik:2.11.20
    rancher/mirrored-metrics-server:v0.7.2
  )

  for ki in "${k3d_images[@]}"; do
    if [[ ${DOCKER_PULL:-unset} != "unset" ]]; then
      (
        set -x
        time docker pull "$ki"
      )
    fi

    (
      set -x
      time k3d image import "$ki" --cluster="$k3d_cluster_name" --mode=auto
    )
  done
fi

# Wait for cluster OK, i.e. Deployments available.
for deployment in coredns local-path-provisioner metrics-server traefik; do
  printf "🚧 %22s " "$deployment"

  until kubectl --context="k3d-$k3d_cluster_name" get deployments "$deployment" --namespace=kube-system &> /dev/null; do
    echo -n .
    sleep 1
  done

  until kubectl --context="k3d-$k3d_cluster_name" wait deployments "$deployment" --for=condition=Available --namespace=kube-system --timeout=0 &> /dev/null; do
    echo -n +
    sleep 1
  done

  echo " ✅ OK"
done

# Set name/IP of server container.
readonly k3d_server="https://k3d-$k3d_cluster_name-server-0:6443"

# Transform kubeconfig with K3D server address.
k3d_kubeconfig="$(mktemp)"
kubectl --context="k3d-$k3d_cluster_name" config view --minify --raw | yq ".clusters[].cluster.server = \"$k3d_server\"" > "$k3d_kubeconfig"

# Apply the CRDs to the cluster.
declare yaml_dir
yaml_dir=$(realpath "../adventofcode/yaml")
kubectl --context="k3d-$k3d_cluster_name" apply --filename="$yaml_dir"/crd.*.yaml

# Set up the schema output directory.
declare schema_dir
schema_dir=$(realpath "../adventofcode/schema/")

# Load yq output into worker container as its kubeconfig, and save the JSON Schema output.
docker run --network="k3d-$k3d_cluster_name" --rm --volume="$k3d_kubeconfig:/root/.kube/config:ro" --volume="$schema_dir:/schema/:rw" "$worker_image"
