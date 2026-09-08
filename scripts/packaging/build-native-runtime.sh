#!/bin/sh
# Build the pinned C wrapper against the official macOS 14 MLX libraries.
# No Python interpreter or offline Metal compiler is needed. This produces
# local build inputs; it does not publish or install a native pack.
# Usage: sh scripts/packaging/build-native-runtime.sh <new-output-directory>
set -eu

[ "$(uname -s)/$(uname -m)" = Darwin/arm64 ] || {
  echo "The native runtime requires macOS arm64." >&2
  exit 1
}
OUT="${1:?usage: build-native-runtime.sh <new-output-directory>}"
[ ! -e "$OUT" ] || {
  echo "Output already exists: $OUT" >&2
  exit 1
}
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
CMAKE_BIN="${MLX_BUN_CMAKE:-cmake}"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

MLXC_COMMIT=c74db5307cc8ce122f48d97ef951b30578674e7f
METAL_URL=https://files.pythonhosted.org/packages/f7/ab/ba1952908c5d2a5070cf1cfbfea0161c4751ea62299e2776819810917483/mlx_metal-0.32.2-py3-none-macosx_14_0_arm64.whl
METAL_SHA256=3825fff379dbc107dd3413e564a06caeaa24819910ec49c0439e454c06a1b9b8

curl --fail --location --retry 3 "$METAL_URL" -o "$STAGE/metal.whl"
echo "$METAL_SHA256  $STAGE/metal.whl" | shasum -a 256 --check
unzip -q "$STAGE/metal.whl" -d "$STAGE/metal"
git init -q "$STAGE/mlxc"
git -C "$STAGE/mlxc" fetch -q --depth 1 https://github.com/ml-explore/mlx-c.git "$MLXC_COMMIT"
git -C "$STAGE/mlxc" checkout -q --detach FETCH_HEAD
[ "$(git -C "$STAGE/mlxc" rev-parse HEAD)" = "$MLXC_COMMIT" ]

"$CMAKE_BIN" -S "$STAGE/mlxc" -B "$STAGE/build" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
  -DMLX_C_BUILD_EXAMPLES=OFF -DMLX_C_USE_SYSTEM_MLX=ON \
  -DMLX_DIR="$STAGE/metal/mlx/share/cmake/MLX" \
  -DCMAKE_INSTALL_PREFIX="$OUT" -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0
"$CMAKE_BIN" --build "$STAGE/build" --parallel 3
"$CMAKE_BIN" --install "$STAGE/build"
cp "$STAGE/metal/mlx/lib/libmlx.dylib" "$OUT/lib/"
cp "$STAGE/metal/mlx/lib/libjaccl.dylib" "$OUT/lib/"
cp "$STAGE/metal/mlx/lib/mlx.metallib" "$OUT/lib/"
install_name_tool -change @rpath/libmlx.dylib @loader_path/libmlx.dylib "$OUT/lib/libmlxc.dylib"
install_name_tool -add_rpath @loader_path "$OUT/lib/libmlx.dylib"
codesign -f -s - "$OUT/lib/libmlxc.dylib" "$OUT/lib/libmlx.dylib" "$OUT/lib/libjaccl.dylib"
echo "Native runtime: $OUT/lib/libmlxc.dylib"
