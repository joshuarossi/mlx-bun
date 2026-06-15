#!/usr/bin/env python
# Model-FREE oracle for the batched sliding-window (rotating) KV cache. Drives
# mlx-lm's BatchRotatingKVCache (the reference) through the exact sequence our
# scheduler does — solo-prefill each row, merge, then N=1 decode steps that
# force the ring to WRAP — and dumps, per step:
#   - make_mask(1)            the per-row causal+window+padding+ROLL mask
#   - per-row extracted keys  (temporal order, padding stripped) = storage check
# tests/batched-rotating.test.ts replays the identical sequence through our
# BatchedRotatingCache (src/model/batched-rotating.ts) and asserts both match.
#
# Tagged keys (H=D=1): row b's t-th written key = (b+1)*1000 + t, so the
# extracted temporal sequence is human-readable and reveals any mis-rotation.
# Tiny window (max_size) so the wrap happens after a few steps. Pure cache math,
# no model — run with the oracle venv (has mlx_lm):
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-rotating-golden.py
import json
import mlx.core as mx
from mlx_lm.models.cache import RotatingKVCache, BatchRotatingKVCache

W = 6              # max_size (window) — tiny so the ring wraps quickly
PREFILL = [4, 2]   # per-row solo prefill lengths (row0 longest → leftPad 0)
STEPS = 8          # decode steps (enough to fill 4->6 then wrap)
B = len(PREFILL)
OUT = "tests/fixtures/batched-rotating-golden.json"


def tagged(vals):
    return mx.array(vals, dtype=mx.float32).reshape(1, 1, len(vals), 1)


# Per-row running counter of written keys (1-based temporal index).
counters = [0] * B


def next_key(b, n):
    vals = []
    for _ in range(n):
        counters[b] += 1
        vals.append((b + 1) * 1000 + counters[b])
    return vals


# Solo prefill each row, then merge into the batched rotating cache.
solos = []
for b, L in enumerate(PREFILL):
    c = RotatingKVCache(max_size=W)
    k = tagged(next_key(b, L))
    c.update_and_fetch(k, k)
    solos.append(c)
cache = BatchRotatingKVCache.merge(solos)


def mask_now():
    m = cache.make_mask(1)  # [B,1,1,S] bool (broadcast over rows)
    m = mx.broadcast_to(m, (B, 1, 1, m.shape[-1]))
    return m.astype(mx.int32).tolist()


def extracted():
    # Per-row real keys in temporal order, padding stripped (the storage truth).
    out = []
    for b in range(B):
        kc = cache.extract(b)  # RotatingKVCache, temporal + padding-stripped
        out.append([int(x) for x in kc.keys.reshape(-1).tolist()])
    return out


steps = []
for s in range(STEPS):
    mask = mask_now()  # BEFORE the write (matches how the model masks this step)
    k = mx.concatenate([tagged(next_key(b, 1)) for b in range(B)], axis=0)  # [B,1,1,1]
    cache.update_and_fetch(k, k)
    steps.append({"mask": mask, "extracted": extracted()})

manifest = {
    "max_size": W, "prefill": PREFILL, "steps": STEPS, "B": B,
    # The exact key VALUES our test must feed (so storage is comparable).
    "prefill_keys": [[(b + 1) * 1000 + (p + 1) for p in range(L)] for b, L in enumerate(PREFILL)],
    "decode_keys": [[(b + 1) * 1000 + (PREFILL[b] + s + 1) for s in range(STEPS)] for b in range(B)],
    "per_step": steps,
}
with open(OUT, "w") as f:
    json.dump(manifest, f, indent=2)
print(f"saved -> {OUT}  (W={W} prefill={PREFILL} steps={STEPS})")
for s, st in enumerate(steps):
    print(f"  step {s}: mask_S={len(st['mask'][0][0][0])} extracted={st['extracted']}")
