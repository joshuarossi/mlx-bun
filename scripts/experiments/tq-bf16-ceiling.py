# bf16 quality ceiling for a model too big to fit in RAM: layer-STREAMED
# teacher-forced scoring (the tq-gptq-27b.py pattern as an evaluator). All
# inputs push through layer i while its bf16 weights are resident, the layer
# is then stripped, and activations carry forward — peak ≈ one layer + the
# activation set (~6 GB for 27B). Produces ppl over the shared corpus AND
# MMLU answer-letter accuracy in ONE pass. (GSM8K needs autoregressive
# decode = 64 layer loads per token — deliberately not attempted.)
#
#   .venv/bin/python -u scripts/experiments/tq-bf16-ceiling.py <bf16_dir> \
#       <corpus.jsonl> [ppl_rows] [mmlu_n]

import json
import math
import random
import re
import sys
from pathlib import Path

import mlx.core as mx
import mlx.nn as nn
from mlx_lm.models.base import create_attention_mask
from mlx_lm.models.qwen3_5 import create_ssm_mask
from mlx_lm.utils import load

model_dir, corpus = sys.argv[1], sys.argv[2]
ppl_rows_n = int(sys.argv[3]) if len(sys.argv) > 3 else 73
mmlu_n = int(sys.argv[4]) if len(sys.argv) > 4 else 100
SEQ = 512
DATA = Path.home() / ".cache/mlx-bun/eval-data"


class Stub(nn.Module):
    def __call__(self, *a, **k):
        raise RuntimeError("stripped layer called")


model, tok = load(model_dir, lazy=True)
lm = model.language_model
inner = lm.model

# ---- inputs -----------------------------------------------------------------
texts = []
for line in open(corpus):
    try:
        texts.append(json.loads(line)["text"])
    except Exception:
        pass
random.Random(123).shuffle(texts)
ids = []
for t in texts:
    ids.extend(tok.encode(t))
    if len(ids) >= (ppl_rows_n + 1) * SEQ:
        break
ppl_rows = [ids[i * SEQ:(i + 1) * SEQ] for i in range(min(ppl_rows_n, len(ids) // SEQ))]

mmlu = [json.loads(l) for l in open(DATA / "mmlu_optiq_frozen.jsonl")][:mmlu_n]
letters = ["A", "B", "C", "D"]
letter_ids = [tok.encode(f" {l}", add_special_tokens=False)[-1] for l in letters]
mmlu_ids = []
for r in mmlu:
    prompt = r["question"].strip() + "\n"
    for li, c in enumerate(r["choices"]):
        prompt += f"{letters[li]}. {c}\n"
    prompt += "Answer:"
    mmlu_ids.append(tok.encode(prompt))

# Sequences, each its own [1, L] stream (batched by padding would change
# masks for the ssm path — keep it simple and exact; the cost is layer-load
# dominated anyway).
streams = [mx.array([r]) for r in ppl_rows] + [mx.array([r]) for r in mmlu_ids]
hs = []
for s in streams:
    h = inner.embed_tokens(s)
    mx.eval(h)
    hs.append(h)
mx.clear_cache()

# ---- layer-streamed forward -------------------------------------------------
n_layers = len(inner.layers)
for li in range(n_layers):
    layer = inner.layers[li]
    is_lin = bool(layer.is_linear)
    new_hs = []
    for h in hs:
        mask = create_ssm_mask(h, None) if is_lin else create_attention_mask(h, None)
        out = layer(h, mask=mask, cache=None)
        mx.eval(out)
        new_hs.append(out)
    hs = new_hs
    inner.layers[li] = Stub()
    mx.clear_cache()
    if (li + 1) % 8 == 0:
        print(f"layer {li + 1}/{n_layers}", flush=True)

# ---- heads ------------------------------------------------------------------
losses = []
mmlu_correct = 0
for i, h in enumerate(hs):
    hn = inner.norm(h)
    if i < len(ppl_rows):
        logits = lm.lm_head(hn).astype(mx.float32)
        x = streams[i]
        lse = mx.logsumexp(logits[:, :-1], axis=-1)
        tgt = mx.take_along_axis(logits[:, :-1], x[:, 1:][..., None], axis=-1)[..., 0]
        ce = lse - tgt
        mx.eval(ce)
        losses.extend(float(v) for v in ce[0])
    else:
        logits = lm.lm_head(hn[:, -1:]).astype(mx.float32)
        mx.eval(logits)
        row = logits[0, -1]
        pick = int(mx.argmax(mx.array([row[t] for t in letter_ids])))
        mmlu_correct += int(pick == mmlu[i - len(ppl_rows)]["answer"])
    mx.clear_cache()

mean = sum(losses) / len(losses)
var = sum((l - mean) ** 2 for l in losses) / (len(losses) - 1)
ppl = math.exp(mean)
se = ppl * math.sqrt(var / len(losses))
print(f"RESULT bf16-ceiling {model_dir}: ppl={ppl:.4f} ±{se:.4f} ({len(losses)} tok)  "
      f"mmlu={mmlu_correct}/{len(mmlu)} = {mmlu_correct / len(mmlu) * 100:.1f}%")
