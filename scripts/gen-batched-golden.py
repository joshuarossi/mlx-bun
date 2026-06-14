#!/usr/bin/env python
# Generate the mlx-lm B=2 batched-decode ORACLE for batched-serving parity.
# Run with the oracle venv:
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-batched-golden.py <model-dir>
#
# Drives mlx-lm's REAL batched path: left-padded prompts → BatchKVCache →
# batch-prefill → greedy batch-decode. Prints each row's greedy token
# trajectory (the cross-stack ground truth) and saves last-position logits per
# step to <out>.f32 + a JSON manifest, for bit-exact comparison from mlx-bun.
#
# This is the L1-batched gate's oracle: mlx-bun B=2 must match mlx-lm B=2.
import sys, json, struct
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import BatchKVCache, BatchRotatingKVCache

MODEL = sys.argv[1] if len(sys.argv) > 1 else \
    "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78"
OUT = sys.argv[2] if len(sys.argv) > 2 else "/tmp/batched-golden"
STEPS = 8

# Same prompts as tests/batched-decode-parity.test.ts (prompts[0] longest).
PROMPTS = [
    [1, 100, 200, 300, 400, 500, 600],  # len 7
    [1, 150, 250, 350, 450],            # len 5
]

model, _ = load(MODEL)

Lmax = max(len(p) for p in PROMPTS)
left_padding = [Lmax - len(p) for p in PROMPTS]
padded = [[0] * (Lmax - len(p)) + p for p in PROMPTS]  # LEFT-pad with 0

# Build the per-layer batch cache exactly like mlx-lm's _make_cache. Sliding
# layers (if any) need BatchRotatingKVCache; full-attention layers BatchKVCache.
def make_cache():
    caches = []
    for layer in model.layers:
        attn = getattr(layer, "self_attn", None)
        max_size = None
        # mlx-lm marks sliding layers via a per-layer attribute on some models;
        # MiniCPM5 (llama) has none → all BatchKVCache.
        if hasattr(attn, "max_size") and attn.max_size:
            max_size = attn.max_size
        caches.append(
            BatchRotatingKVCache(max_size, left_padding) if max_size else BatchKVCache(left_padding)
        )
    return caches

cache = make_cache()

def last_logits(logits):
    # logits [B, L, V]; left-padded → last position is the real last token.
    return logits[:, -1, :]

# Prefill the left-padded batch in one forward.
logits = model(mx.array(padded), cache=cache)
ll = last_logits(logits)
mx.eval(ll)

trajectories = [[] for _ in PROMPTS]
step_logits = []  # per step: [B, V] f32
toks = mx.argmax(ll, axis=-1)  # [B]
for s in range(STEPS):
    step_logits.append(ll.astype(mx.float32))
    tlist = toks.tolist()
    for b in range(len(PROMPTS)):
        trajectories[b].append(int(tlist[b]))
    logits = model(toks[:, None], cache=cache)  # feed [B,1]
    ll = last_logits(logits)
    mx.eval(ll)
    toks = mx.argmax(ll, axis=-1)

# Save: per-step last-position logits as f32 [STEPS, B, V] + JSON manifest.
stacked = mx.stack(step_logits, axis=0)  # [STEPS, B, V]
mx.eval(stacked)
B, V = len(PROMPTS), stacked.shape[-1]
flat = stacked.reshape(-1).tolist()
with open(OUT + ".f32", "wb") as f:
    f.write(struct.pack(f"<{len(flat)}f", *flat))
manifest = {
    "model": MODEL, "prompts": PROMPTS, "left_padding": left_padding,
    "steps": STEPS, "B": B, "V": V, "trajectories": trajectories,
    "logits_file": OUT + ".f32", "logits_shape": [STEPS, B, V],
}
with open(OUT + ".json", "w") as f:
    json.dump(manifest, f, indent=2)

print("mlx-lm B=2 greedy trajectories (the oracle):")
for b, t in enumerate(trajectories):
    print(f"  row{b} (left_pad={left_padding[b]}): {t}")
print(f"saved logits -> {OUT}.f32  manifest -> {OUT}.json  [STEPS={STEPS} B={B} V={V}]")
