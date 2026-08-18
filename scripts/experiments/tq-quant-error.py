# Per-module FUNCTION-SPACE quantization error, three arms:
#   plain      : quantize W;            function error  = ||E||·(γ column-scaled)
#   gamma-only : quantize W·diag(γ)     function error  = ||E||   (γ baked)
#   gamma+rot  : quantize W·diag(γ·s)·H function error  = ||E||   (rotation orthogonal)
# For readers, the *function-space* error operator is:
#   plain: E_p · diag(γ)   (runtime γ multiplies the input the error acts on)
#   baked arms: E as-is (post-hoc basis maps are orthogonal / identity)
# Writers (o/out/down) have no γ; rotation acts on the OUTPUT dim (R1ᵀ W).
#
#   .venv/bin/python scripts/experiments/tq-quant-error.py <bf16_trunk_snapshot>

import glob
import json
import struct
import sys

import mlx.core as mx
import numpy as np

snap = sys.argv[1]
HID = 5120
SEED = 42
BITS, GROUP = 4, 64


def load_tensor(want):
    for p in sorted(glob.glob(f"{snap}/model*.safetensors")):
        with open(p, "rb") as f:
            n = struct.unpack("<Q", f.read(8))[0]
            hdr = json.loads(f.read(n))
            info = hdr.get(want)
            if info is None:
                continue
            s, e = info["data_offsets"]
            f.seek(8 + n + s)
            raw = np.frombuffer(f.read(e - s), dtype=np.uint16)
            return mx.array((raw.astype(np.uint32) << 16).view(np.float32).reshape(info["shape"]))
    raise KeyError(want)


def signs(seed, n, lane):
    # mirror rotate.ts signVector (splitmix32)
    state = (seed ^ ((lane + 1) * 0x9E3779B9 & 0xFFFFFFFF)) & 0xFFFFFFFF
    out = np.empty(n, dtype=np.float32)
    for i in range(n):
        state = (state + 0x9E3779B9) & 0xFFFFFFFF
        z = state
        z = (z ^ (z >> 16)) * 0x21F0AAAD & 0xFFFFFFFF
        z = (z ^ (z >> 15)) * 0x735A2D97 & 0xFFFFFFFF
        z ^= z >> 15
        out[i] = 1.0 if (z & 1) == 0 else -1.0
    return mx.array(out)


S1 = signs(SEED, HID, 0)


def had(x):
    return mx.hadamard_transform(x, scale=1.0 / np.sqrt(x.shape[-1]))


def quant_err(w):
    q = mx.quantize(w.astype(mx.bfloat16), GROUP, BITS)
    deq = mx.dequantize(*q, GROUP, BITS).astype(mx.float32)
    e = deq - w.astype(mx.bfloat16).astype(mx.float32)
    return e


def fro(x):
    return float(mx.sqrt(mx.sum(x.astype(mx.float32) ** 2)))


def analyze_reader(name, gamma_name):
    w = load_tensor(name)
    g = load_tensor(gamma_name) if gamma_name else None
    base = fro(w)
    # plain: error operator E_p · diag(γ)
    ep = quant_err(w)
    ep_fn = fro(ep * g) if g is not None else fro(ep)
    # gamma-only
    wg = w * g if g is not None else w
    eg_fn = fro(quant_err(wg))
    # gamma+rot (input-dim fold)
    vec = (g * S1) if g is not None else S1
    wr = had(w * vec)
    er_fn = fro(quant_err(wr))
    # reference function scale: ||W·diag(γ)|| (same for all arms up to rotation)
    ref = fro(wg)
    print(f"{name:70s} rel_fn_err  plain={ep_fn/ref:.5f}  gamma={eg_fn/ref:.5f}  gamma+rot={er_fn/ref:.5f}")
    return ep_fn / ref, er_fn / ref


def analyze_writer(name):
    w = load_tensor(name)
    ref = fro(w)
    ep = fro(quant_err(w))
    wr = mx.transpose(had(mx.transpose(w) * S1))
    er = fro(quant_err(wr))
    print(f"{name:70s} rel_fn_err  plain={ep/ref:.5f}  gamma=  --      gamma+rot={er/ref:.5f}")
    return ep / ref, er / ref


P = "language_model.model"
for layer in [0, 3, 31]:
    L = f"{P}.layers.{layer}"
    is_full = layer % 4 == 3
    inn = f"{L}.input_layernorm.weight"
    post = f"{L}.post_attention_layernorm.weight"
    if is_full:
        for m in ["q_proj", "k_proj", "v_proj"]:
            analyze_reader(f"{L}.self_attn.{m}.weight", inn)
        analyze_writer(f"{L}.self_attn.o_proj.weight")
    else:
        for m in ["in_proj_qkv", "in_proj_z", "in_proj_b", "in_proj_a"]:
            analyze_reader(f"{L}.linear_attn.{m}.weight", inn)
        analyze_writer(f"{L}.linear_attn.out_proj.weight")
    for m in ["gate_proj", "up_proj"]:
        analyze_reader(f"{L}.mlp.{m}.weight", post)
    analyze_writer(f"{L}.mlp.down_proj.weight")

analyze_reader(f"{P}.embed_tokens.weight", None)
analyze_reader("language_model.lm_head.weight", f"{P}.norm.weight")

# γ dynamic ranges — is γ-baking inflating ranges?
for gname in [f"{P}.layers.0.input_layernorm.weight", f"{P}.layers.3.input_layernorm.weight", f"{P}.norm.weight"]:
    g = load_tensor(gname)
    print(f"γ {gname}: min={float(mx.min(g)):.4f} max={float(mx.max(g)):.4f} mean={float(mx.mean(mx.abs(g))):.4f}")
