#!/usr/bin/env bash

set -euo pipefail

ROOT="${1:-content}"

if [[ ! -d "$ROOT"  ]]; then
    echo "error: directory not found: $ROOT" >&2
    exit 1
fi

find "$ROOT" \
     -type d -name assets -prune -o \
     -not -path '*/.*' \
     -type f -name '*.md' -print
