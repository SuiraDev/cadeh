#!/usr/bin/env bash
# Legado — use: cadeh install | cadeh global
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${ROOT}/bin/cadeh" "$@"
