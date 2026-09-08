#!/usr/bin/env python
"""Golden generator for the Qwen3.5 gated-DeltaNet recurrence (model-free).

Runs mlx-lm's `gated_delta_update` (the GPU-kernel path, use_kernel=True) on
small random inputs at the REAL Qwen3.6-27B head geometry, chained across a
prefill step (T=3, state=None) and a decode step (T=1, state=state1). Dumps the
inputs + the y outputs so tests/unit/qwen-delta.test.ts can assert our port is
BIT-EXACT with the reference kernel without loading the 15 GB model.

Run with the oracle venv:
  /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/oracle/gen-qwen-delta-golden.py

Use --replay tests/fixtures/qwen-delta-golden.json to keep the existing
inputs and regenerate only the oracle outputs. --output selects a review
file; the default writes the reference fixture on M4 Pro and a per-chip
goldens/ override elsewhere. Regeneration is never part of a test run.
"""

import argparse
import hashlib
import importlib.metadata
import json
from pathlib import Path
import platform
import re
import subprocess
from datetime import datetime, timezone

import mlx.core as mx
import mlx_lm.models.gated_delta as gated_delta_module
from mlx_lm.models.gated_delta import gated_delta_update

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--replay", type=Path, help="Reuse an existing fixture's input values")
parser.add_argument("--output", type=Path, help="Explicit output path")
args = parser.parse_args()
repo = Path(__file__).resolve().parents[2]
brand = subprocess.check_output(["sysctl", "-n", "machdep.cpu.brand_string"], text=True).strip()
machine = re.sub(r"[^a-z0-9]+", "-", brand.lower()).strip("-")
default_output = (repo / "tests/fixtures/qwen-delta-golden.json" if machine == "apple-m4-pro"
                  else repo / "goldens" / machine / "qwen-delta-golden.json")
dest = args.output or default_output
replay_bytes = args.replay.read_bytes() if args.replay else None
replay = json.loads(replay_bytes) if replay_bytes else None

# Real Qwen3.6-27B linear-attn geometry.
B = 1
HK = 16          # linear_num_key_heads
HV = 48          # linear_num_value_heads
DK = 128         # linear_key_head_dim
DV = 128         # linear_value_head_dim
if replay:
    B, HK, HV, DK, DV = (replay[k] for k in ("B", "HK", "HV", "DK", "DV"))

mx.random.seed(20260615)


def randn(shape, dtype=mx.bfloat16):
    return mx.random.normal(shape).astype(dtype)


def as_list(a):
    return [float(x) for x in mx.array(a).astype(mx.float32).reshape(-1).tolist()]


def from_list(values, shape):
    return mx.array(values, dtype=mx.float32).reshape(shape).astype(mx.bfloat16)


def state_sha(a):
    # f32 recurrent state, little-endian host bytes on Apple Silicon.
    import numpy as np
    return hashlib.sha256(np.asarray(a).tobytes()).hexdigest()


def step(T, state, existing=None):
    # Inputs mirror GatedDeltaNet just before gated_delta_update: q,k normalized
    # to ~unit scale, v small, a/b arbitrary. Exact dtypes match the model
    # (q,k,v,a,b bf16; A_log,dt_bias bf16; state f32).
    if existing:
        q = from_list(existing["q"], (B, T, HK, DK))
        k = from_list(existing["k"], (B, T, HK, DK))
        v = from_list(existing["v"], (B, T, HV, DV))
        a = from_list(existing["a"], (B, T, HV))
        b = from_list(existing["b"], (B, T, HV))
    else:
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
        "state_sha256": state_sha(new_state),
    }
    return rec, new_state


A_log = (from_list(replay["A_log"], (HV,)) if replay else
         mx.log(mx.random.uniform(low=0.5, high=8.0, shape=(HV,))).astype(mx.bfloat16))
dt_bias = from_list(replay["dt_bias"], (HV,)) if replay else randn((HV,))

s1_rec, s1 = step(replay["prefill"]["T"] if replay else 3, None,
                  replay["prefill"] if replay else None)
s2_rec, _ = step(replay["decode"]["T"] if replay else 1, s1,
                 replay["decode"] if replay else None)

out = {
    "B": B, "HK": HK, "HV": HV, "DK": DK, "DV": DV,
    "A_log": as_list(A_log), "dt_bias": as_list(dt_bias),
    "prefill": s1_rec,
    "decode": s2_rec,
    "oracle": {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "machine": machine, "device": mx.metal.device_info(),
        "python": platform.python_version(), "macos": platform.mac_ver()[0],
        "mlx": importlib.metadata.version("mlx"),
        "mlx_lm": importlib.metadata.version("mlx-lm"),
        "source_sha256": hashlib.sha256(Path(gated_delta_module.__file__).read_bytes()).hexdigest(),
        "generator_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "replayed_fixture_sha256": hashlib.sha256(replay_bytes).hexdigest() if replay_bytes else None,
    },
}

dest.parent.mkdir(parents=True, exist_ok=True)
with open(dest, "w") as f:
    json.dump(out, f)
print("wrote", dest)
print("prefill y shape", s1_rec["y_shape"], "decode y shape", s2_rec["y_shape"])
