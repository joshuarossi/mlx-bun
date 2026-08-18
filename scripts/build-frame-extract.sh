#!/bin/sh
# Build the AVFoundation frame-extraction sidecar (video input decode —
# darwin-native codecs, the afconvert doctrine; see src/native/
# frame_extract.swift). Ships beside the binary and in the native pack as
# `mlx-bun-frame-extract`.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist-native/mlx-bun-frame-extract}"
mkdir -p "$(dirname "$OUT")"
swiftc -O "$ROOT/src/native/frame_extract.swift" -o "$OUT"
echo "$OUT"
