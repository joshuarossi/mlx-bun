#!/usr/bin/env python
# Generate the optiq e4b SigLIP-vision ORACLE for tests/e4b-vision.test.ts.
# Run with the oracle venv:
#   <oracle-venv>/bin/python scripts/gen-e4b-vision-golden.py <model-dir> [image] [out.json]
#
# Drives optiq's REAL gemma4 vision path end-to-end: the SigLIP vision tower +
# MultimodalEmbedder from the optiq_vision.safetensors sidecar, scattered into
# the gemma4_text embedding sequence, then mlx-lm's language decode (per-layer
# inputs, KV-share, sliding window). Greedy at temp 0 → deterministic.
#
# Emits {input_ids, soft_tokens, greedy_ids, decoded} — the tier-a parity
# ground truth (spliced prompt ids + greedy continuation), same shape as the
# 12B goldens/vision.json. The fixture (grad-768.png, 768x768) is resize-free
# so preprocessing is bit-exact.

import json
import sys

# OptiQ's patch maps gemma4* -> mlx-lm classes so mlx-lm can LOAD the OptiQ
# repack (must run before importing mlx_lm). Also registers the vision
# frontends (optiq.vlm import side effect).
from optiq.mlx_lm_patches._register import register

register()

import mlx.core as mx  # noqa: E402
import optiq.vlm  # noqa: F401,E402  (registers gemma4 frontend)
from mlx_lm import load  # noqa: E402
from mlx_lm.models.cache import make_prompt_cache  # noqa: E402
from optiq.runtime.engine import OptiqEngine  # noqa: E402
from PIL import Image  # noqa: E402

MODEL = sys.argv[1] if len(sys.argv) > 1 else (
    "/Users/joshrossi/.cache/huggingface/hub/"
    "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/"
    "fcdb12d740cd813634064567fc7cb51159b34253"
)
IMAGE = sys.argv[2] if len(sys.argv) > 2 else "tests/fixtures/grad-768.png"
OUT = sys.argv[3] if len(sys.argv) > 3 else "goldens/e4b-vision.json"
MAX_TOKENS = 16
PROMPT = "Describe this image in one short sentence."
IMAGE_TOKEN_ID = 258880

model, tok = load(MODEL)
# from_loaded keeps a single model copy (no duplicate-load footprint).
engine = OptiqEngine.from_loaded(model, tok, MODEL)

img = Image.open(IMAGE).convert("RGB")
ids_arr, merged, pli = engine._vlm_prefill_inputs(PROMPT, [img])
prompt_ids = [int(t) for t in ids_arr[0].tolist()]
soft_tokens = sum(1 for t in prompt_ids if t == IMAGE_TOKEN_ID)

cache = make_prompt_cache(model)
_, logits = engine._forward(
    ids_arr, cache=cache, input_embeddings=merged, per_layer_inputs=pli,
)
mx.eval(logits)

eos = engine._eos_ids()
tokid = int(mx.argmax(logits[0, -1]).item())
greedy = [tokid]
# Mirror mlx-bun generate(maxTokens=16): emit each greedy token, stop on EOS.
for _ in range(MAX_TOKENS - 1):
    if tokid in eos:
        break
    _, logits = engine._forward(mx.array([[tokid]]), cache=cache)
    mx.eval(logits)
    tokid = int(mx.argmax(logits[0, -1]).item())
    greedy.append(tokid)

decoded = tok.decode(greedy)
out = {
    "input_ids": prompt_ids,
    "soft_tokens": [soft_tokens],
    "greedy_ids": greedy,
    "decoded": decoded,
}
with open(OUT, "w") as f:
    json.dump(out, f, indent=1)

print(f"wrote {OUT}")
print(f"  prompt_ids: {len(prompt_ids)} (soft_tokens={soft_tokens})")
print(f"  greedy_ids: {greedy}")
print(f"  decoded: {decoded!r}")
