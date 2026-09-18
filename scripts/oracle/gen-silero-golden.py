#!/usr/bin/env python
# Silero VAD reference goldens (silero-vad 6.2.1, torch JIT model) for
# src/audio/silero-vad.ts: per-chunk speech probabilities and
# get_speech_timestamps segments (sotto's parameters: threshold 0.5,
# min_speech_duration_ms 120) on the tracked fixtures plus synthetic silence
# and low-level noise. Run with the whisper oracle venv:
#   ~/Code/mlx-whisper-oracle/.venv/bin/python scripts/oracle/gen-silero-golden.py [out.json]
# Emits goldens/silero-vad.json (tracked; ~600 floats).
import json, sys, wave
from pathlib import Path
import numpy as np, torch, silero_vad
from silero_vad import get_speech_timestamps

ROOT = Path(__file__).resolve().parents[2]
out_path = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "goldens/silero-vad.json"

def read_wav(p):
    with wave.open(str(p), "rb") as w:
        return np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(np.float32) / 32768.0

model = silero_vad.load_silero_vad(onnx=False)
rng = np.random.default_rng(0)
clips = {
    "fox": read_wav(ROOT / "fixtures/audio/speech-fox.wav"),
    "chirp": read_wav(ROOT / "fixtures/audio/chirp-1s6.wav"),
    "silence": np.zeros(32000, np.float32),
    "noise": (rng.standard_normal(32000) * 0.01).astype(np.float32),
}
jfk = Path.home() / "Code/sotto/vendor/whisper.cpp/samples/jfk.wav"
if jfk.exists():
    clips["jfk"] = read_wav(jfk)
manifest = {"oracle": {"silero_vad": silero_vad.__version__, "torch": torch.__version__}, "params": {"threshold": 0.5, "min_speech_duration_ms": 120}, "clips": {}}
for name, a in clips.items():
    model.reset_states()
    x = torch.from_numpy(a)
    probs = []
    for s in range(0, len(a), 512):
        c = x[s:s + 512]
        if len(c) < 512:
            c = torch.nn.functional.pad(c, (0, 512 - len(c)))
        probs.append(round(model(c, 16000).item(), 6))
    segs = get_speech_timestamps(x, model, threshold=0.5, min_speech_duration_ms=120)
    segs_default = get_speech_timestamps(x, model)
    manifest["clips"][name] = {"num_samples": int(len(a)), "noise_seed": 0 if name == "noise" else None,
                               "probs": probs, "segments": segs, "segments_default": segs_default}
    print(name, len(probs), "chunks", segs)
out_path.write_text(json.dumps(manifest, indent=1) + "\n")
print("wrote", out_path)
