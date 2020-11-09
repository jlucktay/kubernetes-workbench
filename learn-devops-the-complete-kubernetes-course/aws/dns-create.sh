#!/usr/bin/env bash
set -euo pipefail

ScriptDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

# shellcheck source=./export.sh
. "$(realpath "$ScriptDirectory/export.sh")"

ID=$(uuidgen) && aws route53 create-hosted-zone --name "$CLUSTER_NAME" --caller-reference "$ID" | jq .DelegationSet.NameServers

# ns-689.awsdns-22.net
# ns-1677.awsdns-17.co.uk
# ns-1209.awsdns-23.org
# ns-334.awsdns-41.com
