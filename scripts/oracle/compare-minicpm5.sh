#!/usr/bin/env bash
# Generate fresh local reference logits, then run the engine's exact test.
set -euo pipefail
download=0
case "${1:-}" in
  --download) download=1 ;;
  --help)
    echo 'Usage: bash scripts/oracle/compare-minicpm5.sh [--download]'
    echo 'Set MLX_BUN_ORACLE_VENV using setup.sh first. Requires Bun 1.4.2+.'
    echo '--download allows fetching the pinned MiniCPM5 snapshot if absent.'
    echo 'MLX_BUN_TEST_MINICPM5 optionally selects an existing model directory.'
    exit 0 ;;
  '') ;;
  *) echo "Unknown argument: $1" >&2; exit 2 ;;
esac
if [[ $# -gt 1 ]]; then echo 'Too many arguments.' >&2; exit 2; fi
if [[ -z "${MLX_BUN_ORACLE_VENV:-}" || ! -x "$MLX_BUN_ORACLE_VENV/bin/python" ]]; then
  echo 'Run bash scripts/oracle/setup.sh first, then use its printed export.' >&2
  exit 1
fi
command -v bun >/dev/null 2>&1 || { echo 'Install Bun 1.4.2 or newer first.' >&2; exit 1; }
repo_dir="$(cd -- "$(dirname -- "$0")/../.." && pwd)"
cd "$repo_dir"
start=$SECONDS
if [[ -z "${MLX_BUN_TEST_MINICPM5:-}" ]]; then
  MLX_BUN_TEST_MINICPM5="$("$MLX_BUN_ORACLE_VENV/bin/python" - "$download" <<'PY'
import sys
from huggingface_hub import snapshot_download
try:
    print(snapshot_download(
        'mlx-community/MiniCPM5-1B-OptiQ-4bit',
        revision='664aabaed233c653f82716d8dc822234d0091f78',
        local_files_only=sys.argv[1] != '1',
    ))
except Exception as error:
    raise SystemExit(f'MiniCPM5 snapshot unavailable: {error}\nRun again with --download to fetch the pinned artifact.')
PY
)"
fi
export MLX_BUN_TEST_MINICPM5
# A fresh directory prevents old or other-machine fixtures from passing.
mkdir -p "$HOME/.cache/mlx-bun/comparisons"
MLX_BUN_GOLDEN_DIR="$(mktemp -d "$HOME/.cache/mlx-bun/comparisons/minicpm5.XXXXXX")"
export MLX_BUN_GOLDEN_DIR
printf 'Model: %s\nFresh fixtures: %s\n' "$MLX_BUN_TEST_MINICPM5" "$MLX_BUN_GOLDEN_DIR"
bun scripts/regen/minicpm5.ts
bun test tests/parity/minicpm5-parity.test.ts
printf 'MiniCPM5 comparison passed in %s seconds. Fixtures: %s\n' "$((SECONDS - start))" "$MLX_BUN_GOLDEN_DIR"
