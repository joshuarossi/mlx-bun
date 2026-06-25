#!/usr/bin/env python
# Generate DiffusionGemma parity goldens from the mlx-optiq reference (the L2
# oracle — stock mlx-lm/mlx-vlm cannot load this model). Run with the oracle
# venv (needs mlx-optiq >= 0.2.3; 0.2.7 installed):
#
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-diffusion-golden.py [MODEL_DIR]
#
# Companion to tests/diffusion-parity.test.ts (the mlx-bun side runs the SAME
# deterministic forward with our primitives and compares).
#
# WHY a fixed canvas (not RNG-reproduced cross-impl): the D1 gate is the static
# GRAPH, not the engine. We seed + dump the canvas here and the TS side LOADS
# the identical canvas ids, so the only thing under test is the forward pass
# (embed_canvas -> 30 decoder layers -> tied head), logits-for-logits. Canvas
# init RNG parity is a D2/engine concern, gated separately.
#
# Reference entry point (dossier §2/§8): the top-level Model.__call__ accepts
#   model(input_ids=<prompt ids>, canvas_ids=<canvas ids>) -> out with .logits
# (confirmed via optiq.vlm.diffusion_gemma.lora.diffusion_loss, which calls
#  `model(input_ids=prompt_ids, canvas_ids=canvas).logits`).
#
# This script is defensive: it first prints the loaded module tree + config so
# the exact attribute names for intermediate dumps can be wired up once the 14 GB
# checkpoint is resident; then it dumps the full-forward golden. Intermediate
# (per-component) goldens are added as TODO hooks below.

import sys, os, json, hashlib
import numpy as np

DEFAULT_MODEL = os.path.expanduser(
    "~/.cache/huggingface/hub/models--mlx-community--diffusiongemma-26B-A4B-it-OptiQ-4bit/"
    "snapshots/c42b77a028434a23c21044659c4eb73f9f299446"
)
MODEL = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_MODEL
OUTDIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "goldens", "diffusion")
os.makedirs(OUTDIR, exist_ok=True)

SEED = 0
# A small, fixed text prompt. Kept short so the encoder prefill is cheap and the
# TS side can hardcode the same ids. We encode via the model's tokenizer and
# also dump the ids, so the TS test feeds byte-identical inputs.
PROMPT_TEXT = "Write a haiku about Apple Silicon."

import mlx.core as mx


def _sha(a: np.ndarray) -> str:
    return hashlib.sha256(np.ascontiguousarray(a).tobytes()).hexdigest()[:16]


def _np(x) -> np.ndarray:
    """MLX array -> contiguous float32/np array (eval first)."""
    mx.eval(x)
    return np.array(x.astype(mx.float32) if x.dtype not in (mx.int32, mx.int64, mx.uint32) else x)


