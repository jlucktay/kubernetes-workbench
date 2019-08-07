#!/usr/bin/env bash
# Thank you: https://github.com/anordal/shellharden/blob/master/how_to_do_things_safely_in_bash.md#how-to-begin-a-bash-script
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# shellcheck source=./export.sh
. "$(realpath "$ScriptDirectory/export.sh")"

EFSID=$(aws efs create-file-system --creation-token 1 | jq -r '.FileSystemId')
ClusterSubnet=$(aws ec2 describe-subnets --filter "Name=tag:KubernetesCluster,Values=$CLUSTER_NAME" | jq -r '.Subnets[].SubnetId')
SecurityGroupID=$(aws ec2 describe-security-groups --filter "Name=tag:Name,Values=nodes.$CLUSTER_NAME" | jq -r '.SecurityGroups[].GroupId')

aws efs create-mount-target --file-system-id "$EFSID" --subnet-id "$ClusterSubnet" --security-groups "$SecurityGroupID"
