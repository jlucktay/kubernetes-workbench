#!/usr/bin/env bash
set -euo pipefail

readonly api_group="adventofcode.jlucktay.dev"

aoc_group=$(kubectl api-resources --api-group="$api_group" --no-headers --output=name)
mapfile -t aoc_kinds < <(printf "%s" "$aoc_group")

if [[ ${#aoc_kinds[@]} -eq 0 ]]; then
  echo >&2 "❌ no API resources found in group '$api_group'"
  exit 1
fi

for kind in "${aoc_kinds[@]}"; do
  kubectl get customresourcedefinitions.apiextensions.k8s.io "$kind" --output=yaml > "/tmp/$kind.yaml"
done

cd /schema

# Read by openapi2jsonschema.py below.
export FILENAME_FORMAT="{fullgroup}_{kind}_{version}"

python3 /bin/openapi2jsonschema.py /tmp/*.yaml

readonly id_prefix="https://github.com/jlucktay/kubernetes-workbench/raw/refs/heads/main/adventofcode/schema/"
readonly schema_draft="https://json-schema.org/draft-07/schema"

for schema in /schema/*.json; do
  jq --arg id "$id_prefix${schema##*/}" --arg sd "$schema_draft" --sort-keys '.["$id"] = $id | .["$schema"] = $sd' "$schema" | sponge "$schema"
done
