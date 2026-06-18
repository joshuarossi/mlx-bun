#!/bin/sh
# release-binary.sh — build, Developer-ID sign, notarize, and package the
# self-contained mlx-bun bundle for Homebrew distribution.
#
#   ./scripts/release-binary.sh [version]      (default: package.json version)
#
# One-time prerequisites (see docs/reference/distribution.md):
#   - a "Developer ID Application" cert in the login keychain
#   - a notarytool keychain profile (default name: AC_PROFILE)
#
# Output (in dist-release/):
#   mlx-bun-v<ver>-arm64.tar.gz        signed + notarized bundle (no parent dir)
#   mlx-bun-v<ver>-arm64.tar.gz.sha256
# and prints the version/url/sha256 to paste into the Homebrew formula.
#
# Overridable via env: MLX_BUN_SIGN_IDENTITY, NOTARY_PROFILE, BUILD_DIR,
# OUT_DIR.
set -eu

ARCH="$(uname -m)"
[ "$ARCH" = "arm64" ] || { echo "release builds are arm64-only (got $ARCH)" >&2; exit 1; }

VERSION="${1:-$(bun -e 'console.log(require("./package.json").version)')}"
IDENTITY="${MLX_BUN_SIGN_IDENTITY:-$(security find-identity -v -p codesigning | awk -F'"' '/Developer ID Application/{print $2; exit}')}"
NOTARY_PROFILE="${NOTARY_PROFILE:-AC_PROFILE}"
BUILD_DIR="${BUILD_DIR:-dist}"
OUT_DIR="${OUT_DIR:-dist-release}"
ENTITLEMENTS="scripts/entitlements.plist"

[ -n "$IDENTITY" ] || {
  echo "no 'Developer ID Application' identity in the keychain." >&2
  echo "create one: Xcode -> Settings -> Accounts -> Manage Certificates -> + -> Developer ID Application" >&2
  exit 1
}
[ -f "$ENTITLEMENTS" ] || { echo "missing $ENTITLEMENTS" >&2; exit 1; }

echo "==> identity: $IDENTITY"
echo "==> version:  $VERSION"

# 1. build the relocatable bundle (binary + dylibs + metallib + pi assets).
#    build-binary.sh ad-hoc signs the dylibs; we re-sign with Developer ID
#    below (--force replaces the ad-hoc signature).
./scripts/build-binary.sh "$BUILD_DIR"

# 2. sign every nested Mach-O first (dylibs + any .node), then the main
#    executable with entitlements. Nested-before-container is required.
#    The metallib / wasm / json / png assets are data, not code — skipped.
echo "==> signing nested code (dylibs, .node)"
find "$BUILD_DIR" -type f \( -name '*.dylib' -o -name '*.node' \) -print0 \
  | xargs -0 codesign --force --timestamp --options runtime -s "$IDENTITY"

echo "==> signing executable (with JIT entitlements)"
codesign --force --timestamp --options runtime \
  --entitlements "$ENTITLEMENTS" -s "$IDENTITY" "$BUILD_DIR/mlx-bun"

echo "==> verifying signature"
codesign --verify --strict --verbose=2 "$BUILD_DIR/mlx-bun"

# 3. post-sign smoke: a missing entitlement gets the binary killed on
#    launch — catch it here, not in a user's brew install.
echo "==> post-sign smoke"
"$BUILD_DIR/mlx-bun" --version >/dev/null && echo "    launches ok"

# 4. notarize — zip the bundle, submit, block until Apple's automated
#    scan returns (typically 1-5 min). A flat CLI bundle cannot be
#    stapled (stapler only does .app/.dmg/.pkg); the ticket lives on
#    Apple's servers and Gatekeeper checks online only when a copy is
#    quarantined. brew installs are not quarantined, so this is
#    belt-and-suspenders for any direct (browser) download you also ship.
mkdir -p "$OUT_DIR"
ZIP="$OUT_DIR/mlx-bun-notarize.zip"
echo "==> zipping for notarization"
ditto -c -k --keepParent "$BUILD_DIR" "$ZIP"
echo "==> submitting to notary service (automated; usually 1-5 min)"
xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait
rm -f "$ZIP"

# 5. package for Homebrew — clean tar.gz of the bundle CONTENTS (no parent
#    dir) so the formula's `libexec.install Dir["*"]` stays tidy.
TARBALL="mlx-bun-v${VERSION}-${ARCH}.tar.gz"
echo "==> packaging $TARBALL"
FILES=""
for f in mlx-bun libmlx.dylib libmlxc.dylib libjaccl.dylib mlx.metallib \
         photon_rs_bg.wasm theme assets export-html native \
         package.json CHANGELOG.md; do
  [ -e "$BUILD_DIR/$f" ] && FILES="$FILES $f"
done
# shellcheck disable=SC2086  # word-splitting $FILES is intentional
tar -czf "$OUT_DIR/$TARBALL" -C "$BUILD_DIR" $FILES
SHA="$(shasum -a 256 "$OUT_DIR/$TARBALL" | awk '{print $1}')"
echo "$SHA  $TARBALL" > "$OUT_DIR/$TARBALL.sha256"

echo
echo "==> done: $OUT_DIR/$TARBALL"
echo
echo "Paste into homebrew-mlx-bun/Formula/mlx-bun.rb:"
echo "  version \"$VERSION\""
echo "  url     \"https://github.com/joshuarossi/mlx-bun/releases/download/v$VERSION/$TARBALL\""
echo "  sha256  \"$SHA\""
echo
echo "Next:"
echo "  gh release create v$VERSION $OUT_DIR/$TARBALL --title \"mlx-bun v$VERSION\" --notes \"...\""
