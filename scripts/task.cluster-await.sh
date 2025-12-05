#!/usr/bin/env bash
set -euo pipefail

readonly context="${KUBECTL_CONTEXT:?}"

# Key = name, value = namespace
declare -A deployments=(
  ['coredns']='kube-system'
  ['local-path-provisioner']='local-path-storage'
)

# Wait for cluster OK, i.e. all Deployments are available.
for dep_key in "${!deployments[@]}"; do
  printf "🚧 %18s/%-22s " "${deployments[$dep_key]}" "$dep_key"

  until kubectl --context="$context" get deployments "$dep_key" --namespace="${deployments[$dep_key]}" &> /dev/null; do
    echo -n .
    sleep 1
  done

  until kubectl --context="$context" wait deployments "$dep_key" --for=condition=Available --namespace="${deployments[$dep_key]}" --timeout=0 &> /dev/null; do
    echo -n +
    sleep 1
  done

  echo "= ✅ OK"
done
