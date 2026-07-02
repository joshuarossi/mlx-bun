# Oracle-dumped fixtures for the model-free universal-rope unit tests
# (tests/universal-rope.test.ts). Runs in the oracle venv:
#
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-universal-rope-fixtures.py
#
# For each rope variant (default / linear / llama3 / yarn / longrope /
# traditional-partial) this dumps, under tests/fixtures/universal-rope/:
#   <case>-input.bin    f32 raw input (cast to bf16 before rope, both sides)
#   <case>-freqs.bin    f32 frequency table (freqs-based variants)
#   <case>-out<k>.bin   f32 rope output at offset k
# plus manifest.json with the exact constructor params + versions.
#
# CPU-side-cheap (tiny tensors, no downloads). Bit-exactness expectation:
# same machine, elementwise ops are cross-build deterministic (see the
# SigLIP op-parity finding); regen here if a future machine disagrees.

import json
import os
import platform

import mlx.core as mx
import mlx.nn as nn
from mlx_lm.models.rope_utils import initialize_rope

OUT = os.path.join(os.path.dirname(__file__), "..", "tests", "fixtures", "universal-rope")
os.makedirs(OUT, exist_ok=True)

B, H, L = 1, 2, 8
OFFSETS = [0, 5]


def dump(name, arr):
    arr = arr.astype(mx.float32)
    mx.eval(arr)
    with open(os.path.join(OUT, name), "wb") as f:
        f.write(bytes(memoryview(arr)))


def make_input(D, seed):
    # Deterministic, sign-mixed, non-tiny values; dumped as f32 so the TS
    # side reproduces the exact bf16 input via the same f32→bf16 cast.
    n = B * H * L * D
    x32 = (mx.arange(n, dtype=mx.float32) * 0.037 + seed * 0.11) % 7.0 - 3.5
    x32 = x32.reshape(B, H, L, D)
    return x32


cases = []


def run_case(name, D, rope, scaling_config, extra):
    x32 = make_input(D, len(cases))
    dump(f"{name}-input.bin", x32)
    x = x32.astype(mx.bfloat16)
    for off in OFFSETS:
        dump(f"{name}-out{off}.bin", rope(x, offset=off))
    freqs = getattr(rope, "_freqs", None)
    if freqs is not None:
        dump(f"{name}-freqs.bin", freqs)
    cases.append({
        "name": name,
        "shape": [B, H, L, D],
        "offsets": OFFSETS,
        "has_freqs": freqs is not None,
        "scaling_config": scaling_config,
        **extra,
    })


# 1. default — nn.RoPE(dims, traditional=False, base)
D = 64
rope = initialize_rope(D, base=10000.0, traditional=False, scaling_config=None,
                       max_position_embeddings=2048)
run_case("default", D, rope, None, {"dims": D, "base": 10000.0, "traditional": False})

# 2. linear — nn.RoPE scale = 1/factor
sc = {"rope_type": "linear", "factor": 4.0}
rope = initialize_rope(D, base=10000.0, traditional=False, scaling_config=sc,
                       max_position_embeddings=8192)
run_case("linear", D, rope, sc, {"dims": D, "base": 10000.0, "traditional": False,
                                 "max_position_embeddings": 8192})

# 3. llama3 — Llama 3.2 real params
sc = {"rope_type": "llama3", "factor": 32.0, "low_freq_factor": 1.0,
      "high_freq_factor": 4.0, "original_max_position_embeddings": 8192}
rope = initialize_rope(D, base=500000.0, traditional=False, scaling_config=sc,
                       max_position_embeddings=131072)
run_case("llama3", D, rope, sc, {"dims": D, "base": 500000.0, "traditional": False,
                                 "max_position_embeddings": 131072})

# 4. yarn — mscale ratio != 1 (exercises the pre-rope input scale)
D = 128
sc = {"rope_type": "yarn", "factor": 40.0, "original_max_position_embeddings": 4096,
      "beta_fast": 32, "beta_slow": 1, "mscale": 1.0, "mscale_all_dim": 0.0}
rope = initialize_rope(D, base=10000.0, traditional=False, scaling_config=sc,
                       max_position_embeddings=163840)
run_case("yarn", D, rope, sc, {"dims": D, "base": 10000.0, "traditional": False,
                               "max_position_embeddings": 163840,
                               "mscale": float(rope.mscale)})

# 5. yarn, mscale == mscale_all_dim (ratio 1 → no pre-scale branch)
sc = {"rope_type": "yarn", "factor": 16.0, "original_max_position_embeddings": 4096,
      "beta_fast": 32, "beta_slow": 1, "mscale": 1.0, "mscale_all_dim": 1.0}
rope = initialize_rope(D, base=10000.0, traditional=False, scaling_config=sc,
                       max_position_embeddings=65536)
run_case("yarn-noscale", D, rope, sc, {"dims": D, "base": 10000.0, "traditional": False,
                                       "max_position_embeddings": 65536,
                                       "mscale": float(rope.mscale)})

# 6. longrope — SuScaledRoPE (phi3-style long_factor list, dims = full head)
D = 96
long_factor = [1.0 + 0.05 * i for i in range(D // 2)]
sc = {"rope_type": "longrope", "original_max_position_embeddings": 4096,
      "short_factor": 1.0, "long_factor": long_factor}
rope = initialize_rope(D, base=10000.0, traditional=False, scaling_config=sc,
                       max_position_embeddings=131072)
run_case("longrope", D, rope, sc, {"dims": D, "base": 10000.0,
                                   "max_position_embeddings": 131072,
                                   "su_scale": float(rope._scale)})

# 7. traditional + partial rotary (glm4-style): nn.RoPE(dims=D/2) on D-wide heads
D = 128
rope_dims = 64
rope = nn.RoPE(rope_dims, traditional=True, base=10000.0)
run_case("traditional-partial", D, rope, None,
         {"dims": rope_dims, "base": 10000.0, "traditional": True})

# 8. precise gelu (nn.gelu, erf-based — gemma-1/starcoder2 MLPs)
x32 = make_input(64, 99)
dump("gelu-input.bin", x32)
dump("gelu-out.bin", nn.gelu(x32.astype(mx.bfloat16)))
cases.append({"name": "gelu", "shape": [B, H, L, 64], "kind": "gelu"})

with open(os.path.join(OUT, "manifest.json"), "w") as f:
    json.dump({
        "cases": cases,
        "oracle": {"mlx": mx.__version__, "machine": platform.machine(),
                   "host_chip": "apple-m1-max"},
    }, f, indent=1)

print(f"wrote {len(cases)} fixture cases to {OUT}")
