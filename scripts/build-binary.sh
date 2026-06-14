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
#   <outdir>/photon_rs_bg.wasm pi's image codec (web chat `read` tool on
#                              image files); see "pi web-chat assets" below.
#
# The binary resolves libmlxc next to itself first (src/mlx/ffi.ts), so
# the directory is relocatable — drop it into a Tauri/Electron app's
# resources and spawn `mlx-bun serve` as a sidecar. Signing/notarization
# recipe: docs/reference/embedding.md.
#
# --- pi web-chat assets (Phase 16) -----------------------------------
# The embedded pi AgentSession (src/pi-web.ts) runs HEADLESS — no TUI. Its
# JS is bundled by `bun build --compile` automatically; the only runtime
# asset it resolves *by path* is photon_rs_bg.wasm, and only when the
# `read` tool is asked to read an image file. pi resolves it relative to
# process.execPath (the mlx-bun binary's dir), so we sidecar it next to
# the binary. Everything else pi ships beside its own compiled binary —
# theme/*.json, assets/*.png, export-html/*, docs/, examples/ — is
# TUI-only (theme rendering, the /export-html command, etc.) and is never
# reached by the headless web-chat path, so we intentionally omit it.
# (Verified: src/pi-web.ts builds the session with noThemes/noSkills/
# noExtensions; createAgentSession's import graph in sdk.js pulls in no
# theme/asset/export-html loaders. photon load failure degrades to null,
# so the wasm is graceful-best-effort, not load-bearing.)
set -eu

OUT="${1:-dist}"
BREW_MLXC="${MLXC_DYLIB:-/opt/homebrew/lib/libmlxc.dylib}"
BREW_MLX_DIR="${MLX_LIB_DIR:-/opt/homebrew/opt/mlx/lib}"

mkdir -p "$OUT"

echo "==> compiling src/cli.ts -> $OUT/mlx-bun"
bun build --compile src/cli.ts --outfile "$OUT/mlx-bun"

echo "==> bundling pi web-chat assets"
# Resolve photon_rs_bg.wasm from the resolved @silvia-odwyer/photon-node
# (pi's image dep). Allow override via PHOTON_WASM for unusual layouts.
PHOTON_WASM="${PHOTON_WASM:-}"
if [ -z "$PHOTON_WASM" ]; then
  for cand in \
    "node_modules/@silvia-odwyer/photon-node/photon_rs_bg.wasm" \
    "node_modules/@earendil-works/pi-coding-agent/dist/photon_rs_bg.wasm"; do
    if [ -f "$cand" ]; then PHOTON_WASM="$cand"; break; fi
  done
fi
if [ -n "$PHOTON_WASM" ] && [ -f "$PHOTON_WASM" ]; then
  cp -f "$PHOTON_WASM" "$OUT/photon_rs_bg.wasm"
  echo "    photon_rs_bg.wasm <- $PHOTON_WASM"
else
  echo "    WARN: photon_rs_bg.wasm not found; web-chat image reads will" \
       "not resize (set PHOTON_WASM=<path> to include it)." >&2
fi

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

echo "==> smoke: binary launches"
"$OUT/mlx-bun" --version
"$OUT/mlx-bun" --help >/dev/null && echo "    --help ok"
"$OUT/mlx-bun" ls >/dev/null && echo "    ls ok"

echo "==> smoke: pi web-chat assets load (headless, no model/server)"
# Compile the verify script into a sibling binary inside the SAME bundle
# dir, then run it. Because it's a compiled Bun binary living next to the
# real one, process.execPath -> $OUT, so pi's by-path asset resolvers
# (photon wasm, theme/, export-html/, assets/) resolve against the same
# layout the real binary sees. The script drives createAgentSession far
# enough to prove the bundled pi SDK + its assets load without a
# missing-asset crash; a provider/model error is the success signal.
if [ -f "scripts/verify-binary-pi.ts" ]; then
  bun build --compile scripts/verify-binary-pi.ts \
    --outfile "$OUT/verify-binary-pi" >/dev/null 2>&1
  if "$OUT/verify-binary-pi"; then
    echo "    pi assets ok"
  else
    echo "    WARN: pi asset smoke failed; see scripts/verify-binary-pi.ts" >&2
  fi
  rm -f "$OUT/verify-binary-pi"
fi
