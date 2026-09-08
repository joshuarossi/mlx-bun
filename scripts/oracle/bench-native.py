"""Pinned mlx-lm half of scripts/bench/native.ts. No downloads or server."""
import argparse
import gc
import hashlib
import importlib.metadata
import json
from pathlib import Path
import platform
import time

import mlx.core as mx
from mlx_lm import load
from mlx_lm.generate import generate_step, generation_stream, wired_limit

parser = argparse.ArgumentParser(description=__doc__)
for name in ("model-path", "prompt-ids", "json"):
    parser.add_argument("--" + name, required=True)
for name, default in (("tokens", 64), ("samples", 5), ("warmup", 1), ("prefill-chunk", 2048)):
    parser.add_argument("--" + name, type=int, default=default)
parser.add_argument("--clear-before-request", action="store_true")
args = parser.parse_args()
if not Path(args.model_path, "config.json").is_file():
    parser.error("--model-path must be an existing local artifact")
if args.tokens < 1 or args.samples < 1 or args.warmup < 0 or args.prefill_chunk < 1:
    parser.error("invalid measurement counts")
ids = json.loads(Path(args.prompt_ids).read_text())
report = {"oracle": {"python": platform.python_version(),
    "mlx": importlib.metadata.version("mlx"), "mlxLm": importlib.metadata.version("mlx-lm"),
    "device": mx.metal.device_info()}, "warmups": [], "samples": []}
out = Path(args.json)
out.parent.mkdir(parents=True, exist_ok=True)
def save(): out.write_text(json.dumps(report, indent=2) + "\n")
save()
try:
    model, tokenizer = load(args.model_path)
    eos = set(tokenizer.eos_token_ids)
    report["eosTokenIds"] = sorted(eos)
    report["memoryPolicy"] = {"wiring": "scoped-recommended",
        "wiredLimitBytes": mx.device_info()["max_recommended_working_set_size"],
        "clearBeforeRequest": args.clear_before_request,
        "note": "Uses mlx-lm's request-scoped wired_limit, including stream synchronization before restoration."}
    save()
    def run():
        memory_before = {"activeBytes": mx.get_active_memory(), "cacheBytes": mx.get_cache_memory()}
        mx.reset_peak_memory()
        start = time.perf_counter()
        if args.clear_before_request: mx.clear_cache()
        tokens, first = [], None
        with wired_limit(model, [generation_stream]):
            gen = generate_step(mx.array(ids, dtype=mx.int32), model,
                max_tokens=args.tokens, prefill_step_size=args.prefill_chunk)
            try:
                for token, _ in gen:
                    if token in eos: break
                    if first is None: first = (time.perf_counter() - start) * 1000
                    tokens.append(token)
            finally:
                gen.close()
                mx.synchronize(generation_stream)
        wall_ms = (time.perf_counter() - start) * 1000
        return {"wallMs": wall_ms, "firstTokenMs": first,
            "tokens": tokens, "finishReason": "stop" if len(tokens) < args.tokens else "length",
            "peakBytes": mx.get_peak_memory(), "memoryBefore": memory_before,
            "memoryAfter": {"activeBytes": mx.get_active_memory(), "cacheBytes": mx.get_cache_memory()}}
    for _ in range(args.warmup): report["warmups"].append(run()); save()
    for _ in range(args.samples): report["samples"].append(run()); save()
    import mlx_lm.models.qwen3_5 as qwen
    import importlib
    generate_module = importlib.import_module("mlx_lm.generate")
    report["oracle"]["sourceFiles"] = {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in (Path(qwen.__file__), Path(generate_module.__file__))}
    del model, tokenizer
    gc.collect()
    mx.clear_cache()
    report["complete"] = True
except Exception as error:
    report["complete"] = False
    report["error"] = repr(error)
    raise
finally:
    save()
