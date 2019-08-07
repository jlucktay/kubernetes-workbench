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

FileSystemId=$(aws efs create-file-system --creation-token 1 | jq -r '.FileSystemId')
echo "FileSystemId: $FileSystemId"

SubnetId=$(aws ec2 describe-subnets --filter "Name=tag:KubernetesCluster,Values=$CLUSTER_NAME" | jq -r '.Subnets[].SubnetId')
echo "SubnetId: $SubnetId"

SecurityGroupId=$(aws ec2 describe-security-groups --filter "Name=tag:Name,Values=nodes.$CLUSTER_NAME" | jq -r '.SecurityGroups[].GroupId')
echo "SecurityGroupId: $SecurityGroupId"

LifeCycleState=

until [ "$LifeCycleState" == "available" ]; do
    LifeCycleState=$(aws efs describe-file-systems --file-system-id "$FileSystemId" | jq -r '.FileSystems[].LifeCycleState')
    echo "LifeCycleState: $LifeCycleState"
done

aws efs create-mount-target --file-system-id "$FileSystemId" --subnet-id "$SubnetId" --security-groups "$SecurityGroupId"
