# mlx-optiq bug report — DRAFT, not yet filed

> Found 2026-07-06 during an adversarial review of a serve-mode h2h
> benchmark: the `optiq (mixed)` server arm's decode rate and RSS were
> byte-for-byte the mlx-lm bf16 fingerprint. Static repro in this
> directory (`repro.py`, runs against the oracle venv, loads no model).
> All file:line references below are from the installed packages in
> `/Users/joshrossi/Code/mlx-lm/.venv/lib/python3.14/site-packages/`.

---

**Title:** `optiq serve --kv-config` never applies per-layer mixed KV on
mlx-lm 0.31.3 — bf16 on the batched server path, uniform max-bits on the
non-batched one

## Environment

- mlx-optiq 0.2.4 AND 0.2.15 (re-verified live after upgrading — same
  behavior on both), mlx-lm 0.31.3, mlx 0.31.2
- Note the contradiction: 0.2.15 declares `mlx-lm>=0.31.3` and the docs
  (mlx-optiq.com/docs/serve) promise `--kv-config` serve-side
  mixed-precision KV with large peak-memory reductions — but on the
  mlx-lm the package itself requires, no batchable request ever reaches
  the quantization hooks (runtime-verified with spies: zero quantize
  calls across an 11.9k-token seedless request on 0.2.15).
- Python 3.14, macOS arm64 (behavior is not platform-specific; defect A
  is Python >= 3.7 import semantics, defect B is mlx-lm routing)

## What happens

`optiq serve --kv-config kv_config.json` starts, logs the mixed-precision
summary, and then serves every ordinary chat request with a plain bf16 KV
cache. Memory and tok/s match a `--kv-bits`-less `mlx_lm.server` exactly.
Two independent defects in `install_mixed_kv` (optiq/serve.py:77) combine
so that the advertised per-layer scheme is never applied by the server:

### Defect A — the per-layer hook lands on a shadowed attribute, not the module

`install_mixed_kv` does (optiq/serve.py:99, :167):

```python
import mlx_lm.generate as gen_mod
...
gen_mod.maybe_quantize_kv_cache = patched_maybe_quantize
```

But `mlx_lm/__init__.py:10` (`from .generate import batch_generate,
generate, stream_generate`) rebinds the package attribute `generate` to
the `generate()` **function**, shadowing the submodule — and on
Python >= 3.7, `import a.b as c` binds `getattr(a, "b")`. So `gen_mod` is
the function object and the setattr decorates *it*, while the module
global `maybe_quantize_kv_cache` that `generate_step` actually calls
(mlx_lm/generate.py:299, consumed at generate.py:380 and, for
speculative decoding, generate.py:538) stays stock.

The second half of the installer (optiq/serve.py:169-182) *does* land:
it wraps `mlx_lm.server.stream_generate` and injects
`kv_bits=trigger_bits` (the max bits in the config). Net effect on any
request that reaches `stream_generate`: mlx-lm's **stock uniform**
`maybe_quantize_kv_cache` runs at `trigger_bits` — quantized, but not
per-layer, and at the *most generous* width in the map.

### Defect B — mlx-lm 0.31.3's server routes ordinary requests around `stream_generate` entirely

The only hook that lands is on `mlx_lm.server.stream_generate`, whose
sole consumer is the non-batched fallback
`ResponseGenerator._serve_single` (mlx_lm/server.py:922, call at
server.py:976). But mlx-lm 0.31.3 routes requests through continuous
batching by default:

- `_is_batchable` (server.py:685-686): `self.model_provider.is_batchable
  and args.seed is None`.
- `is_batchable` (server.py:371-374): no draft model AND every cache
  implements `merge` — true for all stock text models, including
  sliding-window ones (`KVCache.merge` cache.py:397,
  `RotatingKVCache.merge` cache.py:581).
- Batchable requests go to `BatchGenerator` (server.py:813-826;
  class at generate.py:1486); only non-batchable ones fall back to
  `_serve_single` (server.py:813-815).

`BatchGenerator`, `PromptProcessingBatch` (generate.py:1004), and
`GenerationBatch` (generate.py:1229) contain **no reference to
`maybe_quantize_kv_cache`, no `kv_bits` parameter, no quantization logic
at all** (there is no `quantiz` substring anywhere in generate.py between
the batch classes' start and `main()`). So for every seedless text chat
request — i.e. the normal case — *neither* optiq hook is reached and the
KV cache is plain bf16.

## Repro

1. `optiq serve --model <any text model> --kv-config kv_config.json`
   (startup logs the mixed-precision summary — looks armed).
2. Send a **seedless** streamed chat completion and a long prompt.
   Observe: RSS/decode identical to stock `mlx_lm.server` bf16; no quant
   conversion cost at the quantize boundary; `patched_maybe_quantize`
   never executes (add a print inside it — it never fires).
3. Contrast: send a request with `"seed": 0` as the FIRST request. It
   routes to `_serve_single` and the KV **is** quantized — and then the
   next seedless request **crashes the generation worker** (defect C).
4. Static, model-free proof of defects A+B: `python repro.py` with
   mlx-lm 0.31.3 + mlx-optiq 0.2.4 or 0.2.15 installed (this directory).

## Defect C — a seeded request poisons the shared prompt cache and crashes the batch worker

Live-verified 2026-07-06 (MiniCPM5-1B-OptiQ-4bit, macOS arm64): start
`optiq serve --kv-config`, send one `"seed": 0` chat request (routes to
`_serve_single`, quantizes its KV), then one ordinary seedless request.
The second request pulls the quantized entry back out of the server's
shared `LRUPromptCache` and hands it to `BatchGenerator`:

```
File ".../mlx_lm/generate.py", line 880, in _merge_caches
ValueError: <class 'mlx_lm.models.cache.QuantizedKVCache'> does not yet
support batching with history
```

— the generation worker dies and the server stops answering. So the seed
knob is not a workaround for defect B; it converts silent-bf16 into a
denial of service.

## Runtime verification (2026-07-06)

Instrumented run (spies wrapped around the real
`mlx_lm.generate.maybe_quantize_kv_cache` module global and
`KVCache.to_quantized`, installed via `sys.modules` before
`optiq.cli`): across an 11.9k-token seedless streamed request, **zero**
quantization calls — defect B confirmed at runtime, the batch path
serves bf16. A seeded-first request produced a `QuantizedKVCache` in the
prompt cache (per the defect-C crash) while BOTH spies stayed silent —
so the seeded path quantizes through neither the stock uniform hook nor
`KVCache.to_quantized`, and the "uniform max-bits" characterization
above is NOT confirmed; which converter actually runs on that path needs
one more instrumented pass before filing.

## Suggested fix direction

optiq's own VLM installer already solves defect B:
`install_vision_serving` patches `ResponseGenerator._is_batchable` to
force its requests off the batch path, with the comment "batch bypasses
stream_generate" (optiq/serve.py:448-456). `install_mixed_kv` (and
`install_quantized_kv`, optiq/serve.py:52 — same single-hook design,
same dead path) should either do the same while KV-quant is installed,
or grow a `BatchGenerator`-aware hook.

For defect A, patch the real module:
`importlib.import_module("mlx_lm.generate").maybe_quantize_kv_cache = ...`
(or `from mlx_lm import generate as ...` is equally shadowed — importlib
is the unambiguous spelling). Note the tooling knows about the
shadowing implicitly: optiq's eval path re-injects kwargs
(optiq/cli.py:722 "install_mixed_kv only patches
mlx_lm.server.stream_generate") — with defect A fixed, that mirror still
works because the patched hook ignores `kv_bits`.
