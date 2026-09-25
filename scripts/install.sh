#!/bin/sh
# curl -fsSL https://mlx-bun.dev/install.sh | sh
# MLX_BUN_INSTALL_DIR defaults to ~/.mlx-bun; MLX_BUN_VERSION defaults to latest.
# This script owns only app-install/ below that root, never sessions or settings.
set -eu

fail() { echo "mlx-bun: $*" >&2; exit 1; }
if [ "${1:-}" = "--help" ]; then
  echo "Usage: sh install.sh"
  echo "MLX_BUN_INSTALL_DIR: installation root (default ~/.mlx-bun)"
  echo "MLX_BUN_VERSION: latest or a release tag such as v0.5.0"
  echo "Installs the complete bundle under app-install/ and links ~/.local/bin/mlx-bun."
  exit 0
fi
[ "$#" = 0 ] || fail "use --help for usage"
[ "$(uname -s)/$(uname -m)" = "Darwin/arm64" ] || fail "Apple Silicon macOS is required"
VERSION="${MLX_BUN_VERSION:-latest}"
if [ "$VERSION" != latest ]; then
  printf '%s\n' "$VERSION" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.-]+)?(\+[A-Za-z0-9.-]+)?$' || fail "invalid release tag: $VERSION"
fi
INSTALL_DIR="${MLX_BUN_INSTALL_DIR:-$HOME/.mlx-bun}"
mkdir -p "$INSTALL_DIR"
INSTALL_DIR="$(cd "$INSTALL_DIR" && pwd -P)"
APP_ROOT="$INSTALL_DIR/app-install"
[ ! -L "$APP_ROOT" ] || fail "app-install must not be a symlink"
if [ ! -e "$APP_ROOT" ]; then
  mkdir "$APP_ROOT"
  printf 'mlx-bun installer\n' > "$APP_ROOT/.installer-owned"
fi
[ -f "$APP_ROOT/.installer-owned" ] || fail "app-install already exists and is not installer-owned"

# Never reclaim a lock while another installer might be using this directory.
if ! mkdir "$APP_ROOT/lock" 2>/dev/null; then
  OWNER="$(cat "$APP_ROOT/lock/pid" 2>/dev/null || echo unknown)"
  fail "$APP_ROOT/lock exists (installer PID $OWNER); remove this lock directory only after confirming that installer is no longer running"
fi
printf '%s\n' "$$" > "$APP_ROOT/lock/pid"
STAGE=""; LINK=""; SWITCHED=0; COMPLETE=0; PREVIOUS=""
cleanup() {
  if [ "$SWITCHED" = 1 ] && [ "$COMPLETE" = 0 ]; then
    if [ -n "$PREVIOUS" ]; then
      ln -s "$PREVIOUS" "$APP_ROOT/rollback"
      mv -fh "$APP_ROOT/rollback" "$APP_ROOT/current"
    else
      rm -f "$APP_ROOT/current"
    fi
  fi
  [ -z "$LINK" ] || rm -f "$LINK"
  rm -f "$APP_ROOT/next" "$APP_ROOT/rollback"
  if [ "$COMPLETE" = 0 ] && [ -n "$STAGE" ]; then rm -rf "$STAGE"; fi
  rm -f "$APP_ROOT/lock/pid"
  rmdir "$APP_ROOT/lock"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
if [ -e "$APP_ROOT/current" ] || [ -L "$APP_ROOT/current" ]; then
  [ -L "$APP_ROOT/current" ] || fail "current must be an installer symlink"
  PREVIOUS="$(readlink "$APP_ROOT/current")"
fi
STAGE="$(mktemp -d "$APP_ROOT/bundle.XXXXXX")"
if [ "$VERSION" = latest ]; then
  URL="https://github.com/joshuarossi/mlx-bun/releases/latest/download/mlx-bun-arm64.tar.gz"
else
  URL="https://github.com/joshuarossi/mlx-bun/releases/download/$VERSION/mlx-bun-arm64.tar.gz"
fi
echo "Downloading mlx-bun ($VERSION)"
curl -fSL --progress-bar "$URL" -o "$STAGE/archive.tar.gz"
tar -tzf "$STAGE/archive.tar.gz" > "$STAGE/entries"
while IFS= read -r entry; do
  [ "$entry" != './' ] || continue
  entry="${entry#./}"
  printf '%s\n' "$entry" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9._-]*$' || fail "bundle must contain flat file names"
  case "$entry" in archive.tar.gz|entries) fail "reserved bundle file: $entry";; esac
