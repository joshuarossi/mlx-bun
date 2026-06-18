#!/usr/bin/env python
# Debug: dump optiq's e4b vision features at two stages for grad-768.png, so
# mlx-bun's SigLIP port can be compared numerically (isolates the vision tower
# from the language decode). Run with the oracle venv python.
#
#   <oracle-venv>/bin/python scripts/dump-e4b-vision-feats.py <model-dir>
#
# Writes /tmp/e4b-vis-{encoder,feats}.f32 (+ .json shape manifests):
#   encoder = vision_tower(pixel_values)        [1, soft, vision_hidden=768]
#   feats   = embed_vision(vision_tower(pv))    [1, soft, text_hidden=2560]

import json
import sys

from optiq.mlx_lm_patches._register import register

register()

import mlx.core as mx  # noqa: E402
import optiq.vlm  # noqa: F401,E402
from mlx_lm import load  # noqa: E402
from optiq.runtime.engine import OptiqEngine  # noqa: E402
from PIL import Image  # noqa: E402

MODEL = sys.argv[1]
IMAGE = sys.argv[2] if len(sys.argv) > 2 else "tests/fixtures/grad-768.png"

model, tok = load(MODEL)
engine = OptiqEngine.from_loaded(model, tok, MODEL)
fe = engine._load_vision_frontend()
assert fe is not None, "no vision frontend"

img = Image.open(IMAGE).convert("RGB")
messages = [{"role": "user", "content": [
    {"type": "image", "image": img},
    {"type": "text", "text": "Describe this image in one short sentence."},
]}]
inp = fe.preprocess(messages, tokenizer=tok)
pv = inp["pixel_values"][0]  # [1, 3, H, W]

# Pre-transformer patch embedding (isolates patchify/pos/input_proj from the
# 16 transformer layers).
vm = fe.vision_tower
_, _, H, W = pv.shape
positions, padding_mask, n_real = vm._patch_positions_single(H, W)
patch_positions = mx.array(positions[None])
padding_positions = mx.array(padding_mask[None])
inembeds = vm.patch_embedder(
    pv, patch_positions[:, :n_real], padding_positions[:, :n_real],
)  # [1, n_real, 768]

import os  # noqa: E402
nlayers = os.environ.get("MLX_BUN_VIS_LAYERS")
if nlayers:
    vm.encoder.layers = vm.encoder.layers[: int(nlayers)]
    print(f"(truncated optiq encoder to {nlayers} layers)")

enc = fe.vision_tower(pv)                 # [1, soft, 768]
feats = fe.embed_vision(enc)             # [1, soft, 2560]
mx.eval(inembeds, enc, feats)


def dump(name, arr):
    a = arr.astype(mx.float32)
    mx.eval(a)
    import numpy as np
    npa = np.array(a)
    npa.tofile(f"/tmp/e4b-vis-{name}.f32")
    json.dump({"shape": list(npa.shape)}, open(f"/tmp/e4b-vis-{name}.json", "w"))
    print(f"  {name}: shape={list(npa.shape)} "
          f"mean={float(npa.mean()):.5f} std={float(npa.std()):.5f} "
          f"absmax={float(abs(npa).max()):.5f}")


print("optiq e4b vision features:")
dump("inembeds", inembeds)
dump("encoder", enc)
dump("feats", feats)
print("wrote /tmp/e4b-vis-{inembeds,encoder,feats}.f32")
