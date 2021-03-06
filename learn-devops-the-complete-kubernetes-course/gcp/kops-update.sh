#!/usr/bin/env bash
set -euo pipefail

ScriptDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

# shellcheck source=./export.sh
. "$(realpath "$ScriptDirectory/export.sh")"

kops update cluster --name="$CLUSTER_NAME" --yes
