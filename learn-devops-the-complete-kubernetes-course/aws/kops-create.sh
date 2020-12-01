#!/usr/bin/env bash
set -euo pipefail

ScriptName=$(basename "$0")
ScriptDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

### Get flags ready to parse given arguments
YES=0

for i in "$@"; do
  case $i in
    -y | --yes)
      YES=1
      shift
      ;;
    *) # unknown option
      echo "$ScriptName: unknown argument '$i'."
      exit 1
      ;;
  esac
done

# shellcheck source=./export.sh
. "$(realpath "$ScriptDirectory/export.sh")" --kops

# kops create cluster --cloud="$CLOUD" --zones="$ZONES" $CLUSTER_NAME --node-count=$NODE_COUNT --dry-run --output json
KopsArgs=(create cluster "--cloud=$CLOUD")
IFS="," KopsArgs+=("--zones=${ZONES[*]}")
KopsArgs+=("--node-count=$NODE_COUNT" "$CLUSTER_NAME")

if [ "$YES" == 1 ]; then
  KopsArgs+=(--yes)
fi

### Show arguments and execute with them
echo "Running Kops with following arguments:"
echo "${KopsArgs[@]}"

kops "${KopsArgs[@]}"
