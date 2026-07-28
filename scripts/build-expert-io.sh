#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist-native/libmlx_bun_expert_io.dylib}"
mkdir -p "$(dirname "$OUT")"
cc -std=c11 -O2 -Wall -Wextra -Werror -dynamiclib \
  "$ROOT/src/native/expert_io.c" -o "$OUT"
echo "$OUT"
