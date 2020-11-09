#!/usr/bin/env bash
set -euo pipefail

ScriptDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

# shellcheck source=./export.sh
. "$(realpath "$ScriptDirectory/export.sh")"

aws ec2 create-volume \
  --region "$AWS_REGION" \
  --availability-zone "$(echo "$ZONES" | cut -d',' -f1)" \
  --size 10 \
  --tag-specifications "ResourceType=volume, Tags=[{Key=KubernetesCluster,Value=$CLUSTER_NAME}]" \
  --volume-type gp2
