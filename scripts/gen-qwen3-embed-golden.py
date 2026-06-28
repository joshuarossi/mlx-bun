#!/usr/bin/env python3
# Generate Qwen3-Embedding parity goldens from the mlx-lm reference (the L1
# oracle). Companion to tests/qwen3-embed-parity.test.ts — the mlx-bun side runs
# the SAME token ids through its Qwen3Model and compares hidden states + the
# pooled embedding.
#
# Run on a machine with the oracle venv (mlx 0.31.2 / mlx-lm 0.31.3):
#   ../mlx-lm/.venv/bin/python scripts/gen-qwen3-embed-golden.py [MODEL_DIR]
#
# Writes goldens/qwen3-embed/{meta.json, hidden.bin, pooled.bin}. The ids live in
# meta.json so the TS test uses byte-identical input (no tokenizer in the test).

import glob
import json
import os
import sys

import mlx.core as mx
import numpy as np
from mlx_lm import load


def resolve_model() -> str:
    if len(sys.argv) > 1:
        return sys.argv[1]
    hub = os.path.expanduser("~/.cache/huggingface/hub")
    hits = glob.glob(
        os.path.join(hub, "models--mlx-community--Qwen3-Embedding-*", "snapshots", "*", "config.json")
    )
    if not hits:
        raise SystemExit("no Qwen3-Embedding snapshot in HF cache; pass MODEL_DIR")
    return os.path.dirname(hits[0])


MODEL = resolve_model()
OUTDIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "goldens", "qwen3-embed")
os.makedirs(OUTDIR, exist_ok=True)

print(f"[gen-qwen3-embed-golden] model: {MODEL}")
model, tok = load(MODEL)

# A representative sentence + the <|endoftext|> pooling token Qwen3-Embedding
# terminates inputs with. Encode WITHOUT extra specials (Qwen3 has no BOS).
TEXT = "The cat sat on the warm windowsill in the afternoon sun."
EOD = 151643  # <|endoftext|>
ids = list(tok.encode(TEXT, add_special_tokens=False)) + [EOD]
print(f"[gen-qwen3-embed-golden] {len(ids)} ids: {ids}")

arr = mx.array([ids])
hidden = model.model(arr)  # post-final-norm hidden [1, L, H]
mx.eval(hidden)
_, L, H = hidden.shape

pooled = hidden[:, -1, :]  # last-token pooling
norm = pooled / mx.sqrt((pooled * pooled).sum(axis=-1, keepdims=True))
mx.eval(norm)

np.array(hidden.astype(mx.float32)).reshape(-1).astype(np.float32).tofile(os.path.join(OUTDIR, "hidden.bin"))
np.array(norm.astype(mx.float32)).reshape(-1).astype(np.float32).tofile(os.path.join(OUTDIR, "pooled.bin"))
with open(os.path.join(OUTDIR, "meta.json"), "w") as f:
    json.dump({"ids": ids, "seqLen": L, "hidden": H, "text": TEXT, "eod": EOD}, f, indent=1)

print(f"[gen-qwen3-embed-golden] wrote hidden [{L},{H}] + pooled [{H}] to {OUTDIR}")
