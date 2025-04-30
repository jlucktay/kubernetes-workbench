#!/usr/bin/env bash
set -euo pipefail

readonly ap_crd="adventpuzzles.k8s.jlucktay.dev"

kubectl get customresourcedefinitions.apiextensions.k8s.io "$ap_crd" --output=yaml > "/tmp/$ap_crd.yaml"

cd /schema
export FILENAME_FORMAT="{fullgroup}_{kind}_{version}"
python3 /work/openapi2jsonschema.py "/tmp/$ap_crd.yaml"

readonly id_prefix="https://github.com/jlucktay/kubernetes-workbench/raw/refs/heads/main/adventofcode/schema/"
readonly schema_draft="https://json-schema.org/draft-07/schema"

for schema in /schema/*.json; do
  jq --arg id "$id_prefix${schema##*/}" --arg sd "$schema_draft" --sort-keys '.["$id"] = $id | .["$schema"] = $sd' "$schema" | sponge "$schema"
done
