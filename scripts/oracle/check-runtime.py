"""Reference subprocess for tests/parity/runtime-oracle.test.ts; never inference tooling."""
import os

if os.environ.get("MLX_BUN_TEST_RUNTIME_ORACLE") != "1":
    raise RuntimeError("Set MLX_BUN_TEST_RUNTIME_ORACLE=1 to run this oracle worker")

import gc
import hashlib
import json
import sys

import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import ArraysCache, make_prompt_cache

with open(sys.argv[1]) as stream:
    plan = json.load(stream)
assert mx.__version__ == plan["runtime"], (mx.__version__, plan["runtime"])
with open(os.path.join(plan["model"], "config.json"), "rb") as stream:
    config_sha256 = hashlib.sha256(stream.read()).hexdigest()


def array(value):
    raw = mx.contiguous(value).view(mx.uint8)
    mx.eval(raw)
    return dict(shape=list(value.shape), dtype=str(value.dtype).split(".")[-1],
                sha256=hashlib.sha256(bytes(memoryview(raw))).hexdigest())


def state(caches, count):
    result = []
    for cache in caches:
        recurrent = isinstance(cache, ArraysCache)
        offset = count if recurrent else cache.offset
        assert offset == count
        arrays = cache.state if recurrent or offset else []
        result.append(dict(recurrent=recurrent, offset=offset,
                           arrays=[array(value) for value in arrays if value is not None]))
    return result


model, tokenizer = load(plan["model"], lazy=True)
rows = []
try:
    for context in plan["contexts"]:
        for length in plan["lengths"]:
            caches = make_prompt_cache(model)
            try:
                for pos in range(0, context, plan["prefixChunk"]):
                    count = min(plan["prefixChunk"], context - pos)
                    ids = mx.array([[100 + (pos + i) * 7 % 1000 for i in range(count)]], dtype=mx.int32)
                    logits = model(ids, cache=caches)
                    mx.eval(logits, [cache.state for cache in caches])
                    del logits, ids
                    mx.clear_cache()
                prefix = state(caches, context)
                ids = mx.array([[600 + i * 3 for i in range(length)]], dtype=mx.int32)
                logits = model(ids, cache=caches)
                row = dict(context=context, m=length, prefix=prefix, logits=array(logits),
                           state=state(caches, context + length))
                del logits, ids
                logits = model(mx.array([[911]], dtype=mx.int32), cache=caches)
                row["continuation"] = array(logits)
                row["continuationState"] = state(caches, context + length + 1)
                del logits
                rows.append(row)
            finally:
                del caches
                mx.synchronize()
                mx.clear_cache()
finally:
    del model, tokenizer
    gc.collect()
    mx.synchronize()
    mx.clear_cache()

with open(sys.argv[2], "w") as stream:
    json.dump(dict(runtime=mx.__version__, configSha256=config_sha256, rows=rows,
                   activeAfter=mx.get_active_memory()), stream)
