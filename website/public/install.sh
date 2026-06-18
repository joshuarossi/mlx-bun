#!/bin/sh
# mlx-bun installer — https://mlx-bun.dev
#
#   curl -fsSL https://mlx-bun.dev/install.sh | sh
#
# Downloads the signed, notarized self-contained binary from the latest
# GitHub release, installs it, and puts `mlx-bun` on your PATH.
#
# Env overrides:
#   MLX_BUN_INSTALL_DIR   install location (default: ~/.mlx-bun)
#   MLX_BUN_VERSION       pin a release tag, e.g. v0.0.4 (default: latest)
set -eu

REPO="joshuarossi/mlx-bun"
INSTALL_DIR="${MLX_BUN_INSTALL_DIR:-$HOME/.mlx-bun}"
VERSION="${MLX_BUN_VERSION:-latest}"

# 1. platform check — Apple Silicon macOS only (MLX is Metal-only).
OS="$(uname -s)"
ARCH="$(uname -m)"
if [ "$OS" != "Darwin" ] || [ "$ARCH" != "arm64" ]; then
  echo "mlx-bun runs on Apple Silicon Macs only (MLX is Metal-only)." >&2
  echo "  detected: $OS/$ARCH" >&2
  exit 1
fi

# 2. resolve the download url (versionless asset → stable across releases).
if [ "$VERSION" = "latest" ]; then
  URL="https://github.com/$REPO/releases/latest/download/mlx-bun-arm64.tar.gz"
else
  URL="https://github.com/$REPO/releases/download/$VERSION/mlx-bun-arm64.tar.gz"
fi

# 3. download + extract into the install dir.
echo "==> downloading mlx-bun ($VERSION)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -fSL --progress-bar "$URL" -o "$TMP/mlx-bun.tar.gz"
echo "==> installing to $INSTALL_DIR"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP/mlx-bun.tar.gz" -C "$INSTALL_DIR"

BIN="$INSTALL_DIR/mlx-bun"
chmod +x "$BIN" 2>/dev/null || true

# 4. put it on PATH: symlink into a writable bin dir if one exists, else
#    print how to add it. (The binary resolves its sibling dylibs via its
#    real path, so a symlink works fine.)
LINKED=""
for d in "$HOME/.local/bin" /usr/local/bin /opt/homebrew/bin; do
  if [ -d "$d" ] && [ -w "$d" ]; then
    ln -sf "$BIN" "$d/mlx-bun"
    LINKED="$d/mlx-bun"
    break
  fi
done

echo
echo "✅ mlx-bun installed."
if [ -n "$LINKED" ]; then
  echo "   linked: $LINKED"
  echo "   run:    mlx-bun"
else
  case ":$PATH:" in
    *":$INSTALL_DIR:"*) : ;;
    *)
      echo "   add it to your PATH:"
      echo "     export PATH=\"$INSTALL_DIR:\$PATH\""
      echo "   (append that line to your ~/.zshrc to make it permanent)"
      ;;
  esac
  echo "   run:    $BIN"
fi
