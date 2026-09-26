#!/bin/sh
# Build the microphone capture sidecar for `mlx-bun dictate`
# (native/mic-capture.swift → dist/native/mlx-bun-mic-capture). A source
# checkout builds explicitly; packages ship the staged binary.
set -eu
if [ "${1:-}" = "--help" ]; then
  echo "Usage: sh apps/mlx-bun/scripts/build-native.sh [output-file]"
  echo "Compile the microphone helper with swiftc; no microphone access or downloads."
  exit 0
fi
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist/native/mlx-bun-mic-capture}"
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"
# The Command Line Tools' default SDK can carry a malformed libSystem stub
# (macOS 27 CLT, 2026-09); pin the SDK xcrun selects (Xcode's) when unset.
SDKROOT="${SDKROOT:-$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)}"
[ -n "$SDKROOT" ] && export SDKROOT
mkdir -p "$(dirname "$OUT")"
swiftc -O -target "$(uname -m)-apple-macosx$DEPLOYMENT_TARGET" \
  "$ROOT/native/mic-capture.swift" -o "$OUT"
echo "$OUT"
