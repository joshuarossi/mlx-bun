#!/usr/bin/env python
# Generate the optiq e4b AUDIO ORACLE goldens (Phase A0 of
# docs/design/audio-input-plan.md; tiers T0/T1/T2 of §3.4).
# Run with the oracle venv:
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-e4b-audio-golden.py \
#       [model-dir] [out.json]
#
# Drives optiq's REAL gemma4 audio path end-to-end, mirroring
# scripts/gen-e4b-vision-golden.py structurally. optiq's serve frontend only
# wires vision, so the audio machinery is scripted directly from
# optiq/vlm/_mlxvlm/models/gemma4/:
#   - Gemma4AudioFeatureExtractor() with constructor DEFAULTS (§3.3 Q3: no
#     processor_config.json ships, USM params are fixed) -> mel input_features
#     [T,128] f32 + validity mask                                  (T0 golden)
#   - AudioEncoder (12-block Conformer) + MultimodalEmbedder(embed_audio),
#     bf16 weights from the optiq_vision.safetensors sidecar -> language-space
#     embeddings [n,2560]                                          (T1 golden)
#   - <|audio|> -> boa + audio*n + eoa splice with
#     n = min(ceil(duration_ms/40), 750) per processing_gemma4.py, then the
#     merged-embeddings prefill through mlx-lm's gemma4_text (per-layer-input
#     zeroing at audio positions; features pre-divided by embed_scale exactly
#     like the vision frontend) and 32-token greedy decode        (T2 golden)
#
# Attention semantics (§3.3 Q1): audio prompts are strictly CAUSAL — no
# bidirectional overlay is passed, matching the oracle language model.
# enable_thinking is pinned False explicitly (CLAUDE.md hazard: mlx-lm's
# TokenizerWrapper injects enable_thinking=True for thinking-capable models).
#
# Emits goldens/e4b-audio.json (tracked manifest: shapes, spliced ids, greedy
# ids, decoded strings, masks, oracle versions) + UNTRACKED regenerable blobs
# goldens/e4b-audio-<name>-mel.bin / goldens/e4b-audio-<name>-embed.bin
# (float32, row-major, shapes recorded in the manifest; .bin is gitignored).

import json
import math
import re
import sys
import wave
from pathlib import Path

import numpy as np

# OptiQ's patch maps gemma4* -> mlx-lm classes so mlx-lm can LOAD the OptiQ
# repack (must run before importing mlx_lm).
from optiq.mlx_lm_patches._register import register

register()

import mlx.core as mx  # noqa: E402
from mlx_lm import load  # noqa: E402
from mlx_lm.models.cache import make_prompt_cache  # noqa: E402
from optiq.runtime.engine import OptiqEngine  # noqa: E402
from optiq.vlm._mlxvlm.models.gemma4.audio import AudioEncoder  # noqa: E402
from optiq.vlm._mlxvlm.models.gemma4.audio_feature_extractor import (  # noqa: E402
    Gemma4AudioFeatureExtractor,
)
from optiq.vlm._mlxvlm.models.gemma4.config import AudioConfig  # noqa: E402
from optiq.vlm._mlxvlm.models.gemma4.gemma4 import (  # noqa: E402
    MultimodalEmbedder,
    masked_scatter,
)
from optiq.vlm.sidecar import VISION_SIDECAR_NAME  # noqa: E402

MODEL = sys.argv[1] if len(sys.argv) > 1 else (
    "/Users/joshrossi/.cache/huggingface/hub/"
    "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/"
    "fcdb12d740cd813634064567fc7cb51159b34253"
)
OUT = sys.argv[2] if len(sys.argv) > 2 else "goldens/e4b-audio.json"
MAX_TOKENS = 32
FIXTURES = [
    # (name, wav path, user text, expected soft tokens = ceil(duration_ms/40))
    ("chirp", "fixtures/audio/chirp-1s6.wav", "Describe this audio.", 40),
    ("speech", "fixtures/audio/speech-fox.wav", "Transcribe this audio.", 67),
]

cfg = json.load(open(Path(MODEL) / "config.json"))
AUDIO_TOKEN_ID = cfg["audio_token_id"]   # 258881
BOA_TOKEN_ID = cfg["boa_token_id"]       # 256000
EOA_TOKEN_ID = cfg["eoa_token_id"]       # 258883
AUDIO_SEQ_LENGTH = 750                    # processor default (§3.3 Q3)
AUDIO_MS_PER_TOKEN = 40                   # processor default (§3.3 Q3)

