#!/usr/bin/env python
"""Golden generator for the Qwen3.5 gated-DeltaNet recurrence (model-free).

Runs mlx-lm's `gated_delta_update` (the GPU-kernel path, use_kernel=True) on
small random inputs at the REAL Qwen3.6-27B head geometry, chained across a
prefill step (T=3, state=None) and a decode step (T=1, state=state1). Dumps the
inputs + the y outputs so tests/qwen-delta.test.ts can assert our port is
BIT-EXACT with the reference kernel without loading the 15 GB model.

Run with the oracle venv:
  /Users/joshrossi/Code/mlx-lm-example/.venv/bin/python scripts/gen-qwen-delta-golden.py
"""

import json
import os

import mlx.core as mx
from mlx_lm.models.gated_delta import gated_delta_update

# Real Qwen3.6-27B linear-attn geometry.
B = 1
HK = 16          # linear_num_key_heads
HV = 48          # linear_num_value_heads
DK = 128         # linear_key_head_dim
DV = 128         # linear_value_head_dim

mx.random.seed(20260615)


def randn(shape, dtype=mx.bfloat16):
    return mx.random.normal(shape).astype(dtype)


def as_list(a):
    return [float(x) for x in mx.array(a).astype(mx.float32).reshape(-1).tolist()]


def step(T, state):
    # Inputs mirror GatedDeltaNet just before gated_delta_update: q,k normalized
    # to ~unit scale, v small, a/b arbitrary. Exact dtypes match the model
    # (q,k,v,a,b bf16; A_log,dt_bias bf16; state f32).
    q = randn((B, T, HK, DK))
    k = randn((B, T, HK, DK))
    v = randn((B, T, HV, DV))
    a = randn((B, T, HV))
    b = randn((B, T, HV))
    inv = DK ** -0.5
    q = (inv * inv) * mx.fast.rms_norm(q, None, 1e-6)
    k = inv * mx.fast.rms_norm(k, None, 1e-6)
    y, new_state = gated_delta_update(
        q, k, v, a, b, A_log, dt_bias, state, None, use_kernel=True
    )
    mx.eval(y, new_state)
    rec = {
        "T": T,
        "q": as_list(q), "k": as_list(k), "v": as_list(v),
        "a": as_list(a), "b": as_list(b),
        "y": as_list(y),
        "y_shape": list(y.shape),
    }
    return rec, new_state


A_log = mx.log(mx.random.uniform(low=0.5, high=8.0, shape=(HV,))).astype(mx.bfloat16)
dt_bias = randn((HV,))

s1_rec, s1 = step(3, None)
s2_rec, _ = step(1, s1)

out = {
    "B": B, "HK": HK, "HV": HV, "DK": DK, "DV": DV,
    "A_log": as_list(A_log), "dt_bias": as_list(dt_bias),
    "prefill": s1_rec,
    "decode": s2_rec,
}

dest = os.path.join(os.path.dirname(__file__), "..", "tests", "fixtures", "qwen-delta-golden.json")
with open(dest, "w") as f:
    json.dump(out, f)
print("wrote", os.path.normpath(dest))
print("prefill y shape", s1_rec["y_shape"], "decode y shape", s2_rec["y_shape"])
