#!/usr/bin/env python
# Generate the mlx-lm EXTEND-JOIN batched-decode oracle. Run with the venv:
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-batched-extend-golden.py <model-dir> <out.json>
#
# Same scenario as gen-batched-dynamic-golden.py (phase1 {A,B} → C joins →
# phase2 {A,B,C} → A leaves → phase3 {B,C}), but the JOIN uses mlx-lm's
# `BatchKVCache.extend` (append the new row to the running buffer, existing
# rows untouched, pads grow) instead of extract-every-row + re-merge. This is
# the oracle for mlx-bun's extend-join (extendKVRows in
# src/model/batched-mask.ts, driven by #mergeJoiner under
# MLX_BUN_BATCH_EXTEND!=0): per-row greedy trajectories must match
# token-for-token. The layouts differ from the re-merge protocol (pads never
# shrink under extend), so this golden is NOT interchangeable with
# batched-dynamic-golden-*.json — each protocol has its own oracle.
#
# Machine-specific like every logit golden — resolve via tests/goldens.ts.
import sys, json
from optiq.mlx_lm_patches._register import register
register()
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, BatchKVCache

MODEL = sys.argv[1]
OUT = sys.argv[2]

A = [1, 100, 200, 300, 400, 500, 600]  # len 7
B = [1, 150, 250, 350, 450]            # len 5
C = [1, 130, 230, 330, 430, 530]       # len 6 (joins after phase 1)
PHASE1 = 3
PHASE2 = 3
PHASE3 = 3

model, _ = load(MODEL)
L = len(make_prompt_cache(model))


def prefill(prompt):
    c = make_prompt_cache(model)
    logits = model(mx.array([prompt]), cache=c)
    tok = int(mx.argmax(logits[0, -1]))
    return c, tok


def feed(batch, toks):
    logits = model(mx.array(toks)[:, None], cache=batch)
    nxt = mx.argmax(logits[:, -1, :], axis=-1)
    mx.eval(nxt)
    return [int(x) for x in nxt]


# phase 1: {A, B}
cA, a = prefill(A)
cB, b = prefill(B)
batch = [BatchKVCache.merge([cA[i], cB[i]]) for i in range(L)]
trajA, trajB, trajC = [a], [b], []
for _ in range(PHASE1):
    a, b = feed(batch, [a, b])
    trajA.append(a); trajB.append(b)

# JOIN C via EXTEND: running rows stay in place, C appends.
cC, c = prefill(C)
trajC.append(c)
for i in range(L):
    batch[i].extend(BatchKVCache.merge([cC[i]]))
for _ in range(PHASE2):
    a, b, c = feed(batch, [a, b, c])
    trajA.append(a); trajB.append(b); trajC.append(c)

# LEAVE A
for i in range(L):
    batch[i].filter([1, 2])
for _ in range(PHASE3):
    b, c = feed(batch, [b, c])
    trajB.append(b); trajC.append(c)

manifest = {
    "model": MODEL,
    "scenario": {
        "A": A, "B": B, "C": C,
        "phase1": PHASE1, "phase2": PHASE2, "phase3": PHASE3,
        "join_after": PHASE1, "leave_after": PHASE1 + PHASE2, "leave_row": 0,
        "join_op": "extend",
    },
    "trajectories": {"A": trajA, "B": trajB, "C": trajC},
}
with open(OUT, "w") as f:
    json.dump(manifest, f, indent=2)

print("mlx-lm EXTEND-join greedy trajectories (the oracle):")
print(f"  A: {trajA}")
print(f"  B: {trajB}")
print(f"  C: {trajC}")
print(f"saved -> {OUT}")
