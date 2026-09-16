#!/usr/bin/env python
# Generate the mlx-whisper ORACLE goldens for the Whisper port
# (docs/design/generic-model-support.md §6 Whisper). Run with the whisper
# oracle venv (mlx pinned to the engine's MLX_CORE_VERSION):
#   ~/Code/mlx-whisper-oracle/.venv/bin/python scripts/oracle/gen-whisper-golden.py \
#       [model-dir] [out-dir]
#
# Drives mlx_whisper's REAL path (log_mel_spectrogram → transcribe seek loop
# → DecodingTask greedy) and records, per clip:
#   - mel [T,128] f32 with the 30 s trailing pad          (<clip>-mel.bin)
#   - window-0 encoder output [1,1500,D] f16 raw bytes    (<clip>-enc.bin)
#   - window-0 per-step PRE-filter last-position logits f32 [steps,V]
#                                                          (<clip>-logits.bin)
#   - the full transcribe result (text, segments, tokens, avg_logprob,
#     no_speech_prob, compression_ratio, language) → manifest
# Clips: fox (tracked fixture), jfk (whisper.cpp sample via sotto's vendored
# checkout when present), long (fox + silence + jfk + silence + fox + jfk +
# fox, > 30 s so the seek loop crosses a window). Cases per clip are listed
# in CASES below (greedy, temperature 0 only — sampling is RNG-bound).
#
# Emits <out-dir>/whisper.json (tracked manifest with blob SHA-256s) and the
# UNTRACKED .bin blobs (goldens/**/*.bin is gitignored).

import hashlib
import json
import os
import sys
import wave
from pathlib import Path

import mlx.core as mx
import numpy as np

import mlx_whisper
from mlx_whisper import decoding
from mlx_whisper.audio import N_SAMPLES, log_mel_spectrogram
from mlx_whisper.load_models import load_model
from mlx_whisper.transcribe import ModelHolder

ROOT = Path(__file__).resolve().parents[2]
HOME = Path.home()
DEFAULT_MODEL = HOME / ".cache/huggingface/hub/models--mlx-community--whisper-large-v3-turbo/snapshots/a4aaeec0636e6fef84abdcbe3544cb2bf7e9f6fb"
FOX = ROOT / "fixtures/audio/speech-fox.wav"
JFK = HOME / "Code/sotto/vendor/whisper.cpp/samples/jfk.wav"


def read_wav(path: Path) -> np.ndarray:
    with wave.open(str(path), "rb") as w:
        assert w.getnchannels() == 1 and w.getframerate() == 16000 and w.getsampwidth() == 2, path
        return np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(np.float32) / 32768.0


