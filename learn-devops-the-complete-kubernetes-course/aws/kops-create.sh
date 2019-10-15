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
ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

### Get flags ready to parse given arguments
YES=0

for i in "$@"; do
    case $i in
        -y|--yes)
            YES=1
            shift;;
        *) # unknown option
            echo "$ScriptName: unknown argument '$i'."
            exit 1;;
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
