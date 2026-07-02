#!/usr/bin/env python
# Generate the mlx-lm DYNAMIC-B batched-decode ORACLE (rows join/leave
# mid-stream). Run with the oracle venv:
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-batched-dynamic-golden.py <model-dir>
#
# Companion to gen-batched-golden.py (which is STATIC-B: a fixed batch decoded
# to completion). This one drives mlx-lm's REAL continuous-batching cache ops —
# BatchKVCache.merge / .extract / .filter — through a controlled scenario where
# the batch membership changes between decode steps:
#
#   phase 1: {A, B}            merge two solo prefills            (B grows 0->2)
#   JOIN C:  re-merge          extract(A), extract(B) + prefill(C)
#   phase 2: {A, B, C}                                            (B grows 2->3)
#   LEAVE A: filter([1, 2])    evict the finished row            (B shrinks 3->2)
#   phase 3: {B, C}
#
# This is the gate's oracle for the dynamic-B cache ops the --batch N scheduler
# needs (docs/design/parallel-slots.md): mlx-bun's mergeKVRows / filterKVRows
# (src/model/batched-mask.ts) must drive a real batched decode whose per-row
# greedy trajectory matches mlx-lm's BatchKVCache here, token-for-token.
#
# The mlx-bun side (tests/batched-decode-parity.test.ts, realDynamicBatchedGreedy)
# executes the IDENTICAL protocol with our primitives. Greedy argmax, so the
# comparison is exact per-row token trajectories.
#
# The oracle is MACHINE-SPECIFIC (greedy argmax over bf16 batched logits flips
# per-GPU — see PLAN.md "machine-specific goldens"), so the committed golden is
# resolved via tests/goldens.ts: write <out> to
# goldens/batched-dynamic-golden-cpm.json on the reference box (apple-m4-pro),
# or goldens/<machine-key>/batched-dynamic-golden-cpm.json elsewhere.
import sys, json
from optiq.mlx_lm_patches._register import register
register()  # maps gemma4_unified -> mlx-lm gemma4 (harmless for MiniCPM5/llama)
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, BatchKVCache

MODEL = sys.argv[1] if len(sys.argv) > 1 else \
    "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78"
OUT = sys.argv[2] if len(sys.argv) > 2 else \
    "/tmp/batched-dynamic-golden-cpm.json"  # copy into the goldens layer (header)

# Scenario (must match realDynamicBatchedGreedy on the mlx-bun side). Prompt A
# is the longest so the initial merge gives it leftPad 0. C is the joiner.
A = [1, 100, 200, 300, 400, 500, 600]  # len 7
B = [1, 150, 250, 350, 450]            # len 5
C = [1, 130, 230, 330, 430, 530]       # len 6 (joins after phase 1)
PHASE1 = 3   # steps with {A, B}
PHASE2 = 3   # steps with {A, B, C}
PHASE3 = 3   # steps with {B, C}

model, _ = load(MODEL)
L = len(make_prompt_cache(model))  # number of layers (cache entries)


def prefill(prompt):
    """Solo (B=1) prefill -> per-layer KVCache list + the first greedy token."""
    c = make_prompt_cache(model)
    logits = model(mx.array([prompt]), cache=c)
    tok = int(mx.argmax(logits[0, -1]))
    return c, tok


def feed(batch, toks):
    """One batched decode step: feed [B,1], return per-row greedy tokens."""
    logits = model(mx.array(toks)[:, None], cache=batch)
    nxt = mx.argmax(logits[:, -1, :], axis=-1)
    mx.eval(nxt)
    return [int(x) for x in nxt]


# --- phase 1: {A, B} via merge of two solo prefills ---
cA, a = prefill(A)
cB, b = prefill(B)
batch = [BatchKVCache.merge([cA[i], cB[i]]) for i in range(L)]
trajA, trajB, trajC = [a], [b], []
for _ in range(PHASE1):
    a, b = feed(batch, [a, b])
    trajA.append(a); trajB.append(b)

# --- JOIN C: extract live rows + prefill C, re-merge to a 3-row batch ---
cC, c = prefill(C)
trajC.append(c)
batch = [BatchKVCache.merge([batch[i].extract(0), batch[i].extract(1), cC[i]])
         for i in range(L)]
for _ in range(PHASE2):
    a, b, c = feed(batch, [a, b, c])
    trajA.append(a); trajB.append(b); trajC.append(c)

# --- LEAVE A: filter the batch down to {B, C} (rows 1, 2) ---
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
    },
    # Per-row greedy trajectories (the cross-stack ground truth).
    # A: prefill + phase1 + phase2 = 1+3+3 = 7 tokens, then A leaves.
    # B: prefill + phase1+phase2+phase3 = 1+3+3+3 = 10 tokens.
    # C: prefill + phase2 + phase3 = 1+3+3 = 7 tokens.
    "trajectories": {"A": trajA, "B": trajB, "C": trajC},
}
with open(OUT, "w") as f:
    json.dump(manifest, f, indent=2)

print("mlx-lm dynamic-B greedy trajectories (the oracle):")
print(f"  A (joins t=0, leaves t={PHASE1 + PHASE2}): {trajA}")
print(f"  B (whole run):                              {trajB}")
print(f"  C (joins t={PHASE1}):                        {trajC}")
print(f"saved -> {OUT}")