done < "$STAGE/entries"
# Reject links and special files before extraction. Only the optional ./ root
# entry may be a directory; all current bundle assets are regular flat files.
tar -tvzf "$STAGE/archive.tar.gz" | awk 'substr($0,1,1) != "-" && !(substr($0,1,1) == "d" && $NF == "./") { exit 1 }' || fail "bundle contains non-regular files"
tar -xzf "$STAGE/archive.tar.gz" -C "$STAGE"
rm "$STAGE/archive.tar.gz" "$STAGE/entries"
for file in mlx-bun libmlxc.dylib libmlx.dylib libjaccl.dylib mlx.metallib \
  libmlx_bun_expert_io.dylib mlx-bun-frame-extract photon_rs_bg.wasm LICENSE THIRD_PARTY_NOTICES.md; do
  [ -f "$STAGE/$file" ] && [ -s "$STAGE/$file" ] || fail "incomplete bundle: $file"
done
[ -x "$STAGE/mlx-bun" ] || fail "bundle executable is not executable"
ACTUAL="$(MLX_BUN_LIBMLXC=/nonexistent/installer-check "$STAGE/mlx-bun" --version </dev/null)"
printf '%s\n' "$ACTUAL" | grep -Eq '^mlx-bun [0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.-]+)?(\+[A-Za-z0-9.-]+)?$' || fail "invalid bundle version"
[ "$VERSION" = latest ] || [ "$ACTUAL" = "mlx-bun ${VERSION#v}" ] || fail "expected $VERSION, got $ACTUAL"

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
[ ! -d "$BIN_DIR/mlx-bun" ] || [ -L "$BIN_DIR/mlx-bun" ] || fail "command destination is a directory"
LINK="$BIN_DIR/.mlx-bun-install-$$"
ln -s "$APP_ROOT/current/mlx-bun" "$LINK"
ln -s "${STAGE##*/}" "$APP_ROOT/next"
# macOS mv -h replaces the destination symlink itself, never its directory.
mv -fh "$APP_ROOT/next" "$APP_ROOT/current"
SWITCHED=1
mv -fh "$LINK" "$BIN_DIR/mlx-bun"
LINK=""; COMPLETE=1

# A running Bun executable re-execs its canonical path for managed jobs. Keep
# every in-use bundle, not just the previous install. Inspect executable names,
# never command arguments, and retain all old bundles if inspection fails.
PROCESSES=""
if ! PROCESSES="$(/bin/ps -axww -o comm=)" || [ -z "$PROCESSES" ]; then
  echo "Warning: cannot inspect running executables; keeping older bundles." >&2
  CAN_PRUNE=0
else
  CAN_PRUNE=1
fi
bundle_running() {
  while IFS= read -r executable; do
    case "$executable" in "$1/"*) return 0;; esac
  done <<EOF
$PROCESSES
EOF
  return 1
}
# Also retain the immediate previous bundle for rollback. Never follow symlinks.
for old in "$APP_ROOT"/bundle.*; do
  [ "$old" = "$STAGE" ] && continue
  [ "$old" = "$APP_ROOT/$PREVIOUS" ] && continue
  [ "$CAN_PRUNE" = 1 ] || continue
  if [ -d "$old" ] && [ ! -L "$old" ]; then
    if bundle_running "$old"; then
      echo "Keeping running app bundle: $old" >&2
    else
      rm -rf "$old"
    fi
  fi
done
echo "Installed $ACTUAL at $BIN_DIR/mlx-bun"
RESOLVED="$(command -v mlx-bun || true)"
if [ "$RESOLVED" = "$BIN_DIR/mlx-bun" ]; then
  echo "Run: mlx-bun"
elif [ -n "$RESOLVED" ]; then
  echo "Warning: mlx-bun on PATH resolves to $RESOLVED, not the new installation." >&2
  printf 'Use "%s/mlx-bun" or prepend PATH: export PATH="%s:$PATH"\n' "$BIN_DIR" "$BIN_DIR"
else
  printf 'Add to PATH: export PATH="%s:$PATH"\n' "$BIN_DIR"
fi
