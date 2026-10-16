"""Produce external Phonon-2 MLX references; no weights or captures enter Git.

Run through gpu.sh. Requires mlx==0.32.2, mlx-audio==0.4.6,
fermion-research==0.2.11, numpy, scipy, soundfile and huggingface_hub in an
external Python environment. --container and --config are the checksummed
files unpacked from FermionResearch/Phonon-2. See --help for inputs.
"""
import argparse
import hashlib
import importlib.metadata
import importlib.util
import json
from pathlib import Path
import platform
import sys
import types
import time


def sha(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while block := f.read(1024 * 1024):
            h.update(block)
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--container", type=Path, required=True)
    ap.add_argument("--config", type=Path, required=True)
    ap.add_argument("--audio", type=Path, nargs="+", required=True)
    ap.add_argument("--output", type=Path)
    ap.add_argument("--benchmark", type=int, default=0, metavar="REPETITIONS", help="benchmark Fermion default dense16+tdt16, JSON on stdout; no dumps")
    ap.add_argument("--warmup", type=int, default=2)
    a = ap.parse_args()
    versions = {p: importlib.metadata.version(p) for p in ("mlx", "mlx-audio", "fermion-research", "numpy", "soundfile")}
    for p, v in {"mlx": "0.32.2", "mlx-audio": "0.4.6", "fermion-research": "0.2.11"}.items():
        if versions[p] != v:
            raise RuntimeError(f"reference requires {p}=={v}, found {versions[p]}")
    if sha(a.container) != "4b6bfa3a12cc3c4e0a54f2ab3ec4ca7a842b09e5c7ecfc8e7ca0ac6cc8c11468":
        raise RuntimeError("container differs from pinned Phonon-2")
    if a.benchmark < 0 or a.warmup < 0:
        ap.error("benchmark and warmup must be nonnegative")
    if not a.benchmark and not a.output:
        ap.error("--output is required for reference captures")
    if sha(a.config) != "d0daad3b2a182893844f4abdc11e4f5b7083f7d42c8ad7e8203f71559785a31b":
        raise RuntimeError("config differs from pinned Phonon-2")
    if a.output:
        a.output.mkdir(parents=True, exist_ok=True)
    import mlx.core as mx
    import numpy as np
    import soundfile as sf
    # mlx-audio's models package eagerly imports unrelated families. Limit
    # package discovery to Parakeet; its source and operations stay unchanged.
    base = Path(importlib.util.find_spec("mlx_audio").origin).parent
    namespace = types.ModuleType("mlx_audio.stt.models")
    namespace.__path__ = [str(base / "stt/models")]
    sys.modules[namespace.__name__] = namespace
    from fermion._speech._engine_phonon2 import load
    from mlx_audio.stt.models.parakeet.parakeet import log_mel_spectrogram
    loader = load("load_parakeet")
    started = time.perf_counter()
    model = loader.load_parakeet(a.container, a.config, dtype=mx.bfloat16, packed=True, scale_dtype=mx.float32)
    if a.benchmark:
        from fermion._speech.engine_phonon2 import apply_levers
        info = {}
        apply_levers(model, info)
        levers = info.get("levers", {})
        if levers.get("tdt16") != "installed" or levers.get("dense16", {}).get("densified_modules") != 264:
            raise RuntimeError(f"benchmark requires Fermion's default dense16+tdt16, found {info}")
        mx.eval(model.parameters())
        mx.synchronize()
        load_ms = (time.perf_counter() - started) * 1000
        clips = []
        for audio in a.audio:
            wave, sr = sf.read(audio, dtype="float32")
            if sr != 16000 or wave.ndim != 1:
                raise RuntimeError("benchmark clips must be 16 kHz mono")
            clips.append((audio.name, mx.array(wave)))
        first_pass = []
        for _ in range(max(a.warmup, 1)):
            for name, wave in clips:
                mx.synchronize()
                started = time.perf_counter()
                model.generate(wave, dtype=mx.bfloat16)
                mx.synchronize()
                first_pass.append({"audio": name, "ms": (time.perf_counter() - started) * 1000})
        rows = []
        for rep in range(a.benchmark):
            for name, wave in clips:
                mx.synchronize()
                started = time.perf_counter()
                result = model.generate(wave, dtype=mx.bfloat16)
                mx.synchronize()
                elapsed = (time.perf_counter() - started) * 1000
                rows.append({"rep": rep, "audio": name, "ms": elapsed, "text": result.text})
        print(json.dumps({"versions": versions, "device": mx.metal.device_info(), "levers": info,
                          "loadMs": load_ms, "warmup": first_pass, "rows": rows,
                          "memory": {"active": mx.get_active_memory(), "peak": mx.get_peak_memory(), "cache": mx.get_cache_memory()},
                          "sources": {str(p.relative_to(base)): sha(p) for p in (base / "stt/models/parakeet").glob("*.py")},
                          "producer_sha256": sha(Path(__file__))}))
        return
    # The loader installs Fermion's fp32 frontend wrapper.
    from mlx_audio.stt.models.parakeet.parakeet import log_mel_spectrogram
    rows = []
    for i, audio in enumerate(a.audio):
        wave, sr = sf.read(audio, dtype="float32")
        if sr != 16000 or wave.ndim != 1:
            raise RuntimeError("reference clips must be 16 kHz mono")
        mel = log_mel_spectrogram(mx.array(wave).astype(mx.bfloat16), model.preprocessor_config)
        enc, lengths = model.encoder(mel)
        projected = model.joint.enc(enc)
        mx.eval(mel, projected)
        result = model.decode(mel)[0]
        dumps = {}
        for name, array in (("mel", mel), ("encoder", projected)):
            filename = f"{i}.{name}.f32"
            np.asarray(array.astype(mx.float32)).tofile(a.output / filename)
            dumps[name] = {"file": filename, "sha256": sha(a.output / filename), "shape": list(array.shape)}
        rows.append({"audio": audio.name, "audio_sha256": sha(audio), "text": result.text,
                     "tokens": [{"id": t.id, "start": t.start, "duration": t.duration} for sentence in result.sentences for t in sentence.tokens], **dumps})
        print(audio.name, result.text, flush=True)
    sources = {str(p.relative_to(base)): sha(p) for p in (base / "stt/models/parakeet").glob("*.py")}
    manifest = {"versions": versions, "machine": platform.platform(), "device": mx.metal.device_info(),
                "producer_sha256": sha(Path(__file__)), "container_sha256": sha(a.container), "config_sha256": sha(a.config), "sources": sources, "rows": rows}
    path = a.output / "phonon2-reference.json"
    path.write_text(json.dumps(manifest, indent=2))
    print("manifest SHA256", sha(path), flush=True)


if __name__ == "__main__":
    main()
