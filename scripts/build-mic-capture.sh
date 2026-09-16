#!/bin/sh
# Build the microphone capture sidecar for `mlx-bun dictate`
# (src/native/mic_capture.swift → mlx-bun-mic-capture). Ships beside the binary.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist-native/mlx-bun-mic-capture}"
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"
mkdir -p "$(dirname "$OUT")"
swiftc -O -target "$(uname -m)-apple-macosx$DEPLOYMENT_TARGET" \
  "$ROOT/src/native/mic_capture.swift" -o "$OUT"
echo "$OUT"