model, tok = load(MODEL)
# from_loaded keeps a single model copy (no duplicate-load footprint).
engine = OptiqEngine.from_loaded(model, tok, MODEL)
lm = engine._inner  # mlx-lm gemma4_text inner model (embed_tokens, pli)

# ── audio tower + projector from the bf16 sidecar ──────────────────────────
acfg = AudioConfig.from_dict(cfg["audio_config"])
audio_tower = AudioEncoder(acfg)
embed_audio = MultimodalEmbedder(
    embedding_dim=acfg.output_proj_dims or acfg.hidden_size,
    text_hidden_size=cfg["text_config"]["hidden_size"],
    eps=acfg.rms_norm_eps,
)
sc = mx.load(str(Path(MODEL) / VISION_SIDECAR_NAME))
at_w = {k[len("audio_tower."):]: v for k, v in sc.items()
        if k.startswith("audio_tower.")}
ea_w = {k[len("embed_audio."):]: v for k, v in sc.items()
        if k.startswith("embed_audio.")}
audio_tower.load_weights(list(at_w.items()))
embed_audio.load_weights(list(ea_w.items()))
audio_tower.eval()
embed_audio.eval()

feature_extractor = Gemma4AudioFeatureExtractor()  # defaults — §3.3 Q3

# tokenizer template: pin enable_thinking=False when the template takes it
# (it does for e4b; probe like the vision frontend to stay portable).
TMPL_KW = {}
try:
    tok.apply_chat_template(
        [{"role": "user", "content": "x"}],
        add_generation_prompt=True, tokenize=False, enable_thinking=False,
    )
    TMPL_KW["enable_thinking"] = False
except Exception:
    pass

boa_str = tok.convert_ids_to_tokens(BOA_TOKEN_ID)    # "<|audio>"
audio_str = tok.convert_ids_to_tokens(AUDIO_TOKEN_ID)  # "<|audio|>"
eoa_str = tok.convert_ids_to_tokens(EOA_TOKEN_ID)    # "<audio|>"


def read_wav_mono16k(path: str) -> np.ndarray:
    """PCM16 mono 16 kHz WAV -> float32 waveform in [-1, 1)."""
    w = wave.open(path)
    assert w.getnchannels() == 1 and w.getsampwidth() == 2, "expect mono PCM16"
    assert w.getframerate() == 16_000, "expect 16 kHz"
    pcm = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16)
    return pcm.astype(np.float32) / 32768.0


