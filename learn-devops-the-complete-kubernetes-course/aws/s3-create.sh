#!/usr/bin/env bash
set -euo pipefail

ScriptDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

# shellcheck source=./export.sh
. "$(realpath "$ScriptDirectory/export.sh")"

aws s3api create-bucket --bucket "$KOPS_S3_BUCKET" --region us-east-1

aws s3api put-bucket-versioning --bucket "$KOPS_S3_BUCKET" --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket "$KOPS_S3_BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
