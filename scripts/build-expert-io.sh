#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist-native/libmlx_bun_expert_io.dylib}"
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"
mkdir -p "$(dirname "$OUT")"
cc -std=c11 -O2 -Wall -Wextra -Werror -dynamiclib \
  "-mmacosx-version-min=$DEPLOYMENT_TARGET" \
  "$ROOT/src/native/expert_io.c" -o "$OUT"
echo "$OUT"
