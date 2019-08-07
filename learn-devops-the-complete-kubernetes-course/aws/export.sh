#!/usr/bin/env bash

export AWS_DEFAULT_PROFILE=crlab-kops

AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile $AWS_DEFAULT_PROFILE)
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile $AWS_DEFAULT_PROFILE)
export AWS_SECRET_ACCESS_KEY

export CLUSTER_NAME="jlucktay.aws.crlabs.cloud"
export NAME=$CLUSTER_NAME

export CLOUD="aws"
export KOPS_S3_BUCKET="cr-jlucktay-kops-state"
export KOPS_STATE_STORE="s3://$KOPS_S3_BUCKET"
export AWS_REGION="eu-west-2"

# ZONES=$(aws ec2 describe-availability-zones --region "$AWS_REGION" | jq -r '.AvailabilityZones[].ZoneName' | paste --serial --delimiters="," -)
# One zone only ("AvailabilityZones[0]")
ZONES=$(aws ec2 describe-availability-zones --region "$AWS_REGION" | jq -r '.AvailabilityZones[0].ZoneName' | paste --serial --delimiters="," -)
export ZONES

# X nodes per zone
ZONE_COUNT_INTERMEDIATE="${ZONES//[^,]}"
NODES_PER_ZONE=3

export NODE_COUNT=$(( ( ${#ZONE_COUNT_INTERMEDIATE} + 1 ) * NODES_PER_ZONE ))
