#!/usr/bin/env python
# Generate 8000 tokens greedily with mlx-lm (his engine) from a chat prompt, dumping
# the EXACT prompt ids (so our engine feeds the identical input) + the generated ids.
# generate_step ignores EOS, so we get the full 8000-token sequence to compare.
import json, os, sys
os.environ.setdefault("HF_HUB_DISABLE_XET", "1")
import mlx.core as mx
from mlx_lm import load
from mlx_lm.sample_utils import make_sampler
try:
    from mlx_lm.generate import generate_step
except Exception:
    from mlx_lm.utils import generate_step

MODEL = sys.argv[1]
N = 8000
model, tok = load(MODEL)
messages = [{"role": "user", "content": "Write a long, detailed essay on the complete history of computing, from antiquity to the present, covering many eras, machines, and people."}]
prompt_ids = [int(x) for x in tok.apply_chat_template(messages, tokenize=True, add_generation_prompt=True, enable_thinking=False)]
json.dump(prompt_ids, open("/tmp/prompt_ids.json", "w"))

sampler = make_sampler(temp=0.0)
out = []
for t, _lp in generate_step(mx.array(prompt_ids), model, max_tokens=N, sampler=sampler):
    out.append(int(t))
    if len(out) >= N:
        break
json.dump(out, open("/tmp/mlxlm_ids.json", "w"))
print(f"mlx-lm: prompt_len={len(prompt_ids)} generated={len(out)} first15={out[:15]}")
