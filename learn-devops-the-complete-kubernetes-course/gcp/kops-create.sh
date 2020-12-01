#!/usr/bin/env bash
set -euo pipefail

ScriptDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

# shellcheck source=./export.sh
. "$(realpath "$ScriptDirectory/export.sh")"

kops create cluster --name="$CLUSTER_NAME" --cloud="$CLOUD" --state="$KOPS_STATE_STORE" --project="$PROJECT" --zones="$ZONES" \
  --node-count="$NODE_COUNT" --yes
