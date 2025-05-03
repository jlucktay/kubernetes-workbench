#!/usr/bin/env bash
set -euo pipefail

aoc_group=$(kubectl api-resources --api-group=adventofcode.jlucktay.dev --no-headers --output=name)
mapfile -t aoc_kinds <<< "$aoc_group"

# Read by openapi2jsonschema.py below.
export FILENAME_FORMAT="{fullgroup}_{kind}_{version}"

for kind in "${aoc_kinds[@]}"; do
  kubectl get customresourcedefinitions.apiextensions.k8s.io "$kind" --output=yaml > "/tmp/$kind.yaml"
done

cd /schema
python3 /work/openapi2jsonschema.py /tmp/*.yaml

readonly id_prefix="https://github.com/jlucktay/kubernetes-workbench/raw/refs/heads/main/adventofcode/schema/"
readonly schema_draft="https://json-schema.org/draft-07/schema"

for schema in /schema/*.json; do
  jq --arg id "$id_prefix${schema##*/}" --arg sd "$schema_draft" --sort-keys '.["$id"] = $id | .["$schema"] = $sd' "$schema" | sponge "$schema"
done
