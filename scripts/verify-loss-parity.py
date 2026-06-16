# L1 bit-exact check (Python reference side): mlx-lm default_loss masked CE
# on the same fixed batch written by verify-loss-parity.ts. e4b is OptiQ-quantized
# so it loads via optiq.register()+mlx_lm.load; a plain model(inputs) forward is
# the stock mlx-lm (L1) path (fused-quant-sdpa is a serve-time install, not this).
#
#   .venv/bin/python scripts/verify-loss-parity.py

import json
import optiq
if hasattr(optiq, "register"):
    optiq.register()
else:
    from optiq.mlx_lm_patches import _register
    _register.register()
from mlx_lm import load
import mlx.core as mx
import mlx.nn as nn
import os

E4B = os.path.expanduser(
    "~/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/"
    "snapshots/fcdb12d740cd813634064567fc7cb51159b34253"
)

d = json.load(open("/tmp/ft-verify-ids.json"))
ids_list, prompt_len = d["ids"], d["promptLen"]

model, _ = load(E4B)
ids = mx.array([ids_list])           # [1, L]
inputs, targets = ids[:, :-1], ids[:, 1:]
logits = model(inputs)               # [1, T, V]
T = targets.shape[1]

# mlx-lm default_loss masking: target at input-pos t is original index t+1;
# supervised iff (t+1) >= prompt_len  →  steps(=t+1) >= prompt_len.
steps = mx.arange(1, T + 1)
mask = (steps >= prompt_len).astype(mx.float32)        # [T], broadcasts over batch
ce = nn.losses.cross_entropy(logits, targets) * mask   # [1, T]
loss = ce.astype(mx.float32).sum() / mask.sum()
print(f"python default_loss: {float(loss):.10g}  (ntoks={int(mask.sum())})")
