#!/bin/sh
# Build the AVFoundation frame-extraction sidecar (video input decode —
# darwin-native codecs, the afconvert doctrine; see src/native/
# frame_extract.swift). Ships beside the binary and in the native pack as
# `mlx-bun-frame-extract`.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist-native/mlx-bun-frame-extract}"
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"
# The Command Line Tools' default SDK can carry a malformed libSystem stub
# (macOS 27 CLT, 2026-09); pin the SDK xcrun selects (Xcode's) when unset.
SDKROOT="${SDKROOT:-$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)}"
[ -n "$SDKROOT" ] && export SDKROOT
mkdir -p "$(dirname "$OUT")"
swiftc -O -target "$(uname -m)-apple-macosx$DEPLOYMENT_TARGET" \
  "$ROOT/src/native/frame_extract.swift" -o "$OUT"
echo "$OUT"
