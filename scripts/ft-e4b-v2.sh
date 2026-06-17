#!/usr/bin/env bash
# Fine-tune e4b (gemma-4-e4b-it-OptiQ-4bit) on the lucien chunk-v2-500
# curated set (450 train convs, --best 500) via mlx-bun's segmented-backward
# LoRA trainer.
#
#   scripts/ft-e4b-v2.sh probe   # 2-iter memory/stability check (~1 min) — RUN THIS FIRST
#   scripts/ft-e4b-v2.sh train   # the real run (ITERS below)
#
# Override any knob inline, e.g.:  ITERS=750 SEQ=4096 SEG=1 scripts/ft-e4b-v2.sh train
#
# Required for e4b: segmented backward (fits memory) + fused kernels OFF (no vjp).
# Attention = flash attention via the DEFAULT ops.sdpa (mlx's fused flash kernel —
# this is what makes long-context training work, together with segmented backward).
# Do NOT set MLX_BUN_TRAIN_ATTN=flash: that selects a DIFFERENT, hand-rolled custom
# flash kernel (src/model/flash-attention.ts) which crashes on e4b at multi-K
# context (C++ exception/SIGTRAP on the first backward; see
# docs/design/segmented-backward-training.md §10). The default sdpa path is the
# validated e4b recipe (SEQ=2048 SEG=4 run, and the CPM5 95.10 run); segmented
# grads are ~bf16-class, fine for LoRA.
set -euo pipefail

MODE="${1:-probe}"

# --- resolve the e4b OptiQ snapshot dir (default HF cache path) ---
E4B_HUB="$HOME/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots"
if [[ ! -d "$E4B_HUB" ]]; then
  echo "ERROR: e4b model not found at $E4B_HUB" >&2
  exit 1
fi
# Pin the validated snapshot every other e4b script uses; fall back to whatever's there.
E4B_SNAP="fcdb12d740cd813634064567fc7cb51159b34253"
[[ -d "$E4B_HUB/$E4B_SNAP" ]] || E4B_SNAP="$(ls "$E4B_HUB" | head -n1)"
MODEL="${MODEL:-$E4B_HUB/$E4B_SNAP}"

# --- knobs (override via env) ---
DATA="${DATA:-/Users/joshrossi/Code/lucien/benchmark/finetune/chunk-v2-500}"
SEQ="${SEQ:-8192}"
SEG="${SEG:-4}"
RANK="${RANK:-16}"
SCALE="${SCALE:-20}"   # LoRA alpha
LR="${LR:-1e-5}"
ADAPTER="${ADAPTER:-$HOME/.cache/mlx-bun/mlx-bun-finetunes/e4b-chunk-v2}"

if [[ "$MODE" == "probe" ]]; then
  ITERS="${ITERS:-2}"
elif [[ "$MODE" == "train" ]]; then
  ITERS="${ITERS:-900}"   # ~2 epochs over 450 curated examples (batch_size=1)
else
  echo "usage: $0 [probe|train]" >&2
  exit 1
fi

echo "### mode=$MODE  model=e4b  seq=$SEQ seg=$SEG iters=$ITERS rank=$RANK scale=$SCALE lr=$LR"
echo "### data=$DATA"
echo "### adapter=$ADAPTER"

# Required env: PERF_KERNEL/FUSED_GELU off (no vjp). Attention left at the default
# ops.sdpa — mlx's FUSED flash-attention kernel (the right, working path). Do NOT
# set MLX_BUN_TRAIN_ATTN=flash: that is the hand-rolled custom kernel, which
# crashes on e4b at multi-K (see header note). sdpa is what the validated e4b run
# used.
MLX_BUN_PERF_KERNEL=0 \
MLX_BUN_FUSED_GELU=0 \
MODEL="$MODEL" \
DATA="$DATA" \
SEQ="$SEQ" \
SEG="$SEG" \
ITERS="$ITERS" \
RANK="$RANK" \
SCALE="$SCALE" \
LR="$LR" \
ADAPTER="$ADAPTER" \
  bun scripts/chunk-finetune.ts
