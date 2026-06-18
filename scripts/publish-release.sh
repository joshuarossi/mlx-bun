#!/bin/sh
# publish-release.sh — publish a built+signed+notarized bundle and sync the
# Homebrew tap formula so `brew upgrade` picks it up. Run after
# release-binary.sh (or let release-binary.sh chain it via PUBLISH=1).
#
#   ./scripts/publish-release.sh [version]      (default: package.json version)
#
# Does three things, idempotently:
#   1. creates (or updates) the GitHub release v<ver> with the tarball asset
#   2. rewrites version/url/sha256 in the TAP's Formula/mlx-bun.rb and pushes
#   3. mirrors the same three fields into the in-repo source-of-truth formula
#      (packaging/homebrew/mlx-bun.rb) — left staged for you to commit
#
# Releases are inherently local (signing/notarization need the Developer ID
# cert + Apple creds on this Mac), so this local step is the single source
# of release truth — no cross-repo CI token to manage, nothing to forget.
#
# Overridable via env: OUT_DIR, REPO, TAP_REPO.
set -eu

VERSION="${1:-$(bun -e 'console.log(require("./package.json").version)')}"
ARCH="$(uname -m)"
OUT_DIR="${OUT_DIR:-dist-release}"
REPO="${REPO:-joshuarossi/mlx-bun}"
TAP_REPO="${TAP_REPO:-joshuarossi/homebrew-tap}"

TARBALL="mlx-bun-v${VERSION}-${ARCH}.tar.gz"
TARPATH="$OUT_DIR/$TARBALL"
[ -f "$TARPATH" ] || {
  echo "missing $TARPATH — run ./scripts/release-binary.sh $VERSION first" >&2
  exit 1
}

SHA="$(shasum -a 256 "$TARPATH" | awk '{print $1}')"
URL="https://github.com/$REPO/releases/download/v$VERSION/$TARBALL"
echo "==> version $VERSION  sha $SHA"

# A versionless copy of the same tarball, so the direct-download one-liner
# can target a STABLE url: releases/latest/download/mlx-bun-<arch>.tar.gz
# (the versioned asset name changes every release and can't be used there).
LATEST="mlx-bun-${ARCH}.tar.gz"
cp -f "$TARPATH" "$OUT_DIR/$LATEST"

# 1. GitHub release: create if absent, else clobber the assets in place.
if gh release view "v$VERSION" -R "$REPO" >/dev/null 2>&1; then
  echo "==> release v$VERSION exists; uploading assets (--clobber)"
  gh release upload "v$VERSION" "$TARPATH" "$OUT_DIR/$LATEST" -R "$REPO" --clobber
else
  echo "==> creating release v$VERSION"
  gh release create "v$VERSION" "$TARPATH" "$OUT_DIR/$LATEST" -R "$REPO" \
    --title "mlx-bun v$VERSION" --notes "mlx-bun v$VERSION"
fi

# Helper: surgically rewrite the three release-specific fields of a formula.
rewrite_formula() {
  /usr/bin/sed -i '' -E \
    -e "s|^  version \".*\"|  version \"$VERSION\"|" \
    -e "s|^  url \".*\"|  url \"$URL\"|" \
    -e "s|^  sha256 \".*\"|  sha256 \"$SHA\"|" \
    "$1"
}

# 2. Tap formula — clone, rewrite, push (only if changed).
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git -C "$TMP" clone -q "https://github.com/$TAP_REPO" tap
TAP_FORMULA="$TMP/tap/Formula/mlx-bun.rb"
[ -f "$TAP_FORMULA" ] || { echo "tap is missing Formula/mlx-bun.rb" >&2; exit 1; }
rewrite_formula "$TAP_FORMULA"
if git -C "$TMP/tap" diff --quiet; then
  echo "==> tap already at $VERSION"
else
  git -C "$TMP/tap" add Formula/mlx-bun.rb
  git -C "$TMP/tap" -c user.name="Josh" -c user.email="josh.rossi@alphapoint.com" \
    commit -q -m "mlx-bun $VERSION"
  git -C "$TMP/tap" push -q
  echo "==> tap pushed: $VERSION"
fi

# 3. Mirror into the in-repo source of truth (left for you to commit).
rewrite_formula packaging/homebrew/mlx-bun.rb
echo
echo "==> done."
echo "    packaging/homebrew/mlx-bun.rb updated — commit it:"
echo "      git commit -am \"chore(dist): mlx-bun $VERSION\""
echo "    users get it with: brew upgrade joshuarossi/tap/mlx-bun"
