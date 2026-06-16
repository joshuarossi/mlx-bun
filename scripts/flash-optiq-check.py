# Decisive check: does OPTIQ's own flash-attention dK match mlx's stock SDPA?
# If optiq's flash dK also diverges ~100% from sdpa, my TS port is faithful and
# the divergence is inherent to optiq's kernel. If optiq's matches sdpa, my port
# has a real bug to fix.
#
#   .venv/bin/python scripts/flash-optiq-check.py

import optiq
if hasattr(optiq, "register"):
    optiq.register()
else:
    from optiq.mlx_lm_patches import _register; _register.register()

import mlx.core as mx
from optiq.ops.flash_attention_metal import flash_attention_metal

mx.random.seed(0)
B, Hq, Hkv, T, D = 1, 1, 1, 64, 64
scale = D ** -0.5
q = mx.random.normal((B, Hq, T, D)).astype(mx.float16)
k = mx.random.normal((B, Hkv, T, D)).astype(mx.float16)
v = mx.random.normal((B, Hkv, T, D)).astype(mx.float16)

def loss_flash(q, k, v):
    return flash_attention_metal(q, k, v, scale=scale, causal=False).sum()

def loss_sdpa(q, k, v):
    return mx.fast.scaled_dot_product_attention(q, k, v, scale=scale, mask=None).sum()

df = mx.grad(loss_flash, argnums=(0, 1, 2))(q, k, v)
ds = mx.grad(loss_sdpa, argnums=(0, 1, 2))(q, k, v)

for name, i in (("dQ", 0), ("dK", 1), ("dV", 2)):
    a = df[i].astype(mx.float32)
    b = ds[i].astype(mx.float32)
    maxdiff = float(mx.max(mx.abs(a - b)))
    maxref = float(mx.max(mx.abs(b)))
    print(f"{name}: optiq-flash vs sdpa maxdiff={maxdiff:.4f} maxref={maxref:.4f} rel={100*maxdiff/(maxref or 1):.1f}%")

print("optiq flash dK[0,0,0,:6]:", [round(float(x), 4) for x in df[1][0, 0, 0, :6]])
print("sdpa       dK[0,0,0,:6]:", [round(float(x), 4) for x in ds[1][0, 0, 0, :6]])
