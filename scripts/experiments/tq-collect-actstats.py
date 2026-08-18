# Collect per-channel activation magnitudes at every decoder-norm site of a
# qwen3_5 snapshot (run the FOLDED model to get stats in the rotated basis).
# Output: {norm_site_name: [mean|x| per channel]} — the input to AWQ-style
# equalization (tq-equalize.ts).
#
#   .venv/bin/python scripts/experiments/tq-collect-actstats.py \
#       <model_dir> <corpus.jsonl> <out.json> [rows] [seq]

import json
import random
import sys

import mlx.core as mx
import mlx.nn as nn
from mlx_lm.utils import load

model_dir, corpus, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
rows_n = int(sys.argv[4]) if len(sys.argv) > 4 else 16
seq_len = int(sys.argv[5]) if len(sys.argv) > 5 else 512

model, tok = load(model_dir)

# Find the decoder layer list + final norm regardless of VL wrapper nesting.
inner = model
for attr in ("language_model", "model"):
    while hasattr(inner, attr):
        inner = getattr(inner, attr)
print("inner model:", type(inner).__name__, file=sys.stderr)
layers = inner.layers
final_norm = inner.norm

stats = {}


class Tap(nn.Module):
    def __init__(self, orig, name):
        super().__init__()
        self.orig = orig
        self.name = name

    def __call__(self, x):
        out = self.orig(x)
        a = mx.mean(mx.abs(out.astype(mx.float32)), axis=(0, 1))
        prev = stats.get(self.name)
        stats[self.name] = a if prev is None else prev + a
        return out


P = "language_model.model"
for i, layer in enumerate(layers):
    layer.input_layernorm = Tap(layer.input_layernorm, f"{P}.layers.{i}.input_layernorm.weight")
    layer.post_attention_layernorm = Tap(
        layer.post_attention_layernorm, f"{P}.layers.{i}.post_attention_layernorm.weight")
inner.norm = Tap(final_norm, f"{P}.norm.weight")

texts = []
with open(corpus) as f:
    for line in f:
        try:
            texts.append(json.loads(line)["text"])
        except Exception:
            pass
random.Random(123).shuffle(texts)
ids = []
for t in texts:
    ids.extend(tok.encode(t))
    if len(ids) >= (rows_n + 1) * seq_len:
        break
rows = [ids[i * seq_len:(i + 1) * seq_len] for i in range(min(rows_n, len(ids) // seq_len))]

for r in rows:
    logits = model(mx.array([r]))
    mx.eval(logits)
    for v in stats.values():
        mx.eval(v)
    mx.clear_cache()

out = {k: [float(x) / len(rows) for x in v] for k, v in stats.items()}
with open(out_path, "w") as f:
    json.dump(out, f)
print(f"wrote {len(out)} sites × {len(next(iter(out.values())))} channels over {len(rows)} rows")
