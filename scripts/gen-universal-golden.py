# Universal-parity golden generator — runs INSIDE the oracle venv
# (/Users/joshrossi/Code/mlx-lm/.venv/bin/python; resolved by
# scripts/regen-universal-goldens.ts via tests/paths.ts ORACLE_PYTHON).
#
#   python scripts/gen-universal-golden.py <snapshot> <prompt> <steps> <outdir> <prefix> <repo_id>
#
# Emits, for the bf16-KV L1 bar (vs stock mlx-lm):
#   <outdir>/<prefix>-parity.json          prompt ids + greedy ids + versions
#   <outdir>/<prefix>-logits-step<k>.bin   raw f32 last-position logits per step
#
# Explicit token ids only (no cross-stack tokenizer dependency at test
# time). Logit goldens are bit-exact ONLY on the GPU that produced them —
# run this on the same machine the parity test runs on (the .ts wrapper
# routes output through tests/goldens.ts goldenOutDir()).

import json
import platform
import sys

import mlx.core as mx
import mlx_lm
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache

snap, prompt, steps, outdir, prefix, repo_id = (
    sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4], sys.argv[5], sys.argv[6],
)

model, tokenizer = load(snap)
ids = tokenizer.encode(prompt)
cache = make_prompt_cache(model)

greedy = []
y = mx.array([ids])
for step in range(steps):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    with open(f"{outdir}/{prefix}-logits-step{step}.bin", "wb") as f:
        f.write(bytes(memoryview(last)))
    tok = mx.argmax(last).item()
    greedy.append(tok)
    y = mx.array([[tok]])

print(json.dumps({
    "model": repo_id,
    "snapshot": snap,
    "model_type": model.model_type,
    "mode": "bf16",
    "prompt": prompt,
    "prompt_ids": ids,
    "greedy_ids": greedy,
    "logit_steps": steps,
    "vocab_size": int(last.shape[0]),
    "oracle": {
        "mlx": mx.__version__,
        "mlx_lm": mlx_lm.__version__,
        "machine": platform.machine(),
    },
}))
