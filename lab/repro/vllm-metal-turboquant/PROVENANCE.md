# Provenance — vendored vllm-metal TurboQuant reference

**Source URL:** `https://raw.githubusercontent.com/vllm-project/vllm-metal/main/vllm_metal/attention/caches/turboquant.py`

**Fetched:** 2026-07-06, via `curl` against `raw.githubusercontent.com` (HTTP 200).

**`main` HEAD at fetch time:** `cd72e7d6d5c3eec452afe2693c3a45a0564d7650`.

**Last commit that touched this exact file (via `gh api
repos/vllm-project/vllm-metal/commits?path=...&sha=main`):**
`ef776cacac8f8a4219e5e23fc0b50fa72d37d22c` — "[Refactor] Refactor attention
abstraction (#412)", 2026-06-04. That PR moved the file from
`metal_kernel_backend/turboquant.py` to its current path
(`vllm_metal/attention/caches/turboquant.py`) via `git mv`; the module's
logic is unchanged by the move (pure reorg, per the PR description: "57
files changed, +472/−430 — a near-wash, mostly moves + import rewiring").

**File identity:** 557 lines, byte-identical to what `curl` returned —
`turboquant_reference.py` in this directory is an exact copy, not
retyped or reformatted. Confirms the research dossier's independent
transcription (`research-refImpl.md` Part 1) matches the live source
line-for-line, including the `CENTROIDS_3BIT`/`BOUNDARIES_3BIT` constants,
the `quantize()`/`dequantize()` asymmetric-affine key path, the
`fwht()`/`lm_quant()`/`lm_de_quant()` value path, and all `_pack_*bit`/
`_unpack_*bit` helpers.

## Why it's vendored

**Golden generation only.** This file is never imported by the mlx-bun
product (`src/`). It is driven exclusively by
`lab/repro/vllm-metal-turboquant/gen_goldens.py`, which is in turn invoked
only by `scripts/regen-turboquant-goldens.ts` through the oracle venv
python (`/Users/joshrossi/Code/mlx-lm/.venv/bin/python`, mlx 0.31.2). Its
role is identical to `optiq/runtime/fused_quant_sdpa.py` in the
`scripts/regen-kvq-goldens.ts` pattern: a pure-MLX Python reference used
once, offline, to produce bit-exact `goldens/turboquant.json` and the
generated TypeScript constants table (`src/mlx/turboquant-tables.ts`). The
TS port (`src/mlx/turboquant-ops.ts`, forthcoming) is verified AGAINST
these goldens; it never calls into this file or any vllm_metal package at
runtime.

## Shims required to run it standalone

The only import in the file that isn't satisfied by a bare `mlx` install is:

```python
from vllm.logger import init_logger
logger = init_logger(__name__)
```

`gen_goldens.py` stubs this with a `sys.modules["vllm"]` /
`sys.modules["vllm.logger"]` fake package (a module exposing
`init_logger(name) -> logging.Logger`) installed **before** importing
`turboquant_reference`, so the vendored file's `import` line resolves
without pulling in the actual `vllm` package (which is not installed in
the oracle venv and is unrelated to this task — only its logger shim is
needed). `logger.warning(...)` is called from `_compute_lloyd_max_normal`
only on non-convergence within 500 Lloyd-Max iterations; the stub's
`logging.Logger.warning` is fully functional so this path works
identically to the real `vllm.logger` if it ever fires.

No other shims are needed — every other symbol used
(`mx.random.key/randint/normal`, `mx.hadamard_transform`, `mx.clip`,
`mx.round`, `mx.arange`, `mx.linspace`, `mx.where`, array indexing/
reshape/stack/concatenate) is stock `mlx.core`, already a dependency of
the oracle venv.

## Non-goals

- This file is NOT part of the mlx-bun build (`src/`, `scripts/*` outside
  the two generation scripts named above never import it).
- It is not kept in sync with upstream beyond this one fetch — if
  vllm-metal changes the algorithm, re-run the fetch step above and
  re-generate goldens; do not hand-edit this file to "fix" anything
  (bugs/quirks in the reference, e.g. the fp16 `+1e-8` epsilon underflow
  noted in `docs/design/turboquant-kv.md`, are intentionally preserved
  because our port's correctness oracle is "matches what this file
  actually computes," not "matches what it should compute").