results = {}
for name, wav_path, prompt, expected_n in FIXTURES:
    waveform = read_wav_mono16k(wav_path)
    duration_ms = len(waveform) / feature_extractor.sampling_rate * 1000.0
    # processing_gemma4.py _compute_audio_num_tokens
    n_soft = min(math.ceil(duration_ms / AUDIO_MS_PER_TOKEN), AUDIO_SEQ_LENGTH)
    assert n_soft == expected_n, f"{name}: soft tokens {n_soft} != {expected_n}"

    # ── T0: mel features + validity mask (feature-extractor defaults) ──────
    fe_out = feature_extractor([waveform], return_attention_mask=True)
    mel = fe_out["input_features"][0]          # [T,128] f32 (padded tail zeroed)
    mel_mask = fe_out["input_features_mask"][0]  # [T] bool, True = valid

    # ── spliced ids: chat template renders <|audio|>, expand like the oracle
    # processor (text-level re.sub), encode once ────────────────────────────
    messages = [{
        "role": "user",
        "content": [{"type": "audio"}, {"type": "text", "text": prompt}],
    }]
    text = tok.apply_chat_template(
        messages, add_generation_prompt=True, tokenize=False, **TMPL_KW
    )
    expanded = re.sub(
        re.escape(audio_str),
        lambda _: boa_str + audio_str * n_soft + eoa_str,
        text,
    )
    prompt_ids = tok.encode(expanded, add_special_tokens=False)
    assert prompt_ids.count(AUDIO_TOKEN_ID) == n_soft

    # ── T1: tower + embed_audio (tower mask: True = INVALID) ───────────────
    feats = mx.array(mel)[None]                       # [1,T,128] f32
    invalid = mx.logical_not(mx.array(mel_mask))[None]  # [1,T]
    enc, _ = audio_tower(feats, invalid)
    lang_embeds = embed_audio(enc)                    # [1,T_sub,2560]
    mx.eval(lang_embeds)
    t_sub = lang_embeds.shape[1]
    assert t_sub == n_soft, f"{name}: tower frames {t_sub} != soft tokens {n_soft}"

    mel_np = np.asarray(mel, dtype=np.float32)
    emb_np = np.array(lang_embeds[0].astype(mx.float32))
    mel_bin = f"goldens/e4b-audio-{name}-mel.bin"
    emb_bin = f"goldens/e4b-audio-{name}-embed.bin"
    mel_np.tofile(mel_bin)
    emb_np.tofile(emb_bin)

    # ── T2: merged-embeddings prefill + 32-token greedy (vision-frontend
    # conventions: unscaled token embeds, features pre-divided by embed_scale,
    # per-layer-input ids zeroed at audio positions, causal mask only) ───────
    ids_arr = mx.array(prompt_ids, dtype=mx.int32)[None]
    embeds = lm.embed_tokens(ids_arr)  # UNSCALED (mlx-lm scales later)
    features = lang_embeds.reshape(-1, lang_embeds.shape[-1])
    features = features.astype(embeds.dtype) / lm.embed_scale
    scatter_mask = mx.broadcast_to(
        mx.expand_dims(ids_arr == AUDIO_TOKEN_ID, -1), embeds.shape
    )
    merged = masked_scatter(embeds, scatter_mask, features)
    pli = None
    if getattr(lm, "hidden_size_per_layer_input", 0):
        text_mask = ids_arr != AUDIO_TOKEN_ID
        zeroed = mx.where(text_mask, ids_arr, mx.zeros_like(ids_arr))
        pli = lm._get_per_layer_inputs(zeroed)

    cache = make_prompt_cache(model)
    _, logits = engine._forward(
        ids_arr, cache=cache, input_embeddings=merged, per_layer_inputs=pli,
    )
    mx.eval(logits)

    eos = engine._eos_ids()
    tokid = int(mx.argmax(logits[0, -1]).item())
    greedy = [tokid]
    # Mirror mlx-bun generate(maxTokens=32): emit each greedy token, stop on EOS.
    for _ in range(MAX_TOKENS - 1):
        if tokid in eos:
            break
        _, logits = engine._forward(mx.array([[tokid]]), cache=cache)
        mx.eval(logits)
        tokid = int(mx.argmax(logits[0, -1]).item())
        greedy.append(tokid)

    decoded = tok.decode(greedy)
    results[name] = {
        "wav": wav_path,
        "num_samples": int(len(waveform)),
        "duration_ms": duration_ms,
        "text": prompt,
        "soft_tokens": n_soft,
        "input_ids": prompt_ids,
        "mel_bin": mel_bin,
        "mel_shape": list(mel_np.shape),
        "mel_mask": [int(v) for v in mel_mask],
        "embed_bin": emb_bin,
        "embed_shape": list(emb_np.shape),
        "greedy_ids": greedy,
        "decoded": decoded,
    }
    print(f"{name}: {wav_path} ({duration_ms:.2f} ms)")
    print(f"  mel {mel_np.shape}  valid_frames={int(np.sum(mel_mask))}")
    print(f"  embed {emb_np.shape}  soft_tokens={n_soft}")
    print(f"  prompt_ids: {len(prompt_ids)}")
    print(f"  greedy_ids: {greedy}")
    print(f"  decoded: {decoded!r}")

import mlx_lm  # noqa: E402
import optiq  # noqa: E402

out = {
    "oracle": {
        "mlx": mx.__version__,
        "mlx_lm": mlx_lm.__version__,
        "optiq": optiq.__version__,
        "model": MODEL,
        "enable_thinking": TMPL_KW.get("enable_thinking"),
        "generator": "scripts/gen-e4b-audio-golden.py",
    },
    "token_ids": {
        "boa": BOA_TOKEN_ID, "audio": AUDIO_TOKEN_ID, "eoa": EOA_TOKEN_ID,
    },
    "fixtures": results,
}
with open(OUT, "w") as f:
    json.dump(out, f, indent=1)
print(f"wrote {OUT}")
