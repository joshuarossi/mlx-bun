#!/bin/sh
# Build the mlx native runtime pack (option 3 of the one-binary decision,
# 2026-06-12): the 61 MB mlx-bun executable stays 100% ours; the MLX
# native runtime (libmlx + libmlxc + libjaccl + mlx.metallib, ~166 MB
# uncompressed) ships as a separate versioned, sha256-verified tarball
# that the binary downloads on first run into
# ~/Library/Caches/mlx-bun/native-v<ver>-<arch>/.
#
#   ./scripts/build-native-pack.sh <version> [outdir]   (default outdir: dist-native/)
#
# Emits <outdir>/mlx-bun-native-v<ver>-<arch>.tar.gz + .sha256, and
# prints the constants to bake into src/native-pack.ts.
set -eu

VER="${1:?usage: build-native-pack.sh <version> [outdir]}"
OUT="${2:-dist-native}"
ARCH="$(uname -m)"
BREW_MLXC="${MLXC_DYLIB:-/opt/homebrew/lib/libmlxc.dylib}"
BREW_MLX_DIR="${MLX_LIB_DIR:-/opt/homebrew/opt/mlx/lib}"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$OUT"

cp -f "$BREW_MLXC" "$STAGE/libmlxc.dylib"
cp -f "$BREW_MLX_DIR/libmlx.dylib" "$STAGE/libmlx.dylib"
cp -f "$BREW_MLX_DIR/libjaccl.dylib" "$STAGE/libjaccl.dylib"
cp -f "$BREW_MLX_DIR/mlx.metallib" "$STAGE/mlx.metallib"

# Same load-command rewrites as build-binary.sh: resolve siblings via
# @loader_path so the extracted directory is self-contained.
install_name_tool -change "$BREW_MLX_DIR/libmlx.dylib" \
  "@loader_path/libmlx.dylib" "$STAGE/libmlxc.dylib"
install_name_tool -add_rpath "@loader_path" "$STAGE/libmlx.dylib" 2>/dev/null || true
codesign -f -s - "$STAGE/libmlxc.dylib" "$STAGE/libmlx.dylib" "$STAGE/libjaccl.dylib" >/dev/null 2>&1

NAME="mlx-bun-native-v${VER}-${ARCH}.tar.gz"
tar -czf "$OUT/$NAME" -C "$STAGE" .
SHA="$(shasum -a 256 "$OUT/$NAME" | awk '{print $1}')"
SIZE="$(stat -f %z "$OUT/$NAME")"
echo "$SHA  $NAME" > "$OUT/$NAME.sha256"

echo "==> $OUT/$NAME"
echo "    bake into src/native-pack.ts:"
echo "    NATIVE_PACK_VERSION = \"$VER\""
echo "    NATIVE_PACK_SHA256[\"$ARCH\"] = \"$SHA\""
echo "    NATIVE_PACK_SIZE[\"$ARCH\"] = $SIZE"
