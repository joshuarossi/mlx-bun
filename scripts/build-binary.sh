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
# --- pi assets (Phase 16) --------------------------------------------
# pi's JS is bundled by `bun build --compile` automatically; what it
# resolves *by path* at runtime must ride along beside the binary. For a
# Bun single-file executable pi computes its package dir as
# dirname(process.execPath) (config.js getPackageDir, isBunBinary branch),
# so every asset goes directly in $OUT next to mlx-bun.
#
# The headless web-chat embed (src/pi-web.ts) needs only photon_rs_bg.wasm
# (the `read` tool's image resize). The EMBEDDED TERMINAL (src/pi-terminal.ts
# -> InteractiveMode) additionally resolves, by path:
#   theme/*.json            theme rendering (built-in dark/light fallback)
#   assets/*.png            startup art
#   export-html/*           the /export command's HTML template + vendor JS
#   package.json,CHANGELOG.md   version banner + startup changelog
#   native/.../darwin-modifiers.node   pi-tui native modifier-key detection
#                           (3rd resolver candidate dirname(execPath)/native;
#                            degrades gracefully if absent — see
#                            pi-tui/dist/native-modifiers.js)
# This mirrors upstream's own `copy-binary-assets` manifest
# (pi-coding-agent/package.json) — their release binary is built the same
# way, so each piece is a supported configuration.
#
# Bundled skills (src/web/skills/): each SKILL.md is embedded as a text
# import (src/web/skills.ts) and written to ~/.mlx-bun/skills/ at startup,
# then loaded via additionalSkillPaths. No bundle asset to sidecar and no
# build step here — skill loading is plain filesystem reads of the
# materialized files. noSkills:true still excludes the user's own skills.
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

echo "==> bundling pi terminal (TUI) assets"
# Resolved against process.execPath at runtime (see header). Source layout
# is the installed pi-coding-agent dist/ + pi-tui native prebuilds.
PI_DIST="node_modules/@earendil-works/pi-coding-agent/dist"
PI_ROOT="node_modules/@earendil-works/pi-coding-agent"
PI_TUI="node_modules/@earendil-works/pi-tui"
ARCH="$(uname -m)"  # arm64 | x86_64 -> darwin-arm64 / darwin-x64
case "$ARCH" in
  arm64) PI_NATIVE_ARCH="darwin-arm64" ;;
  x86_64) PI_NATIVE_ARCH="darwin-x64" ;;
  *) PI_NATIVE_ARCH="" ;;
esac

# Themes (built-in dark/light have a code fallback, but ship them so custom
# theme reads and the schema resolve).
if [ -d "$PI_DIST/modes/interactive/theme" ]; then
  mkdir -p "$OUT/theme"
  cp -f "$PI_DIST"/modes/interactive/theme/*.json "$OUT/theme/" 2>/dev/null || true
  echo "    theme/*.json"
fi
# Startup art.
if [ -d "$PI_DIST/modes/interactive/assets" ]; then
  mkdir -p "$OUT/assets"
  cp -f "$PI_DIST"/modes/interactive/assets/*.png "$OUT/assets/" 2>/dev/null || true
  echo "    assets/*.png"
fi
# /export HTML template + vendor JS.
if [ -f "$PI_DIST/core/export-html/template.html" ]; then
  mkdir -p "$OUT/export-html/vendor"
  cp -f "$PI_DIST/core/export-html/template.html" "$OUT/export-html/" 2>/dev/null || true
  cp -f "$PI_DIST"/core/export-html/vendor/*.js "$OUT/export-html/vendor/" 2>/dev/null || true
  echo "    export-html/{template.html,vendor/*.js}"
fi
# Version banner + startup changelog.
[ -f "$PI_ROOT/package.json" ] && cp -f "$PI_ROOT/package.json" "$OUT/package.json" && echo "    package.json"
[ -f "$PI_ROOT/CHANGELOG.md" ] && cp -f "$PI_ROOT/CHANGELOG.md" "$OUT/CHANGELOG.md" && echo "    CHANGELOG.md"
# pi-tui native modifier-key helper (graceful if missing).
PI_NODE="$PI_TUI/native/darwin/prebuilds/$PI_NATIVE_ARCH/darwin-modifiers.node"
if [ -n "$PI_NATIVE_ARCH" ] && [ -f "$PI_NODE" ]; then
  mkdir -p "$OUT/native/darwin/prebuilds/$PI_NATIVE_ARCH"
  cp -f "$PI_NODE" "$OUT/native/darwin/prebuilds/$PI_NATIVE_ARCH/darwin-modifiers.node"
  echo "    native/darwin/prebuilds/$PI_NATIVE_ARCH/darwin-modifiers.node"
else
  echo "    WARN: pi-tui darwin-modifiers.node not found for $ARCH;" \
       "native modifier-key detection will degrade (non-fatal)." >&2
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

echo "==> smoke: pi assets load (headless, no model/server)"
# Compile the verify script into a sibling binary inside the SAME bundle
# dir, then run it. Because it's a compiled Bun binary living next to the
# real one, process.execPath -> $OUT, so pi's by-path asset resolvers
# (photon wasm, theme/, export-html/, assets/, native/) resolve against the
# same layout the real binary sees. The script drives createAgentSession +
# initTheme + the native modifier load far enough to prove the bundled pi
# SDK + its assets load without a missing-asset crash; a provider/model
# error is the success signal.
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
