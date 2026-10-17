#!/bin/sh
# Build MLX, its Metal kernel library and the C wrapper from pinned sources
# with the local toolchain (CMake, Xcode and its Metal toolchain). No Python
# interpreter is used. This produces local build inputs; it does not publish or
# install a native pack.
# Usage: sh scripts/build-native.sh <new-output-directory>
set -eu

[ "$(uname -s)/$(uname -m)" = Darwin/arm64 ] || {
  echo "The native runtime requires macOS arm64." >&2
  exit 1
}
OUT="${1:?usage: build-native.sh <new-output-directory>}"
[ ! -e "$OUT" ] || {
  echo "Output already exists: $OUT" >&2
  exit 1
}
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
CMAKE_BIN="${MLX_BUN_CMAKE:-cmake}"
JOBS="$(sysctl -n hw.ncpu)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# MLX v0.32.2; the proofs pin the same revision.
MLX_COMMIT=1f8e74e3f12f31365464a6867c6579f0e9b29d85
MLXC_COMMIT=c74db5307cc8ce122f48d97ef951b30578674e7f
# MLX's CMake dependencies at v0.32.2, fetched here so each one is verified.
FMT_COMMIT=407c905e45ad75fc29bf0f9bb7c5c2fd3475976f # 12.1.0
GGUF_COMMIT=8fa6eb65236618e28fd7710a0fba565f7faa1848
METAL_CPP_URL=https://developer.apple.com/metal/cpp/files/metal-cpp_26.zip
METAL_CPP_SHA256=4df3c078b9aadcb516212e9cb03004cbc5ce9a3e9c068fa3144d021db585a3a4
JSON_URL=https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz
JSON_SHA256=d6c65aca6b1ed68e7a182f4757257b107ae403032760ed6ef121c9d55e81757d

fetch_commit() { # <repository> <commit> <directory>
  git init -q "$3"
  git -C "$3" fetch -q --depth 1 "$1" "$2"
  git -C "$3" checkout -q --detach FETCH_HEAD
  [ "$(git -C "$3" rev-parse HEAD)" = "$2" ]
}
fetch_archive() { # <url> <sha256> <file>
  curl --fail --location --retry 3 "$1" -o "$3"
  echo "$2  $3" | shasum -a 256 --check
}

fetch_commit https://github.com/ml-explore/mlx.git "$MLX_COMMIT" "$STAGE/mlx"
fetch_commit https://github.com/ml-explore/mlx-c.git "$MLXC_COMMIT" "$STAGE/mlxc"
fetch_commit https://github.com/fmtlib/fmt.git "$FMT_COMMIT" "$STAGE/fmt"
fetch_commit https://github.com/antirez/gguf-tools.git "$GGUF_COMMIT" "$STAGE/gguf"
fetch_archive "$METAL_CPP_URL" "$METAL_CPP_SHA256" "$STAGE/metal-cpp.zip"
fetch_archive "$JSON_URL" "$JSON_SHA256" "$STAGE/json.tar.xz"
unzip -q "$STAGE/metal-cpp.zip" -d "$STAGE"
tar -xf "$STAGE/json.tar.xz" -C "$STAGE"

# Release build with precompiled Metal kernels (no JIT), as in the official
# macOS 14 wheel. FETCHCONTENT_FULLY_DISCONNECTED keeps CMake off the network.
"$CMAKE_BIN" -S "$STAGE/mlx" -B "$STAGE/mlx-build" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
  -DMLX_BUILD_METAL=ON -DMLX_METAL_JIT=OFF -DMLX_BUILD_CPU=ON \
  -DMLX_BUILD_TESTS=OFF -DMLX_BUILD_EXAMPLES=OFF -DMLX_BUILD_BENCHMARKS=OFF \
  -DMLX_BUILD_PYTHON_BINDINGS=OFF -DMLX_USE_CCACHE=OFF \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_METAL_CPP="$STAGE/metal-cpp" \
  -DFETCHCONTENT_SOURCE_DIR_JSON="$STAGE/json" \
  -DFETCHCONTENT_SOURCE_DIR_FMT="$STAGE/fmt" \
  -DFETCHCONTENT_SOURCE_DIR_GGUFLIB="$STAGE/gguf" \
  -DCMAKE_INSTALL_PREFIX="$STAGE/mlx-install" -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0
"$CMAKE_BIN" --build "$STAGE/mlx-build" --parallel "$JOBS"
"$CMAKE_BIN" --install "$STAGE/mlx-build"

"$CMAKE_BIN" -S "$STAGE/mlxc" -B "$STAGE/mlxc-build" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
  -DMLX_C_BUILD_EXAMPLES=OFF -DMLX_C_USE_SYSTEM_MLX=ON \
  -DMLX_DIR="$STAGE/mlx-install/share/cmake/MLX" \
  -DCMAKE_INSTALL_PREFIX="$OUT" -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0
"$CMAKE_BIN" --build "$STAGE/mlxc-build" --parallel "$JOBS"
"$CMAKE_BIN" --install "$STAGE/mlxc-build"
cp "$STAGE/mlx-install/lib/libmlx.dylib" "$OUT/lib/"
cp "$STAGE/mlx-install/lib/mlx.metallib" "$OUT/lib/"
# Built when the SDK is 26.2 or newer; libmlx links it only when targeting 26.2.
cp "$STAGE/mlx-build/jaccl/libjaccl.dylib" "$OUT/lib/"
install_name_tool -change @rpath/libmlx.dylib @loader_path/libmlx.dylib "$OUT/lib/libmlxc.dylib"
install_name_tool -add_rpath @loader_path "$OUT/lib/libmlx.dylib"
codesign -f -s - "$OUT/lib/libmlxc.dylib" "$OUT/lib/libmlx.dylib" "$OUT/lib/libjaccl.dylib"
echo "Native runtime: $OUT/lib/libmlxc.dylib"
