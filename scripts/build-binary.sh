#!/bin/sh
# Build the self-contained mlx-bun binary + sidecar dylib bundle.
#
#   ./scripts/build-binary.sh [outdir]      (default: dist/)
#
# Produces:
#   <outdir>/mlx-bun           single-file executable (bun build --compile)
#   <outdir>/libmlxc.dylib     mlx-c, dependent-lib path rewritten to
#                              @loader_path/libmlx.dylib
#   <outdir>/libmlx.dylib      mlx core
#   <outdir>/mlx.metallib      Metal kernel library (libmlx loads it from
#                              its own directory)
#
# The binary resolves libmlxc next to itself first (src/mlx/ffi.ts), so
# the directory is relocatable — drop it into a Tauri/Electron app's
# resources and spawn `mlx-bun serve` as a sidecar. Signing/notarization
# recipe: docs/embedding.md.
set -eu

OUT="${1:-dist}"
BREW_MLXC="${MLXC_DYLIB:-/opt/homebrew/lib/libmlxc.dylib}"
BREW_MLX_DIR="${MLX_LIB_DIR:-/opt/homebrew/opt/mlx/lib}"

mkdir -p "$OUT"

echo "==> compiling src/cli.ts -> $OUT/mlx-bun"
bun build --compile src/cli.ts --outfile "$OUT/mlx-bun"

echo "==> bundling dylibs"
cp -f "$BREW_MLXC" "$OUT/libmlxc.dylib"
cp -f "$BREW_MLX_DIR/libmlx.dylib" "$OUT/libmlx.dylib"
cp -f "$BREW_MLX_DIR/libjaccl.dylib" "$OUT/libjaccl.dylib"
cp -f "$BREW_MLX_DIR/mlx.metallib" "$OUT/mlx.metallib"

# libmlxc references libmlx by absolute brew path; point it at the copy
# in the same directory. libmlx references @rpath/libjaccl.dylib with an
# @loader_path/../lib rpath — add @loader_path so the flat bundle layout
# resolves it. arm64 requires re-signing after any load-command rewrite
# (ad-hoc here; replace with your identity for distribution).
install_name_tool -change "$BREW_MLX_DIR/libmlx.dylib" \
  "@loader_path/libmlx.dylib" "$OUT/libmlxc.dylib"
install_name_tool -add_rpath "@loader_path" "$OUT/libmlx.dylib" 2>/dev/null || true
codesign -f -s - "$OUT/libmlxc.dylib" "$OUT/libmlx.dylib" "$OUT/libjaccl.dylib" >/dev/null 2>&1

echo "==> bundle:"
ls -lh "$OUT" | awk 'NR>1 {print "    " $9 "  " $5}'
echo "==> smoke: $OUT/mlx-bun ls"
"$OUT/mlx-bun" ls >/dev/null && echo "    ok"
