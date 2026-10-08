#!/bin/sh
# Offline Metal + MLX Primitive probe. Builds only; never starts GPU work.
# Headers MUST match the linked MLX build. No packages are fetched or installed.
set -eu
if [ "$#" -ne 4 ] && [ "$#" -ne 5 ]; then
  echo "Usage: sh scripts/bench/build-q4-native.sh MLX_SOURCE METAL_CPP_HEADERS MLX_LIB_DIR EXTERNAL_OUT [--runtime-compile]" >&2
  exit 1
fi
MLX_SOURCE="$1"; METAL_HEADERS="$2"; MLX_LIB="$3"; PROBE_OUT="$4"
MLX_SOURCE="$(cd "$MLX_SOURCE" && pwd)"
METAL_HEADERS="$(cd "$METAL_HEADERS" && pwd)"
MLX_LIB="$(cd "$MLX_LIB" && pwd)"
mkdir -p "$PROBE_OUT"
PROBE_OUT="$(cd "$PROBE_OUT" && pwd)"
PROBE_SRC="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$PROBE_SRC/../.." && pwd)"
case "$PROBE_OUT" in "$REPO_ROOT"|"$REPO_ROOT"/*)
  echo "Build output must be outside the checkout" >&2; exit 1;;
esac
KERNEL_PATH="$PROBE_OUT"
if [ "${5:-}" = "--runtime-compile" ]; then
  # Still a native Primitive and Metal pipeline, not fast.metal_kernel. Useful
  # when macOS can compile Metal but Xcode's offline component is absent.
  cp "$PROBE_SRC/q4-native.metal" "$PROBE_OUT/q4-native.metal"
  KERNEL_PATH="$PROBE_OUT/q4-native.metal"
elif [ "$#" -eq 5 ]; then
  echo "Unknown option: $5" >&2; exit 1
else
  xcrun -sdk macosx metal -std=metal3.1 -O3 -fno-fast-math -c "$PROBE_SRC/q4-native.metal" -o "$PROBE_OUT/q4_native.air"
  xcrun -sdk macosx metallib "$PROBE_OUT/q4_native.air" -o "$PROBE_OUT/q4_native.metallib"
fi
xcrun clang++ -std=c++20 -O3 -I"$MLX_SOURCE" -I"$METAL_HEADERS" \
  "$PROBE_SRC/q4-native.cpp" -L"$MLX_LIB" -lmlx -framework Metal -framework Foundation \
  -Wl,-rpath,"$MLX_LIB" -o "$PROBE_OUT/q4-native"
{
  xcrun clang++ --version
  sw_vers
  sysctl -n machdep.cpu.brand_string hw.memsize
  if [ "$(git -C "$MLX_SOURCE" rev-parse --show-toplevel 2>/dev/null || true)" = "$MLX_SOURCE" ]; then
    git -C "$MLX_SOURCE" rev-parse HEAD
  else
    printf 'MLX source is an unversioned directory: %s\n' "$MLX_SOURCE"
  fi
  shasum -a 256 "$MLX_SOURCE/CMakeLists.txt" "$MLX_SOURCE/mlx/primitives.h" "$MLX_SOURCE/mlx/array.h" "$MLX_SOURCE/mlx/backend/metal/device.h"
  shasum -a 256 "$PROBE_SRC/build-q4-native.sh" "$PROBE_SRC/q4-native.cpp" "$PROBE_SRC/q4-native.metal" "$MLX_LIB/libmlx.dylib"
  printf 'kernel=%s\n' "$KERNEL_PATH"
} > "$PROBE_OUT/build-provenance.txt"
echo "Run on an idle GPU: $PROBE_OUT/q4-native $KERNEL_PATH 5120 5120"
echo "Append mma to measure the register-matrix candidate. Both candidates must pass numerical gates before runtime integration."
