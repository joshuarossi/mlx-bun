#!/usr/bin/env python3
"""Replay a captured scheduler protocol through pinned mlx-lm cache operations.

Input on stdin: model path and schedules of solo/batch forward inputs with
sampled row/step identities. Outputs SHA-256 of every sampled float32 logit
vector. No native-output values are provided to this oracle. Cache operations
are mlx-lm's merge/extend/filter APIs (MIT, ml-explore/mlx-lm).
"""
import hashlib
import json
import sys

import numpy as np
from optiq.mlx_lm_patches._register import register

register()
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import (
    BatchKVCache, BatchRotatingKVCache, KVCache, RotatingKVCache, make_prompt_cache,
)


def replay(model, frames):
    solo = {}
    prepared = []
    active = []
    batch = None
    results = []
    for frame in frames:
        row = frame["row"]
        if row is not None:
            if row not in solo:
                solo[row] = make_prompt_cache(model)
            cache = solo[row]
            rows = [row]
        else:
            new = [r for r in prepared if r not in active]
            if new:
                joined = []
                for layer in zip(*(solo[r] for r in new)):
                    cls = (BatchRotatingKVCache if isinstance(layer[0], RotatingKVCache)
                           else BatchKVCache)
                    joined.append(cls.merge(layer))
                if batch is None:
                    batch = joined
                else:
                    for current, addition in zip(batch, joined):
                        current.extend(addition)
                active.extend(new)
            width = frame["shape"][0]
            if width < len(active):
                # This fixture's increasing output caps retire oldest rows first.
                keep = list(range(len(active) - width, len(active)))
                for c in batch:
                    c.filter(mx.array(keep))
                active = [active[i] for i in keep]
                prepared = list(active)
            cache = batch
            rows = active
        # The serving policy uses scalar-position full-attention caches when
        # no row is padded. Derive eligibility from the reference state itself.
        # Rotating caches retain their per-row positions even at B=1.
        forward_cache = list(cache)
        scalar_full = []
        for index, c in enumerate(cache):
            if isinstance(c, BatchKVCache) and all(p == 0 for p in c.left_padding.tolist()):
                scalar = KVCache()
                scalar.keys, scalar.values, scalar.offset = c.keys, c.values, c._idx
                forward_cache[index] = scalar
                scalar_full.append((c, scalar))
        logits = model(mx.array(frame["ids"]).reshape(frame["shape"]), cache=forward_cache)
        mx.eval(logits, [c.state for c in forward_cache])
        for c, scalar in scalar_full:
            c.keys, c.values, c._idx = scalar.keys, scalar.values, scalar.offset
            c.offset = mx.full(c.offset.shape, scalar.offset, dtype=c.offset.dtype)
        for sample in frame["samples"]:
            values = np.array(logits[rows.index(sample["row"]), -1].astype(mx.float32))
            results.append({**sample, "hash": hashlib.sha256(values.tobytes()).hexdigest()})
            if sample["step"] == 0 and sample["row"] not in prepared:
                prepared.append(sample["row"])
    return results


def main():
    plan = json.load(sys.stdin)
    model, _ = load(plan["model"], adapter_path=plan.get("adapter"))
    print(json.dumps([replay(model, frames) for frames in plan["schedules"]]))


if __name__ == "__main__":
    main()
