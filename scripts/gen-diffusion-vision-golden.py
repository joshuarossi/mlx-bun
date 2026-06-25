#!/usr/bin/env python
# DiffusionGemma image-text-to-text (D3 vision) parity golden. Drives optiq's
# real image path with a fixed seed + confidence-threshold sampler at temp 0.
# Dumps: the spliced input_ids + soft-token count (splice gate), the SigLIP
# vision features `get_image_features(pixel_values)` (tower sub-gate), and the
# emitted token ids (end-to-end gate).
#
#   <oracle-venv>/bin/python scripts/gen-diffusion-vision-golden.py
#
# Companion: tests/diffusion-vision.test.ts. Fixture grad-768.png (768x768,
# resize-free → bit-exact preprocessing).

import sys, os, json, hashlib
import numpy as np
import mlx.core as mx

DEFAULT_MODEL = os.path.expanduser(
    "~/.cache/huggingface/hub/models--mlx-community--diffusiongemma-26B-A4B-it-OptiQ-4bit/"
    "snapshots/c42b77a028434a23c21044659c4eb73f9f299446"
)
MODEL = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_MODEL
IMAGE = sys.argv[2] if len(sys.argv) > 2 else "tests/fixtures/grad-768.png"
OUTDIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "goldens", "diffusion")
os.makedirs(OUTDIR, exist_ok=True)

SEED = 0
PROMPT = "Describe this image in one short sentence."
MAX_TOKENS = 64


def _sha(a):
    return hashlib.sha256(np.ascontiguousarray(a).tobytes()).hexdigest()[:16]


def main():
    from PIL import Image
    from optiq.vlm.diffusion_gemma import load as dg_load
    from optiq.vlm.diffusion_gemma.generate import _build_image_inputs
    from optiq.vlm._mlxvlm.generate.diffusion import stream_diffusion_generate

    model, tokenizer = dg_load(MODEL)
    img = Image.open(IMAGE).convert("RGB")

    input_ids, pixel_values, mm = _build_image_inputs(model, tokenizer, PROMPT, [img])
    ids = np.array(input_ids)[0].astype(int).tolist()
    soft = int((np.array(mm)[0] == 1).sum())
    print(f"[vision-golden] spliced ids: {len(ids)} (soft tokens {soft})")

    # Per-stage sub-gates (localize a TS divergence): hook the vision sub-modules
    # at the CLASS level (nn.Module.__call__ resolves on the type).
    import optiq.vlm._mlxvlm.models.gemma4.vision as VIS
    def _stash(name, arr):
        mx.eval(arr); a = np.array(arr.astype(mx.float32))
        a.tofile(os.path.join(OUTDIR, f"vision-{name}.bin"))
        print(f"[vision-golden] stage {name}: shape={a.shape} sha={_sha(a)}")
    PE, ENC, POOL = VIS.VisionPatchEmbedder, VIS.VisionTransformerModel, VIS.VisionPooler
    pe_o, enc_o, pool_o = PE.__call__, ENC.__call__, POOL.__call__
    PE.__call__ = lambda self, *a, **k: (lambda r: (_stash("patchembed", r), r)[1])(pe_o(self, *a, **k))
    ENC.__call__ = lambda self, *a, **k: (lambda r: (_stash("transformer", r), r)[1])(enc_o(self, *a, **k))
    POOL.__call__ = lambda self, *a, **k: (lambda r: (_stash("pooled", r[0]), r)[1])(pool_o(self, *a, **k))

    # Tower sub-gate: features that get scattered into the prompt embeddings.
    feats = model.model.encoder.get_image_features(pixel_values)
    mx.eval(feats)
    feats_np = np.array(feats.astype(mx.float32))
    print(f"[vision-golden] vision features: shape={feats_np.shape} sha={_sha(feats_np)}")
    feats_np.astype(np.float32).tofile(os.path.join(OUTDIR, "vision-features.bin"))
    np.array(pixel_values.astype(mx.float32)).astype(np.float32).tofile(
        os.path.join(OUTDIR, "vision-pixels.bin")
    )

    # End-to-end: seeded image-text generation.
    mx.random.seed(SEED)
    tokens = []
    total_steps = 0
    finish = "length"
    for r in stream_diffusion_generate(
        model, tokenizer, tokenizer, input_ids, pixel_values, None,
        max_tokens=MAX_TOKENS, skip_special_token_ids=set(),
        temperature=0.0, diffusion_sampler="confidence-threshold",
        mm_token_type_ids=mm,
    ):
        if r.diffusion_denoising_steps:
            total_steps = int(r.diffusion_denoising_steps)
        if r.is_draft or r.diffusion_block_complete:
            continue
        if r.finish_reason is not None:
            finish = r.finish_reason
            continue
        if r.token is not None:
            tokens.append(int(r.token))
    decoded = tokenizer.decode(tokens) if hasattr(tokenizer, "decode") else ""
    print(f"[vision-golden] generated {len(tokens)} tokens / {total_steps} steps ({finish})")
    print(f"[vision-golden] decoded: {decoded!r}")

    meta = {
        "model": MODEL,
        "image": IMAGE,
        "prompt": PROMPT,
        "seed": SEED,
        "max_tokens": MAX_TOKENS,
        "input_ids": ids,
        "soft_tokens": soft,
        "pixel_shape": list(pixel_values.shape),
        "vision_features_shape": list(feats_np.shape),
        "vision_features_sha16": _sha(feats_np),
        "tokens": tokens,
        "total_steps": total_steps,
        "finish_reason": finish,
        "decoded": decoded,
    }
    with open(os.path.join(OUTDIR, "vision.json"), "w") as f:
        json.dump(meta, f, indent=1)
    print(f"[vision-golden] wrote {OUTDIR}/vision.json")


if __name__ == "__main__":
    main()
