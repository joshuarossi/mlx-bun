#!/usr/bin/env bash
# Install the numerical reference outside the checkout. stdout is shell setup;
# progress goes to stderr. Evaluate stdout only after a successful exit.
set -euo pipefail

if [[ "${1:-}" == --help ]]; then
  echo 'Usage: bash scripts/oracle/setup.sh [venv-directory]'
  echo 'Requires uv. Installs Python 3.13.5 and the committed reference lock.'
  echo 'Prints an export for MLX_BUN_ORACLE_VENV. No models or GPU work.'
  exit 0
fi
if [[ $# -gt 1 ]]; then echo 'Expected at most one venv-directory.' >&2; exit 2; fi
if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
  echo 'The Metal parity oracle requires an Apple Silicon Mac.' >&2
  exit 1
fi
if ! command -v uv >/dev/null 2>&1; then
  echo 'Install uv first: brew install uv' >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
oracle_dir="${1:-${MLX_BUN_ORACLE_VENV:-$HOME/.cache/mlx-bun/oracle-mlx-0.32.2-py3.13.5}}"
if [[ ! -e "$oracle_dir" ]]; then
  uv venv --python 3.13.5 "$oracle_dir" >&2
elif [[ ! -f "$oracle_dir/pyvenv.cfg" ]]; then
  echo "Not a Python venv: $oracle_dir. Choose a new directory." >&2
  exit 1
fi
oracle_dir="$(cd -- "$oracle_dir" && pwd)"
"$oracle_dir/bin/python" -c 'import sys; assert sys.version_info[:3] == (3, 13, 5), "Expected Python 3.13.5; choose a new venv directory"'
uv pip sync --python "$oracle_dir/bin/python" "$script_dir/requirements.lock" >&2
uv pip check --python "$oracle_dir/bin/python" >&2
"$oracle_dir/bin/python" - "$script_dir/requirements.lock" >&2 <<'PY'
import importlib.metadata as metadata
import json
import pathlib
import sys

for line in pathlib.Path(sys.argv[1]).read_text().splitlines():
    if not line or line.startswith('#'):
        continue
    if ' @ ' in line:
        name, url = line.split(' --hash=', 1)[0].split(' @ ', 1)
        direct = json.loads(metadata.distribution(name).read_text('direct_url.json'))
        assert direct['url'] == url.split('#')[0], f'{name}: wrong wheel URL'
        # uv verifies the wheel hash from the lock during installation.
        assert metadata.version(name) == '0.32.2', f'{name}: wrong version'
    else:
        name, expected = line.split('==')
        assert metadata.version(name) == expected, f'{name}: expected {expected}'
print('Reference lock verified. Python', sys.version.split()[0])
PY
printf 'export MLX_BUN_ORACLE_VENV=%q\n' "$oracle_dir"
