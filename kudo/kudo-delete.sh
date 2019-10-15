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

set +e

kubectl delete -f https://raw.githubusercontent.com/kudobuilder/kudo/842c7f19a0a361751f0dab330faf3be147c9c4b3/docs/deployment/20-deployment.yaml
kubectl delete -f https://raw.githubusercontent.com/kudobuilder/kudo/v0.5.0/docs/deployment/10-crds.yaml
kubectl delete -f https://raw.githubusercontent.com/kudobuilder/kudo/v0.5.0/docs/deployment/00-prereqs.yaml
