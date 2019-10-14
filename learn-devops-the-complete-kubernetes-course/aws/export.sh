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

ScriptName=$(basename "$0")

### Set up usage/help output
function usage() {
    cat << HEREDOC

    Usage: $ScriptName [--help] [--kops] [-n=X|--nodes-per-zone=X] [-r=X|--aws-region=X] [-z=X|--zone-count=X]

    Optional arguments:
        -h,   --help                show this usage help
        -k,   --kops                configure AWS CLI to run under the 'kops' profile (default: SSO via Google)
        -n=X, --nodes-per-zone=X    provision X nodes per availability zone (default: 3)
        -r=X, --aws-region=X        use AWS region X (default: eu-west-2)
        -z=X, --zone-count=X        stripe nodes across X availability zones (default: 1)

    Example:

    Provision 4 nodes in each of 2 AZs (8 nodes total) in the 'us-east-1' region.
    $ $ScriptName -n=4 -z=2 --aws-region=us-east1

HEREDOC
}

### Get flags ready to parse given arguments
AWS_REGION="eu-west-2"
KOPS=0
NODES_PER_ZONE=3
ZONE_COUNT=1

for i in "$@"; do
    case $i in
        -k|--kops)
            KOPS=1
            shift;; # past argument
        -n=*|--nodes-per-zone=*)
            NODES_PER_ZONE="${i#*=}"
            shift;; # past argument=value
        -r=*|--aws-region=*)
            AWS_REGION="${i#*=}"
            shift;; # past argument=value
        -z=*|--zone-count=*)
            ZONE_COUNT="${i#*=}"
            shift;; # past argument=value
        -h|--help)
            usage
            exit 0;;
        *) # unknown option
            echo "${ScriptName} unknown argument '$i'."
            usage
            exit 1;;
    esac
done

# Validate argument number values
NumberRegEx='^[0-9]+$'
if ! [[ $NODES_PER_ZONE =~ $NumberRegEx ]]; then
    echo "${ScriptName} error: '${NODES_PER_ZONE}' is not a number" >&2; exit 1
fi
if ! [[ $ZONE_COUNT =~ $NumberRegEx ]]; then
    echo "${ScriptName} error: '${ZONE_COUNT}' is not a number" >&2; exit 1
fi

### AWS
export CLOUD="aws"
export AWS_REGION
export CLUSTER_NAME="jlucktay.aws.crlabs.cloud"

# Kops state in S3 bucket
export KOPS_S3_BUCKET="cr-jlucktay-kops-state"
export KOPS_STATE_STORE="s3://$KOPS_S3_BUCKET"

# Select/auth the desired set of credentials
if (( KOPS == 1 )); then
    AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$AWS_DEFAULT_PROFILE")
    export AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$AWS_DEFAULT_PROFILE")
    export AWS_SECRET_ACCESS_KEY

    export AWS_DEFAULT_PROFILE=crlab-kops
else
    echo "Refreshing AWS token with Google SSO..."
    aws-google-auth -p cr-labs-master
    export AWS_DEFAULT_PROFILE=cr-labs-jlucktay
fi

# Check AZs in target region
mapfile -t AvailableZones < <( aws ec2 describe-availability-zones --region "$AWS_REGION" \
    | jq --raw-output '.AvailabilityZones[].ZoneName' )

# Take highest of ZONE_COUNT and len(AvailableZones), and slice this many elements from ZONES
ZoneLen=$(( ZONE_COUNT > ${#AvailableZones[@]} ? ZONE_COUNT : ${#AvailableZones[@]} ))
export ZONES=("${AvailableZones[@]:0:${ZoneLen}}")

# X nodes per zone
export NODE_COUNT=$(( ${#ZONES[@]} * NODES_PER_ZONE ))
