"""Direct mlx-lm replay of the 2,048-token server prefill boundary."""

import json
import os
import time
from pathlib import Path

import mlx.core as mx
from mlx_lm.utils import load_model


model_path = os.environ.get("MODEL")
if not model_path:
    raise RuntimeError("set MODEL to a local Qwen3.8 snapshot")
n = int(os.environ.get("PROMPT_TOKENS", "1125"))

model, _ = load_model(Path(model_path), lazy=False)
prompt = mx.array([1000 + (i % 10000) for i in range(n)])


def active():
    return {
        "activeBytes": mx.metal.get_active_memory(),
        "cacheBytes": mx.metal.get_cache_memory(),
        "peakBytes": mx.metal.get_peak_memory(),
    }


def replay(label, tokens):
    cache = model.make_cache()
    started = time.perf_counter()
    model(tokens[:-1][None], cache=cache)
    mx.eval([c.state for c in cache])
    mx.clear_cache()
    prefill_ms = (time.perf_counter() - started) * 1000
    before = active()

    started = time.perf_counter()
    logits = model(tokens[-1:][None], cache=cache)
    logits = logits[:, -1, :]
    logprobs = logits - mx.logsumexp(logits, axis=-1, keepdims=True)
    token_array = mx.argmax(logprobs, axis=-1)
    if os.environ.get("PIPELINE") == "1":
        mx.async_eval(token_array, logprobs)
        logits_1 = model(token_array[:, None], cache=cache)
        logits_1 = logits_1[:, -1, :]
        logprobs_1 = logits_1 - mx.logsumexp(logits_1, axis=-1, keepdims=True)
        token_1 = mx.argmax(logprobs_1, axis=-1)
        mx.async_eval(token_1, logprobs_1)
    mx.eval(token_array)
    token = token_array.item()
    token_zero_ms = (time.perf_counter() - started) * 1000
    print(json.dumps({
        "label": label,
        "promptTokens": tokens.size,
        "prefillMs": prefill_ms,
        "tokenZeroMs": token_zero_ms,
        "memoryBeforeTokenZero": before,
        "memoryAfterTokenZero": active(),
        "token": token,
    }))


replay("warmup", prompt[:2])
replay("measured", prompt)
