#!/usr/bin/env bash

FILE="$1"

pandoc \
    "$FILE" \
    --lua-filter=scripts/reader.lua \
    -t plain
