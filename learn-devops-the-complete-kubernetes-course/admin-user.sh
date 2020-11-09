#!/usr/bin/env bash
set -euo pipefail

kubectl -n kube-system describe secret "$(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')"
