"""Matched mlx-lm output-head/token-zero microbenchmark.

MODEL=/path/to/snapshot LAZY=0 /path/to/oracle/python qwen-token-zero-head.py
MODEL=/path/to/snapshot LAZY=1 /path/to/oracle/python qwen-token-zero-head.py
"""

import json
import os
import statistics
import time
from pathlib import Path

import mlx.core as mx
from mlx_lm.utils import load_model


model_path = os.environ.get("MODEL")
if not model_path:
    raise RuntimeError("set MODEL to a local Qwen3.8 snapshot")
lazy = os.environ.get("LAZY", "0") == "1"

load_started = time.perf_counter()
model, config = load_model(Path(model_path), lazy=lazy)
load_ms = (time.perf_counter() - load_started) * 1000
lm = model.language_model
head = lm.model.embed_tokens.as_linear if lm.args.tie_word_embeddings else lm.lm_head
hidden_size = lm.args.hidden_size
vocab_size = lm.args.vocab_size
hidden = mx.zeros((1, 1, hidden_size), dtype=mx.bfloat16)
mx.eval(hidden)


def head_and_sample():
    started = time.perf_counter()
    logits = head(hidden)
    logprobs = logits - mx.logsumexp(logits, axis=-1, keepdims=True)
    token_array = mx.argmax(logprobs, axis=-1)
    mx.eval(token_array)
    token = token_array.item()
    return (time.perf_counter() - started) * 1000, token


def head_only():
    started = time.perf_counter()
    logits = head(hidden)
    mx.eval(logits)
    return (time.perf_counter() - started) * 1000, logits


def sample_evaluated(logits):
    started = time.perf_counter()
    logprobs = logits - mx.logsumexp(logits, axis=-1, keepdims=True)
    token_array = mx.argmax(logprobs, axis=-1)
    mx.eval(token_array)
    token = token_array.item()
    return (time.perf_counter() - started) * 1000, token


print(json.dumps({
    "runtime": "mlx-lm",
    "model": model_path,
    "lazy": lazy,
    "loadMs": load_ms,
    "hiddenSize": hidden_size,
    "vocabSize": vocab_size,
    "tied": lm.args.tie_word_embeddings,
    "headType": type(lm.lm_head).__name__ if hasattr(lm, "lm_head") else "tied embedding",
}))

cold_ms, token = head_and_sample()
warm_e2e = [head_and_sample()[0] for _ in range(7)]
warm_head_ms, logits = head_only()
sample_times = []
for _ in range(7):
    sample_ms, token = sample_evaluated(logits)
    sample_times.append(sample_ms)

print(json.dumps({
    "coldHeadSampleMs": cold_ms,
    "warmHeadSampleMs": warm_e2e,
    "warmHeadSampleMedianMs": statistics.median(warm_e2e),
    "warmHeadOnlyMs": warm_head_ms,
    "warmSampleOnlyMs": sample_times,
    "warmSampleOnlyMedianMs": statistics.median(sample_times),
    "token": token,
}))
