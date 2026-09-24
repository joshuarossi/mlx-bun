#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist/native/libmlx_bun_expert_io.dylib}"
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"
# The Command Line Tools' default SDK can carry a malformed libSystem stub
# (macOS 27 CLT, 2026-09); pin the SDK xcrun selects (Xcode's) when unset.
SDKROOT="${SDKROOT:-$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)}"
[ -n "$SDKROOT" ] && export SDKROOT
mkdir -p "$(dirname "$OUT")"
cc -std=c11 -O2 -Wall -Wextra -Werror -dynamiclib \
  "-mmacosx-version-min=$DEPLOYMENT_TARGET" \
  "$ROOT/native/expert-io.c" -o "$OUT"
echo "$OUT"
FRAME_OUT="$ROOT/dist/native/mlx-bun-frame-extract"
swiftc -O -target "$(uname -m)-apple-macosx$DEPLOYMENT_TARGET" \
  "$ROOT/native/frame-extract.swift" -o "$FRAME_OUT"
echo "$FRAME_OUT"
