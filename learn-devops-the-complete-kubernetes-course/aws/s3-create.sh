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

aws s3api create-bucket --bucket $KOPS_S3_BUCKET --region us-east-1

aws s3api put-bucket-versioning --bucket $KOPS_S3_BUCKET --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket $KOPS_S3_BUCKET \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