def main():
    print(f"[gen-diffusion-golden] model: {MODEL}")
    import optiq
    print(f"[gen-diffusion-golden] optiq: {getattr(optiq, '__version__', '?')}")
    from optiq.vlm.diffusion_gemma import load as dg_load

    # Public load(model_path) -> (model, tokenizer)  [verified via inspect].
    model, tokenizer = dg_load(MODEL)
    config = getattr(model, "config", None)

    # --- 1. Introspection: module tree + config (run-first, cheap, decisive) ---
    try:
        tree = {}
        def walk(m, prefix="", depth=0):
            if depth > 3:
                return
            for name, child in getattr(m, "children", lambda: {})().items():
                key = f"{prefix}{name}"
                tree[key] = type(child).__name__
                walk(child, key + ".", depth + 1)
        walk(model)
        with open(os.path.join(OUTDIR, "module-tree.json"), "w") as f:
            json.dump(tree, f, indent=1)
        print(f"[gen-diffusion-golden] module tree -> {len(tree)} nodes (module-tree.json)")
    except Exception as e:
        print(f"[gen-diffusion-golden] WARN module-tree introspection failed: {e}")

    cfg_dict = None
    for attr in ("config", "args"):
        c = getattr(model, attr, None)
        if c is not None:
            cfg_dict = getattr(c, "__dict__", None) or (c if isinstance(c, dict) else None)
            break
    if cfg_dict is None and isinstance(config, dict):
        cfg_dict = config
    canvas_length = int(getattr(getattr(model, "config", object()), "canvas_length", 256) or 256)
    # vocab_size lives on the text config; fall back to the known 262144.
    vocab_size = None
    for probe in (getattr(model, "config", None), config):
        v = getattr(probe, "vocab_size", None) if probe is not None else None
        if v:
            vocab_size = int(v); break
    if vocab_size is None and isinstance(cfg_dict, dict):
        vocab_size = int(cfg_dict.get("vocab_size", 262144))
    vocab_size = vocab_size or 262144
    print(f"[gen-diffusion-golden] canvas_length={canvas_length} vocab_size={vocab_size}")

    # --- 2. Deterministic inputs ---
    # Prompt ids via the tokenizer returned by load() (carries the chat template).
    prompt_ids = None
    try:
        msgs = [{"role": "user", "content": PROMPT_TEXT}]
        text = tokenizer.apply_chat_template(msgs, tokenize=False, add_generation_prompt=True)
        ids = tokenizer.encode(text)
        prompt_ids = np.array([ids], dtype=np.int32)
        print(f"[gen-diffusion-golden] prompt ids: shape={prompt_ids.shape}")
    except Exception as e:
        print(f"[gen-diffusion-golden] WARN tokenizer encode failed ({e}); using a fixed id stub")
        prompt_ids = np.array([[2, 1841, 476, 35978]], dtype=np.int32)  # bos + a few ids

    mx.random.seed(SEED)
    canvas = mx.random.randint(0, vocab_size, (1, canvas_length)).astype(mx.int32)
    canvas_np = np.array(canvas)

    # --- 3a. Staged intermediates (per-component localization) ---
    # Reproduce the backbone flow so we can dump enc_hidden / dec_hidden /
    # pre-softcap logits and pinpoint where a TS divergence starts. The full
    # forward below must match these (same sha as the monolith path).
    backbone = model.model
    # Per-layer encoder dumps (localize where a TS divergence starts): replicate
    # EncoderModel.__call__ layer-by-layer so we can dump the embedding and the
    # first few layer outputs (pre-final-norm).
    enc = backbone.encoder
    cache = enc.make_cache()
    emb = enc._embed_inputs(mx.array(prompt_ids))
    emb_np = _np(emb)
    print(f"[gen-diffusion-golden] enc_emb: shape={emb_np.shape} sha={_sha(emb_np)}")
    emb_np.astype(np.float32).tofile(os.path.join(OUTDIR, "enc-emb.bin"))
    masks = enc._make_encoder_masks(emb, cache, None, mm_token_type_ids=None)
    h = emb
    for i, (layer, c, mask) in enumerate(zip(backbone.decoder.layers, cache, masks)):
        h = layer(
            h, mask, c, decoder=False,
            layer_scalar=enc.language_model.layers[i].layer_scalar,
        )
        if i < 3:
            hn = _np(h)
            print(f"[gen-diffusion-golden] enc_layer{i}: sha={_sha(hn)}")
            hn.astype(np.float32).tofile(os.path.join(OUTDIR, f"enc-layer{i}.bin"))

    # Layer-0 sub-component dump (attention vs parallel FFN/MoE).
    cache = enc.make_cache()
    emb = enc._embed_inputs(mx.array(prompt_ids))
    masks = enc._make_encoder_masks(emb, cache, None, mm_token_type_ids=None)
    layer0 = backbone.decoder.layers[0]
    ls0 = enc.language_model.layers[0].layer_scalar
    residual = emb
    hn = layer0.input_layernorm(emb)
    attn_out = layer0.self_attn(hn, masks[0], cache[0], decoder=False)
    _np(attn_out).astype(np.float32).tofile(os.path.join(OUTDIR, "l0-attn-out.bin"))
    print(f"[gen-diffusion-golden] l0_attn_out: sha={_sha(_np(attn_out))}")
    h_mid = residual + layer0.post_attention_layernorm(attn_out)
    _np(h_mid).astype(np.float32).tofile(os.path.join(OUTDIR, "l0-hmid.bin"))
    print(f"[gen-diffusion-golden] l0_h_mid: sha={_sha(_np(h_mid))}")
    h1 = layer0.post_feedforward_layernorm_1(layer0.mlp(layer0.pre_feedforward_layernorm(h_mid)))
    _np(h1).astype(np.float32).tofile(os.path.join(OUTDIR, "l0-h1.bin"))
    print(f"[gen-diffusion-golden] l0_h1(dense): sha={_sha(_np(h1))}")
    flat = h_mid.reshape(-1, h_mid.shape[-1])
    idx, w = layer0.router(flat)
    np.array(idx).astype(np.int32).tofile(os.path.join(OUTDIR, "l0-router-idx.bin"))
    _np(w).astype(np.float32).tofile(os.path.join(OUTDIR, "l0-router-w.bin"))
    print(f"[gen-diffusion-golden] l0_router idx{list(idx.shape)} sha={_sha(np.array(idx))} "
          f"w sha={_sha(_np(w))}")
    experts_raw = layer0.experts(layer0.pre_feedforward_layernorm_2(flat), idx, w)
    experts_raw = experts_raw.reshape(h_mid.shape)
    _np(experts_raw).astype(np.float32).tofile(os.path.join(OUTDIR, "l0-experts-raw.bin"))
    print(f"[gen-diffusion-golden] l0_experts_raw: sha={_sha(_np(experts_raw))}")
    h2 = layer0.post_feedforward_layernorm_2(experts_raw)
    _np(h2).astype(np.float32).tofile(os.path.join(OUTDIR, "l0-h2.bin"))
    print(f"[gen-diffusion-golden] l0_h2(moe): sha={_sha(_np(h2))}")

    cache = backbone.encoder.make_cache()
    enc_hidden, cache = backbone.encoder(mx.array(prompt_ids), cache=cache)
    enc_np = _np(enc_hidden)
    print(f"[gen-diffusion-golden] enc_hidden: shape={enc_np.shape} sha={_sha(enc_np)}")
    enc_np.astype(np.float32).tofile(os.path.join(OUTDIR, "enc-hidden.bin"))

    dec_hidden = backbone.decoder(canvas, cache=cache)
    dec_np = _np(dec_hidden)
    print(f"[gen-diffusion-golden] dec_hidden: shape={dec_np.shape} sha={_sha(dec_np)}")
    dec_np.astype(np.float32).tofile(os.path.join(OUTDIR, "dec-hidden.bin"))

    presoftcap = backbone.decoder.embed_tokens.as_linear(dec_hidden)
    pre_np = _np(presoftcap)
    print(f"[gen-diffusion-golden] presoftcap: shape={pre_np.shape} sha={_sha(pre_np)}")
    pre_np.astype(np.float32).tofile(os.path.join(OUTDIR, "presoftcap-logits.bin"))

    # --- 3. Full-forward golden (the D1 exit gate) ---
    # No self-conditioning signal (first denoise step): sc_logits/sc_embeddings None.
    out = model(input_ids=mx.array(prompt_ids), canvas_ids=canvas)
    logits = getattr(out, "logits", out)
    logits_np = _np(logits)  # expected [1, canvas_length, vocab_size]
    print(f"[gen-diffusion-golden] forward logits: shape={logits_np.shape} sha={_sha(logits_np)}")

    logits_np.astype(np.float32).tofile(os.path.join(OUTDIR, "forward-logits.bin"))
    canvas_np.astype(np.int32).tofile(os.path.join(OUTDIR, "forward-canvas.bin"))
    prompt_ids.astype(np.int32).tofile(os.path.join(OUTDIR, "forward-prompt.bin"))
    meta = {
        "model": MODEL,
        "seed": SEED,
        "prompt_text": PROMPT_TEXT,
        "prompt_ids_shape": list(prompt_ids.shape),
        "canvas_shape": list(canvas_np.shape),
        "canvas_length": canvas_length,
        "vocab_size": vocab_size,
        "logits_shape": list(logits_np.shape),
        "logits_sha16": _sha(logits_np),
        "logits_dtype": "float32",
        "argmax_canvas": np.array(mx.argmax(logits, axis=-1))[0].astype(int).tolist(),
        "enc_hidden_shape": list(enc_np.shape),
        "dec_hidden_shape": list(dec_np.shape),
        "presoftcap_shape": list(pre_np.shape),
        "files": {
            "logits": "forward-logits.bin",
            "canvas": "forward-canvas.bin",
            "prompt": "forward-prompt.bin",
            "enc_hidden": "enc-hidden.bin",
            "dec_hidden": "dec-hidden.bin",
            "presoftcap": "presoftcap-logits.bin",
        },
    }
    with open(os.path.join(OUTDIR, "forward.json"), "w") as f:
        json.dump(meta, f, indent=1)
    print(f"[gen-diffusion-golden] wrote goldens -> {OUTDIR}")

    # --- 4. TODO (wire once module tree is confirmed on real weights) ---
    #  * vision features: model.model.encoder.get_image_features(pixel_values)
    #  * per-layer hidden states: hook model.model.decoder.layers[k]
    #  * tied-head only: embed_tokens.as_linear(h) on a fixed normed h
    #  * self-conditioning step: second forward with sc_embeddings fed back
    # These give the per-COMPONENT sub-gates (cheaper to localize a divergence
    # than to debug the whole 30-layer forward). Add after the first full-forward
    # golden is confirmed to load.


if __name__ == "__main__":
    main()
