#!/bin/sh
# history-rewrite.sh — CONTRIBUTING.md Phase C as ONE guarded command.
#
# Purges the historical golden/adapter binary blobs from git history
# (~179 MB -> expect a <30 MB fresh clone). DESTRUCTIVE BY DESIGN: rewrites
# every commit hash and force-pushes main. Run it ON ONE MACHINE ONLY;
# every other clone (the other laptop!) must re-clone afterwards.
#
#   Dry run (default):   ./scripts/history-rewrite.sh
#   The real thing:      MLX_BUN_REWRITE_GO=1 ./scripts/history-rewrite.sh
#
# Preconditions enforced below: git-filter-repo installed, clean tree,
# HEAD == origin/main, and a fresh mirror backup tarball written OUTSIDE
# the repo (~/mlx-bun-history-backup-<date>.tar) before anything rewrites.
# The backup preserves the pre-rewrite history PERMANENTLY, including every
# blob being purged — nothing is lost even in the worst case.
set -eu

cd "$(dirname "$0")/.."
command -v git-filter-repo >/dev/null 2>&1 || {
  echo "git-filter-repo not installed:  brew install git-filter-repo" >&2; exit 1; }

git diff --quiet && git diff --cached --quiet || { echo "working tree dirty — commit first" >&2; exit 1; }
git fetch -q origin main
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || {
  echo "HEAD != origin/main — push first (and confirm the OTHER laptop is pushed too)" >&2; exit 1; }

STAMP="$(date +%F)"
BACKUP="$HOME/mlx-bun-history-backup-$STAMP.tar"

echo "==> analysis (what the rewrite would purge):"
git filter-repo --analyze --force
sed -n '1,15p' .git/filter-repo/analysis/blob-shas-and-paths.txt 2>/dev/null || true
echo "    full report: .git/filter-repo/analysis/"

if [ "${MLX_BUN_REWRITE_GO:-0}" != "1" ]; then
  cat <<EOF

DRY RUN ONLY — nothing rewritten. To execute:
  1. Confirm the OTHER laptop has pushed everything (git log origin/main..HEAD empty there).
  2. MLX_BUN_REWRITE_GO=1 ./scripts/history-rewrite.sh
  3. Afterwards, on EVERY other machine:  mv mlx-bun mlx-bun.old && git clone git@github.com:joshuarossi/mlx-bun.git
     (untracked local assets — goldens/*.bin, adapters/, runs/ — copy over from mlx-bun.old)
EOF
  exit 0
fi

echo "==> mirror backup -> $BACKUP"
TMP="$(mktemp -d)"
git clone -q --mirror . "$TMP/mlx-bun-mirror.git"
tar -cf "$BACKUP" -C "$TMP" mlx-bun-mirror.git
rm -rf "$TMP"
[ -s "$BACKUP" ] || { echo "backup failed" >&2; exit 1; }

echo "==> rewriting: purge historical goldens/**.bin + fixtures adapter safetensors"
ORIGIN_URL="$(git remote get-url origin)"
git filter-repo --force \
  --path-glob 'goldens/*.bin' --path-glob 'goldens/*/*.bin' --path-glob 'goldens/*/*/*.bin' \
  --path-glob 'fixtures/adapters/*/adapters.safetensors' \
  --invert-paths

echo "==> force-pushing rewritten main + tags"
git remote add origin "$ORIGIN_URL" 2>/dev/null || git remote set-url origin "$ORIGIN_URL"
git push --force origin main
git push --force origin --tags

echo "==> local repack"
git reflog expire --expire=now --all
git gc --prune=now --aggressive
du -sh .git

cat <<EOF
==> DONE. Now:
  - other laptop: re-clone (see header), copy untracked assets from the old checkout
  - verify: bash scripts/test.sh && bun scripts/check-hygiene.ts
  - keep $BACKUP until both machines are green
EOF