def silence(seconds: float) -> np.ndarray:
    return np.zeros(int(seconds * 16000), np.float32)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    model_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_MODEL
    out_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "goldens"
    out_dir.mkdir(parents=True, exist_ok=True)

    clips: dict[str, dict] = {}
    fox = read_wav(FOX)
    clips["fox"] = {"samples": fox, "recipe": [{"file": "fixtures/audio/speech-fox.wav"}]}
    if JFK.exists():
        jfk = read_wav(JFK)
        clips["jfk"] = {"samples": jfk, "recipe": [{"file": "vendor/whisper.cpp/samples/jfk.wav"}]}
        long_parts = [fox, silence(2.0), jfk, silence(1.0), fox, jfk, fox]
        clips["long"] = {
            "samples": np.concatenate(long_parts),
            "recipe": [
                {"file": "fixtures/audio/speech-fox.wav"}, {"silence": 2.0},
                {"file": "vendor/whisper.cpp/samples/jfk.wav"}, {"silence": 1.0},
                {"file": "fixtures/audio/speech-fox.wav"}, {"file": "vendor/whisper.cpp/samples/jfk.wav"},
                {"file": "fixtures/audio/speech-fox.wav"},
            ],
        }
    else:
        print(f"note: {JFK} missing — jfk/long clips skipped", file=sys.stderr)

    # cases: (clip, name, transcribe kwargs)
    CASES = [
        ("fox", "greedy-en", dict(language="en")),
        ("fox", "prompt-en", dict(language="en", initial_prompt="Sotto, SwiftUI, Metal, quick brown fox")),
        ("fox", "notimestamps-en", dict(language="en", without_timestamps=True)),
        ("jfk", "greedy-auto", dict(language=None)),
        ("jfk", "translate-en", dict(language="en", task="translate")),
        ("long", "greedy-en", dict(language="en")),
        ("long", "noprev-en", dict(language="en", condition_on_previous_text=False)),
    ]

    model = ModelHolder.get_model(str(model_dir), mx.float16)
    dims = model.dims.__dict__

    manifest = {
        "oracle": {"mlx": mx.__version__, "mlx_whisper": mlx_whisper.__version__, "model_dir": str(model_dir),
                    "weights_sha256": sha256(model_dir / "weights.safetensors")[:16]},
        "dims": dims,
        "clips": {},
        "cases": [],
        "blobs": {},
    }

    for name, clip in clips.items():
        samples = clip["samples"]
        mel = log_mel_spectrogram(mx.array(samples), n_mels=dims["n_mels"], padding=N_SAMPLES)
        mx.eval(mel)
        p = out_dir / f"whisper-{name}-mel.bin"
        np.array(mel).astype(np.float32).tofile(p)
        manifest["clips"][name] = {"num_samples": int(samples.shape[0]), "recipe": clip["recipe"],
                                    "mel_shape": list(mel.shape)}
        manifest["blobs"][p.name] = {"sha256": sha256(p), "dtype": "float32", "shape": list(mel.shape)}

    for clip_name, case_name, kwargs in CASES:
        if clip_name not in clips:
            continue
        samples = clips[clip_name]["samples"]
        # Instrument window 0: encoder output + per-step pre-filter logits.
        # windows counts encoder calls (language detection runs one too);
        # decode_window pins the first window the decoder actually ran on.
        captured = {"enc": None, "last_enc": None, "logits": [], "windows": 0, "decode_window": None}
        orig_encoder = model.encoder
        orig_logits = decoding.Inference.logits

        class Enc:
            def __call__(self, mel):
                out = orig_encoder(mel)
                captured["windows"] += 1
                mx.eval(out)
                captured["last_enc"] = out
                return out

        def logits(self, tokens, audio_features):
            out = orig_logits(self, tokens, audio_features)
            if captured["decode_window"] is None:
                captured["decode_window"] = captured["windows"]
                captured["enc"] = captured["last_enc"]
            if captured["windows"] == captured["decode_window"]:
                last = out[:, -1]
                mx.eval(last)
                captured["logits"].append(np.array(last, dtype=np.float32))
            return out

        model.encoder = Enc()
        decoding.Inference.logits = logits
        try:
            result = mlx_whisper.transcribe(
                samples, path_or_hf_repo=str(model_dir), temperature=0.0, fp16=True, **kwargs,
            )
        finally:
            model.encoder = orig_encoder
            decoding.Inference.logits = orig_logits

        tag = f"{clip_name}-{case_name}"
        enc = captured["enc"]
        enc_p = out_dir / f"whisper-{tag}-enc.bin"
        # raw f16 bytes (bit-exact compare)
        np.array(enc, dtype=np.float16).tofile(enc_p)
        logits_arr = np.stack(captured["logits"]) if captured["logits"] else np.zeros((0, 1, dims["n_vocab"]), np.float32)
        logits_arr = logits_arr.reshape(logits_arr.shape[0], -1)  # [steps, n_group*V]
        logits_p = out_dir / f"whisper-{tag}-logits.bin"
        logits_arr.astype(np.float32).tofile(logits_p)
        manifest["blobs"][enc_p.name] = {"sha256": sha256(enc_p), "dtype": "float16", "shape": list(enc.shape)}
        manifest["blobs"][logits_p.name] = {"sha256": sha256(logits_p), "dtype": "float32", "shape": list(logits_arr.shape)}
        manifest["cases"].append({
            "clip": clip_name, "name": case_name, "options": kwargs,
            "language": result["language"], "text": result["text"],
            "segments": [
                {k: (v.tolist() if hasattr(v, "tolist") else v) for k, v in s.items() if k != "words"}
                for s in result["segments"]
            ],
            "windows": captured["windows"], "decode_window": captured["decode_window"], "window0_steps": int(logits_arr.shape[0]),
        })
        print(f"{tag}: {captured['windows']} windows, {logits_arr.shape[0]} steps → {result['text']!r}")

    (out_dir / "whisper.json").write_text(json.dumps(manifest, indent=1, ensure_ascii=False) + "\n")
    print(f"wrote {out_dir / 'whisper.json'}")


if __name__ == "__main__":
    main()
