#!/bin/sh
# fetch-test-fixtures.sh — download the untracked binary test fixtures
# (CONTRIBUTING.md B2) and verify their pinned SHA-256s.
#
# The gated suites skip cleanly when these files are absent, so this is
# only needed to RUN those suites on a machine that doesn't already have
# the fixtures (both dev laptops do — untracking never deleted anything).
#
# Source of truth for the bytes, in order of preference:
#   1. the `test-fixtures-v1` GitHub release on joshuarossi/mlx-bun
#      (create it once from a machine that has the files:
#        gh release create test-fixtures-v1 --prerelease \
#          --title "test fixtures v1 (not a software release)" \
#          --notes "binary test fixtures kept out of git history" \
#          upper-adapters.safetensors french-adapters.safetensors )
#   2. any dev machine's working tree (scp the two files)
#   3. retrain from the tracked recipe (fixtures/adapters/adapter_config.json
#      + data-upper/ + data-french/) — bit-exactness of a retrain is
#      UNVERIFIED (trainer-of-record ambiguity), which is exactly why the
#      original bytes are pinned by hash below.
set -eu

REPO="${REPO:-joshuarossi/mlx-bun}"
TAG="test-fixtures-v1"
cd "$(dirname "$0")/.."

# fixture -> destination + pinned sha256 (the 2026-06-10 originals)
fetch() { # $1 asset name, $2 dest path, $3 sha256
  if [ -f "$2" ]; then
    echo "exists   $2"
  else
    echo "fetching $2 from release $TAG"
    gh release download "$TAG" --repo "$REPO" --pattern "$1" --output "$2"
  fi
  got="$(shasum -a 256 "$2" | awk '{print $1}')"
  [ "$got" = "$3" ] || { echo "SHA MISMATCH for $2: got $got want $3" >&2; exit 1; }
  echo "verified $2"
}

fetch upper-adapters.safetensors fixtures/adapters/upper/adapters.safetensors \
  94f83569ba85df9e05557238809101cd19f9eabd0149c7931904e2a58774a05b
fetch french-adapters.safetensors fixtures/adapters/french/adapters.safetensors \
  bbd75bffe591f88dadf5af26aebcd5d6c3f629dafa403714f31524a6e3180dc9

echo "done — MLX_BUN_TEST_LORA=1 suites are runnable."
