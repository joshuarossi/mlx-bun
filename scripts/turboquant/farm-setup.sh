#!/bin/bash
# One-shot setup: fresh rented Apple-silicon macOS box → benchmark-farm worker.
# Usage (from the orchestrating machine):
#   scp this script over, then:
#   ssh <box> 'HF_TOKEN=hf_xxx FARM_MODEL=mjriii/Qwen3.8-27B bash farm-setup.sh'
# Idempotent; safe to re-run. Versions pinned to the campaign oracle
# (mlx 0.31.2 / mlx-lm 0.31.3 — must match the laptop runs for score merging).
set -euo pipefail

echo "== bun"
command -v ~/.bun/bin/bun >/dev/null || curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"

echo "== repo"
if [ -d ~/Code/mlx-bun/.git ]; then
  git -C ~/Code/mlx-bun fetch -q origin && git -C ~/Code/mlx-bun checkout -q feature/turboquant-weights && git -C ~/Code/mlx-bun pull --ff-only -q
else
  mkdir -p ~/Code && git clone -q --branch feature/turboquant-weights https://github.com/joshuarossi/mlx-bun ~/Code/mlx-bun
fi
cd ~/Code/mlx-bun && ~/.bun/bin/bun install --silent

echo "== oracle venv (pinned)"
[ -d ~/mlx-lm-venv ] || python3 -m venv ~/mlx-lm-venv
~/mlx-lm-venv/bin/pip -q install "mlx==0.31.2" "mlx-lm==0.31.3" huggingface_hub

echo "== hf auth + model"
export HF_HUB_DISABLE_XET=1
if [ -n "${HF_TOKEN:-}" ]; then
  ~/mlx-lm-venv/bin/python -c "from huggingface_hub import login; login(token='$HF_TOKEN', add_to_git_credential=False)"
fi
if [ -n "${FARM_MODEL:-}" ]; then
  ~/mlx-lm-venv/bin/python -c "from huggingface_hub import snapshot_download; print(snapshot_download('$FARM_MODEL'))"
fi

echo "== stay awake"
pgrep -x caffeinate >/dev/null || (nohup caffeinate -is >/dev/null 2>&1 &)

mkdir -p ~/Code/mlx-bun/runs/tq-qwen
echo "farm worker ready: $(hostname) · $(sysctl -n machdep.cpu.brand_string) · $(($(sysctl -n hw.memsize)/1073741824))GB"
