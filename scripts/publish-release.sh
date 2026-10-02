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
#   3. publishes the workspace npm archives in dependency order
#
# Releases are inherently local (signing/notarization need the Developer ID
# cert + Apple creds on this Mac), so this local step is the single source
# of release truth — no cross-repo CI token to manage, nothing to forget.
#
# Overridable via env: OUT_DIR, REPO, TAP_REPO.
set -eu

cd "$(dirname "$0")/.."
VERSION="${1:-$(bun --no-env-file -e 'console.log(require("./apps/mlx-bun/package.json").version)')}"
ARCH="$(uname -m)"
OUT_DIR="${OUT_DIR:-dist-release}"
BUILD_DIR="${BUILD_DIR:-$OUT_DIR/prepared-v$VERSION}"
NOTES_FILE="${RELEASE_NOTES:-docs/planning/release-notes-v$VERSION.md}"
REPO="${REPO:-joshuarossi/mlx-bun}"
TAP_REPO="${TAP_REPO:-joshuarossi/homebrew-tap}"

TARBALL="mlx-bun-v${VERSION}-${ARCH}.tar.gz"
TARPATH="$OUT_DIR/$TARBALL"
[ -f "$TARPATH" ] || {
  echo "missing $TARPATH — run ./scripts/release-binary.sh $VERSION first" >&2
  exit 1
}
[ -f "$NOTES_FILE" ] || { echo "missing release notes: set RELEASE_NOTES to the reviewed file" >&2; exit 1; }
bun --no-env-file scripts/release-inputs.ts inspect "$BUILD_DIR" "$NOTES_FILE" >/dev/null
cmp "$TARPATH" "$BUILD_DIR/release/$TARBALL" || { echo "release archive differs from accepted preparation" >&2; exit 1; }
PREPARED_HEAD="$(bun --no-env-file -e 'console.log((await Bun.file(process.argv[1]+"/preparation.json").json()).sourceHead)' "$BUILD_DIR")"

SHA="$(shasum -a 256 "$TARPATH" | awk '{print $1}')"
URL="https://github.com/$REPO/releases/download/v$VERSION/$TARBALL"
echo "==> version $VERSION  sha $SHA"

# Preflight: the site deploys from origin/main on push, while these binaries
# are built from the LOCAL tree — releasing unpushed code splits the story.
# (Skip with RELEASE_SKIP_GIT_CHECK=1 for a re-run/hotfix of assets only.)
if [ "${RELEASE_SKIP_GIT_CHECK:-0}" != "1" ]; then
  if [ -n "$(git status --porcelain --untracked-files=all)" ]; then
    echo "working tree is dirty — commit (or stash) before releasing," >&2
    echo "or RELEASE_SKIP_GIT_CHECK=1 to override" >&2
    exit 1
  fi
  git fetch -q origin main
  if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
    echo "local HEAD != origin/main — run \`git push\` first (the site deploys" >&2
    echo "from the push; binaries must match), or RELEASE_SKIP_GIT_CHECK=1" >&2
    exit 1
  fi
  [ "$(git rev-parse HEAD)" = "$PREPARED_HEAD" ] || { echo "prepared source differs from origin/main" >&2; exit 1; }
fi
npm whoami >/dev/null
gh auth status >/dev/null

# --target creates a missing tag; an existing tag must identify these artifacts.
REMOTE_TAG="$(git ls-remote --tags "https://github.com/$REPO.git" "refs/tags/v$VERSION" "refs/tags/v$VERSION^{}")"
TAG_HEAD="$(printf '%s\n' "$REMOTE_TAG" | awk '$2 ~ /\^\{\}$/ {peeled=$1} $2 !~ /\^\{\}$/ {raw=$1} END {print peeled ? peeled : raw}')"
if [ -n "$TAG_HEAD" ] && [ "$TAG_HEAD" != "$PREPARED_HEAD" ]; then
  echo "existing release tag v$VERSION differs from prepared source" >&2
  exit 1
fi

# A versionless copy of the same tarball, so the direct-download one-liner
# can target a STABLE url: releases/latest/download/mlx-bun-<arch>.tar.gz
# (the versioned asset name changes every release and can't be used there).
LATEST="mlx-bun-${ARCH}.tar.gz"
cp -f "$TARPATH" "$OUT_DIR/$LATEST"
printf '%s  %s\n' "$SHA" "$TARBALL" > "$TARPATH.sha256"
printf '%s  %s\n' "$SHA" "$LATEST" > "$OUT_DIR/$LATEST.sha256"

# 1. GitHub release: create if absent, else clobber the assets in place.
if gh release view "v$VERSION" -R "$REPO" >/dev/null 2>&1; then
  echo "==> release v$VERSION exists; uploading assets (--clobber)"
  gh release upload "v$VERSION" "$TARPATH" "$OUT_DIR/$LATEST" "$TARPATH.sha256" "$OUT_DIR/$LATEST.sha256" -R "$REPO" --clobber
else
  echo "==> creating release v$VERSION"
  echo "    notes from $NOTES_FILE"
  gh release create "v$VERSION" "$TARPATH" "$OUT_DIR/$LATEST" "$TARPATH.sha256" "$OUT_DIR/$LATEST.sha256" -R "$REPO" \
    --title "mlx-bun v$VERSION" --notes-file "$NOTES_FILE" --target "$PREPARED_HEAD"
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

# The formula is generated from the accepted archive by prepare-homebrew.ts;
# no checked-in version/hash mirror needs another commit.
# 3. npm — same idempotent step, extended to the public workspace packages.
bun --no-env-file scripts/release-inputs.ts npm "$BUILD_DIR" "$NOTES_FILE"

echo
echo "==> done — all channels:"
echo "    GitHub release  https://github.com/$REPO/releases/tag/v$VERSION"
echo "    Homebrew tap    brew upgrade joshuarossi/tap/mlx-bun"
echo "    npm             mlx-bun@$VERSION"
echo "    site            deploys from the git push (GitHub Pages)"
