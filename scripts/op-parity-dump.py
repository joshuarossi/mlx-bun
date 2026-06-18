#!/usr/bin/env python
# Model-free op parity: run fused kernels through the ORACLE mlx on fixed
# inputs, dump inputs + outputs as raw f32, so mlx-bun can run the SAME inputs
# through its OWN libmlx and compare op-by-op (bit-exact). Settles whether the
# two builds' kernels diverge ON THIS MACHINE.
#   <oracle-venv>/bin/python scripts/op-parity-dump.py
import numpy as np
import mlx.core as mx
import mlx.nn as nn

rng = np.random.default_rng(1234)


def w(name, arr):
    a = np.asarray(arr, dtype=np.float32)
    a.tofile(f"/tmp/op-{name}.f32")
    return a


def bf(x):  # f32 ndarray -> bf16 mx array (deterministic round-to-nearest-even)
    return mx.array(x).astype(mx.bfloat16)


# ---- rms_norm ----
x = w("rms_x", rng.standard_normal((128, 768)))
g = w("rms_w", rng.standard_normal((768,)))
w("rms_out", np.array(mx.fast.rms_norm(bf(x), bf(g), 1e-6).astype(mx.float32)))

# ---- gelu_approx ----
gx = w("gelu_x", rng.standard_normal((128, 3072)) * 3.0)
w("gelu_out", np.array(nn.gelu_approx(bf(gx)).astype(mx.float32)))

# ---- sdpa: well-conditioned (MODERATE scale, NOT peaked) so a bit-exact
# comparison is meaningful. q,k,v [1,4,128,64], scale=1/sqrt(64). Dump no-mask
# AND additive-zero-array-mask outputs (the two dispatch paths). ----
B, H, N, D = 1, 4, 128, 64
scale = 1.0 / (D ** 0.5)
q = w("sdpa_q", rng.standard_normal((B, H, N, D)))
k = w("sdpa_k", rng.standard_normal((B, H, N, D)))
v = w("sdpa_v", rng.standard_normal((B, H, N, D)))
qb, kb, vb = bf(q), bf(k), bf(v)
so_no = mx.fast.scaled_dot_product_attention(qb, kb, vb, scale=scale).astype(mx.float32)
zmask = mx.zeros((B, 1, N, N), dtype=mx.bfloat16)
so_ma = mx.fast.scaled_dot_product_attention(qb, kb, vb, scale=scale, mask=zmask).astype(mx.float32)
mx.eval(so_no, so_ma)
w("sdpa_out", np.array(so_no))
w("sdpa_out_mask", np.array(so_ma))
print("oracle no-mask vs zero-array-mask bit-identical:",
      bool(np.array_equal(np.array(so_no), np.array(so_ma))))
print(f"sdpa scale={scale:.5f} (moderate, non-peaked)")

# ---- bf16 matmul: a[128,768] @ b[768,512] (proj-shaped) ----
a = w("mm_a", rng.standard_normal((128, 768)))
b = w("mm_b", rng.standard_normal((768, 512)))
w("mm_out", np.array((bf(a) @ bf(b)).astype(mx.float32)))

# ---- manual VisionRMSNorm (the q/k/v norm): float32, x**2, weight applied ----
rx = w("vrn_x", rng.standard_normal((1, 256, 12, 64)))
rw = w("vrn_w", rng.standard_normal((64,)))
xf = bf(rx).astype(mx.float32)
var = mx.mean(xf ** 2, axis=-1, keepdims=True)
normed = xf * mx.rsqrt(var + 1e-6)
vrn = (normed * bf(rw).astype(mx.float32)).astype(mx.bfloat16).astype(mx.float32)
mx.eval(vrn)
w("vrn_out", np.array(vrn))

# ---- clip with bf16 scalar bounds (like ClippableLinear) ----
cx = w("clip_x", rng.standard_normal((128, 768)) * 4)
lo = mx.array(-3.5, dtype=mx.bfloat16)
hi = mx.array(3.484375, dtype=mx.bfloat16)
w("clip_out", np.array(mx.clip(bf(cx), lo, hi).astype(mx.float32)))

# ---- cos / sin (2D-RoPE table construction) ----
sx = w("trig_x", rng.standard_normal((256, 16)).astype(np.float32))
w("cos_out", np.array(mx.cos(mx.array(sx))))
w("sin_out", np.array(mx.sin(mx.array(sx))))

# ---- pooler: optiq's einsum("Ll,Ld->ld", weights_f32, x_bf16).astype(bf16) ----
pL, psoft, pd = 2304, 256, 768
pw = w("pool_w", (rng.standard_normal((pL, psoft)) > 1.5).astype(np.float32) / 9)
px = w("pool_x", rng.standard_normal((pL, pd)))
pool = mx.einsum("Ll,Ld->ld", mx.array(pw), bf(px)).astype(mx.bfloat16)
w("pool_out", np.array(pool.astype(mx.float32)))

# ---- full multidimensional RoPE (optiq apply_multidimensional_rope) ----
import importlib
vis = importlib.import_module("optiq.vlm.gemma4.vision")
rq = w("rope_q", rng.standard_normal((1, 256, 12, 64)))
posg = np.stack(np.meshgrid(np.arange(16), np.arange(16), indexing="xy"), -1)
pos = posg.reshape(256, 2).astype(np.int32)
np.asarray(pos, dtype=np.float32).tofile("/tmp/op-rope_pos.f32")
rope_out = vis.apply_multidimensional_rope(bf(rq), mx.array(pos)[None], 100.0).astype(mx.float32)
mx.eval(rope_out)
w("rope_out", np.array(rope_out))
