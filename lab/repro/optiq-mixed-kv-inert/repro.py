# Static proof that `optiq serve --kv-config` never serves per-layer mixed
# KV on mlx-lm 0.31.3. Two independent defects in optiq 0.2.4's
# install_mixed_kv (optiq/serve.py:77):
#
#   A. SHADOWED-MODULE PATCH: the per-layer quantize hook is assigned to
#      `mlx_lm.generate` obtained via `import mlx_lm.generate as gen_mod`
#      (optiq/serve.py:167) — but mlx_lm/__init__.py:10 rebinds the package
#      attribute `generate` to the generate() FUNCTION, and `import a.b as c`
#      binds getattr(a, "b") on Python >= 3.7. The setattr lands on that
#      function object; the module global `maybe_quantize_kv_cache` that
#      generate_step actually calls (generate.py:380) stays STOCK. Net: the
#      non-batch serve path quantizes UNIFORMLY at trigger_bits (the
#      injected kv_bits, serve.py:176-182), not per the kv_config map.
#
#   B. DEAD PATH UNDER BATCHING: the only hook that does land,
#      mlx_lm.server.stream_generate (optiq/serve.py:182), is consumed
#      solely by ResponseGenerator._serve_single (mlx_lm/server.py:976).
#      The server routes every request that is batchable — text-only, no
#      draft model, mergeable caches, and NO `seed` in the request body
#      (server.py:686) — through BatchGenerator (server.py:813-826), which
#      never calls stream_generate or any quantize hook. Net: seedless chat
#      requests are served plain bf16 KV.
#
# No model is downloaded or loaded — the proof is inspect-based.
#
# Run with the oracle venv:
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python repro.py
import importlib
import inspect

import mlx_lm  # noqa: F401  (runs __init__, which installs the shadowing)

gen_mod = importlib.import_module("mlx_lm.generate")
server_mod = importlib.import_module("mlx_lm.server")
from optiq.serve import _LayerQuantConfig, install_mixed_kv  # noqa: E402

# --- Defect A: the per-layer hook never lands on the module -----------------
shadow = mlx_lm.generate  # the attribute optiq's `import mlx_lm.generate` binds
assert not inspect.ismodule(shadow) and callable(shadow), "expected the shadowing function"
orig_hook = gen_mod.maybe_quantize_kv_cache
orig_stream = server_mod.stream_generate

install_mixed_kv([_LayerQuantConfig(layer_idx=0, bits=8, group_size=64)], 0)

assert gen_mod.maybe_quantize_kv_cache is orig_hook, "module hook unexpectedly patched"
assert getattr(shadow, "maybe_quantize_kv_cache", None) is not None, (
    "patch did not land on the shadowing function either?"
)
assert server_mod.stream_generate is not orig_stream, "server stream not patched"
print(
    "[A] install_mixed_kv left mlx_lm.generate.maybe_quantize_kv_cache (the\n"
    "    module global generate_step calls, generate.py:380) UNPATCHED; the\n"
    "    per-layer hook landed as an attribute on the shadowing generate()\n"
    "    function (mlx_lm/__init__.py:10). Only mlx_lm.server.stream_generate\n"
    "    was really patched — it injects a uniform kv_bits, so seeded/\n"
    "    non-batch requests get STOCK uniform quantization, not the map."
)

# --- Defect B: the batched path references neither patched name -------------
for cls in (
    gen_mod.BatchGenerator,          # generate.py:1486
    gen_mod.PromptProcessingBatch,   # generate.py:1004
    gen_mod.GenerationBatch,         # generate.py:1229
):
    src = inspect.getsource(cls)
    assert "maybe_quantize_kv_cache" not in src, cls.__name__
    assert "stream_generate" not in src, cls.__name__
    # Stronger: the batch path contains no quantization logic at all.
    assert "quantiz" not in src.lower(), cls.__name__
assert "kv_bits" not in inspect.signature(gen_mod.BatchGenerator.__init__).parameters
print(
    "[B1] BatchGenerator / PromptProcessingBatch / GenerationBatch contain no\n"
    "     reference to either patched name — no 'quantiz' substring at all —\n"
    "     and BatchGenerator.__init__ has no kv_bits parameter."
)

rg = server_mod.ResponseGenerator
assert "args.seed is None" in inspect.getsource(rg._is_batchable)   # server.py:686
gen_src = inspect.getsource(rg._generate)
assert "BatchGenerator(" in gen_src                                 # server.py:821
assert "_serve_single" in gen_src                                   # server.py:813-815
assert "stream_generate(" not in gen_src
assert "stream_generate(" in inspect.getsource(rg._serve_single)    # server.py:976
print(
    "[B2] mlx_lm.server routing: _is_batchable = batchable model AND\n"
    "     args.seed is None (server.py:686); batchable -> BatchGenerator\n"
    "     (server.py:821); only the non-batch fallback _serve_single calls\n"
    "     the patched stream_generate (server.py:976)."
)

print(
    "\nCONCLUSION: under `optiq serve --kv-config` on mlx-lm 0.31.3, a\n"
    "seedless text chat request on a stock text model (mergeable caches,\n"
    "cache.py:397/581) is served PLAIN bf16 KV, and even a seeded request\n"
    "gets UNIFORM max-bits quantization — the per-layer mixed-precision\n"
    "scheme is never applied by the server."
)
