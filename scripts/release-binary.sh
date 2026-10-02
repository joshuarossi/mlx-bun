#!/bin/sh
# Port of main's one-shot build/sign/notarize/package flow. The staged Bun
# implementation owns workspace packaging and its relocated-bundle checks.
# PUBLISH=1 ./scripts/release-binary.sh [version] also publishes every channel.
# Overridable: MLX_BUN_SIGN_IDENTITY, NOTARY_PROFILE, BUILD_DIR, OUT_DIR.
set -eu
cd "$(dirname "$0")/.."
ARCH="$(uname -m)"
[ "$ARCH" = arm64 ] || { echo "release builds are arm64-only (got $ARCH)" >&2; exit 1; }
APP_VERSION="$(bun --no-env-file -e 'console.log(require("./apps/mlx-bun/package.json").version)')"
VERSION="${1:-$APP_VERSION}"
[ "$VERSION" = "$APP_VERSION" ] || { echo "version differs from app manifest: $APP_VERSION" >&2; exit 1; }
IDENTITY="${MLX_BUN_SIGN_IDENTITY:-$(security find-identity -v -p codesigning | awk -F'"' '/Developer ID Application/{print $2; exit}')}"
NOTARY_PROFILE="${NOTARY_PROFILE:-AC_PROFILE}"
OUT_DIR="${OUT_DIR:-dist-release}"
BUILD_DIR="${BUILD_DIR:-$OUT_DIR/prepared-v$VERSION}"
[ -n "$IDENTITY" ] || { echo "no Developer ID Application identity in the keychain" >&2; exit 1; }
echo "==> identity: $IDENTITY"
echo "==> version: $VERSION"
if [ ! -f "$BUILD_DIR/preparation.json" ]; then
  bun --no-env-file scripts/prepare-release.ts prepare "$BUILD_DIR"
fi
STAGE="$(bun --no-env-file -e 'import {readPreparation} from "./scripts/prepare-release.ts";console.log((await readPreparation(process.argv[1])).stage)' "$BUILD_DIR")"
if [ "$STAGE" = unsigned ]; then
  bun --no-env-file scripts/prepare-release.ts sign "$BUILD_DIR" "$IDENTITY"
  STAGE=signed
fi
if [ "$STAGE" = signed ]; then
  bun --no-env-file scripts/prepare-release.ts notarize "$BUILD_DIR" "$NOTARY_PROFILE"
fi
# Apple acceptance and unchanged bundle hashes are enforced by this stage.
if [ ! -f "$BUILD_DIR/release/mlx-bun-v$VERSION-$ARCH.tar.gz" ]; then
  bun --no-env-file scripts/prepare-release.ts package "$BUILD_DIR"
fi
mkdir -p "$OUT_DIR"
cp "$BUILD_DIR/release/"*.tar.gz "$BUILD_DIR/release/"*.sha256 "$OUT_DIR/"
echo "==> done: $OUT_DIR/mlx-bun-v$VERSION-$ARCH.tar.gz"
if [ "${PUBLISH:-0}" = 1 ]; then
  export OUT_DIR BUILD_DIR
  exec ./scripts/publish-release.sh "$VERSION"
fi
echo "Next: BUILD_DIR=$BUILD_DIR OUT_DIR=$OUT_DIR ./scripts/publish-release.sh $VERSION"
