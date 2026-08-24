# Perplexity of an MLX snapshot over a local {"text": ...}.jsonl corpus,
# through STOCK mlx-lm (independent of mlx-bun's forward paths). mlx-lm
# perplexity methodology: concatenate tokenized samples in a seeded shuffled
# order, cut into non-overlapping seq-len rows, score every position in f32.
#
#   .venv/bin/python scripts/turboquant/tq-ppl.py <model_dir> <corpus.jsonl> \
#       [seq_len] [num_rows]

import json
import random
import sys

import mlx.core as mx
from mlx_lm.utils import load

model_dir, corpus = sys.argv[1], sys.argv[2]
seq_len = int(sys.argv[3]) if len(sys.argv) > 3 else 512
num_rows = int(sys.argv[4]) if len(sys.argv) > 4 else 32

model, tok = load(model_dir)

texts = []
with open(corpus) as f:
    for line in f:
        try:
            texts.append(json.loads(line)["text"])
        except Exception:
            pass
rng = random.Random(123)
rng.shuffle(texts)

ids = []
for t in texts:
    ids.extend(tok.encode(t))
    if len(ids) >= (num_rows + 1) * seq_len:
        break
rows = [ids[i * seq_len:(i + 1) * seq_len] for i in range(min(num_rows, len(ids) // seq_len))]

losses = []
n_tok = 0
for r in rows:
    x = mx.array([r])
    logits = model(x[:, :-1]).astype(mx.float32)
    targets = x[:, 1:]
    lse = mx.logsumexp(logits, axis=-1)
    tgt = mx.take_along_axis(logits, targets[..., None], axis=-1)[..., 0]
    ce = (lse - tgt)  # [1, T]
    mx.eval(ce)
    losses.extend([float(v) for v in ce[0]])
    n_tok += ce.shape[1]
    mx.clear_cache()

import math
mean = sum(losses) / len(losses)
var = sum((l - mean) ** 2 for l in losses) / (len(losses) - 1)
ppl = math.exp(mean)
se = ppl * math.sqrt(var / len(losses))
print(f"{model_dir}: ppl={ppl:.4f} ±{se:.4f}  (rows={len(rows)}, seq={seq_len}, tokens={n_tok})")
