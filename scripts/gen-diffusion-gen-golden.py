#!/usr/bin/env python
# DiffusionGemma D2 (denoising engine) parity golden. Drives optiq's REAL
# stream_diffusion_generate with a fixed global seed + confidence-threshold
# sampler at temperature 0 (the OptiQ public default), and dumps the emitted
# token ids + step count. The mlx-bun engine seeds the SAME global mlx key and
# calls randint in the same order → token-for-token parity.
#
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-diffusion-gen-golden.py
#
# Companion: tests/diffusion-gen-parity.test.ts.

import sys, os, json
import numpy as np
import mlx.core as mx

DEFAULT_MODEL = os.path.expanduser(
    "~/.cache/huggingface/hub/models--mlx-community--diffusiongemma-26B-A4B-it-OptiQ-4bit/"
    "snapshots/c42b77a028434a23c21044659c4eb73f9f299446"
)
MODEL = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_MODEL
OUTDIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "goldens", "diffusion")
os.makedirs(OUTDIR, exist_ok=True)

SEED = 0
PROMPT_TEXT = "Write a haiku about Apple Silicon."
MAX_TOKENS = 64
SAMPLER = "confidence-threshold"
THRESHOLD = 0.9


def main():
    from optiq.vlm.diffusion_gemma import load as dg_load
    from optiq.vlm._mlxvlm.generate.diffusion import stream_diffusion_generate

    model, tokenizer = dg_load(MODEL)

    msgs = [{"role": "user", "content": PROMPT_TEXT}]
    text = tokenizer.apply_chat_template(msgs, tokenize=False, add_generation_prompt=True)
    ids = tokenizer.encode(text)
    input_ids = mx.array([ids], dtype=mx.int32)
    print(f"[gen-gen-golden] prompt ids: {len(ids)}")

    skip_special = []

    # Run both samplers from the SAME global seed (confidence-threshold = OptiQ
    # public default; entropy-bound = model/engine default). Each output is a
    # separate golden the TS engine reproduces token-for-token.
    for sampler, outfile in (
        ("confidence-threshold", "gen.json"),
        ("entropy-bound", "gen-entropy.json"),
    ):
        mx.random.seed(SEED)
        tokens = []
        total_steps = 0
        finish_reason = "length"
        for r in stream_diffusion_generate(
            model,
            tokenizer,
            tokenizer,
            input_ids,
            pixel_values=None,
            attention_mask=None,
            max_tokens=MAX_TOKENS,
            skip_special_token_ids=skip_special,
            temperature=0.0,
            diffusion_sampler=sampler,
            diffusion_threshold=THRESHOLD,
        ):
            if r.diffusion_denoising_steps:
                total_steps = int(r.diffusion_denoising_steps)
            if r.is_draft or r.diffusion_block_complete:
                continue
            if r.finish_reason is not None:
                finish_reason = r.finish_reason
                continue
            if r.token is not None:
                tokens.append(int(r.token))

        print(f"[gen-gen-golden] {sampler}: {len(tokens)} tokens, {total_steps} steps, finish={finish_reason}")
        print(f"[gen-gen-golden]   first 16: {tokens[:16]}")
        meta = {
            "model": MODEL,
            "seed": SEED,
            "prompt_text": PROMPT_TEXT,
            "prompt_ids": ids,
            "max_tokens": MAX_TOKENS,
            "sampler": sampler,
            "threshold": THRESHOLD,
            "temperature": 0.0,
            "max_denoising_steps": 48,
            "t_min": 0.4,
            "t_max": 0.8,
            "entropy_bound": 0.1,
            # optiq loads generation_config=None for this checkpoint, so the
            # stable_and_confident stop is a no-op and the eos set is the
            # tokenizer's stopping_criteria ([1, 106]; 50 is NOT an eos).
            "stable_stop": False,
            "eos_token_id": [1, 106],
            "tokens": tokens,
            "total_steps": total_steps,
            "finish_reason": finish_reason,
        }
        with open(os.path.join(OUTDIR, outfile), "w") as f:
            json.dump(meta, f, indent=1)
        print(f"[gen-gen-golden] wrote {OUTDIR}/{outfile}")


if __name__ == "__main__":
    main()
