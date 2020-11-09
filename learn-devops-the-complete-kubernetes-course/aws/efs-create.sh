#!/usr/bin/env bash
set -euo pipefail

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
