# Faithful → L1: consolidating the "match mlx-lm" path

> **2026-07-05 addendum:** the Phase-1 deletion pass executed —
> fused-gelu/fused-swiglu/perf-kernel/fused-decode/CPM5_FAITHFUL deleted, `--l3`
> removed ([unified-engine-frontier-plan.md §6](unified-engine-frontier-plan.md)).
> The flag tables below are the historical decision record.

**Status:** PLANNED (2026-07-04). Written after the 2026-07-04 audit of the
`MLX_BUN_FAITHFUL` work (commit `fd8ff5f`). The faithful kernels are correct and
proven byte-identical to mlx-lm — but they were wired as a *parallel base-preset
axis* rather than folded into the L1 parity regime, which (a) abandons the
model-specific optimized files and (b) leaves the preset incomplete. This doc is
the contract for fixing that. Companion memory:
`faithful-is-the-l1-implementation`. Framing: [parity-tier-dag.md](parity-tier-dag.md),
`three-level-fidelity-tree-model` (memory).

## The governing framing (two orthogonal axes)

1. **Parity** — a *guarantee about which oracle you reproduce bit-for-bit*, full
   logprobs (not just greedy argmax). **L1 = mlx-lm, L2 = mlx-optiq, L3 = no
   oracle.** A config *is* L1 by definition iff its output matches mlx-lm bit-for-bit.
   Nothing about parity concerns speed or methodology.
2. **Performance / implementation** — orthogonal. Within a regime there are many
   valid implementations (faster/slower, more/less memory). For a given regime we
   **default-serve the fastest implementation that still holds the guarantee**; a
   user overrides individual kernels with extra flags (`--l1 --fused-geglu`).

**Where "faithful" fits:** it is *the fastest known implementation of L1* — it runs
mlx-lm's own exact kernels, so it's bit-exact, and per the 2026-07-03 h2h it is
faster than our previous L1 path (the old "perf" path was net-SLOWER than mlx-lm:
12B 0.88×, cpm5 0.95×, perf-kernel HURT e4b 0.62×). So faithful should become
**`--l1`'s default implementation**, not a new naked default and not a third
selection system.

**Naked `mlx-bun` (no flags) is unchanged:** best experience for local AI on a Mac —
fastest / most-intelligent / most-memory-efficient, no parity worries. The user who
needs the mlx-lm drop-in guarantee reads the docs and passes `--l1`.

> **SUPERSEDED 2026-07-05 — naked default is now `--l1`.** The full h2h pass
> (benchmarks-h2h-2026-07-05, M1 Max 32GB) showed the L1 faithful kernel set at
> exact speed parity with mlx-lm (1.00×) on cpm5/e4b/12B while every
> output-changing lever failed to beat it in a paired A/B: fused-decode 1.00×,
> fused-gelu +0–1%, the perf arm 0.62–0.93× on e4b (its one win, 12B @16k +6%,
> carried a KL WARN), and quantized KV 5–20% slower decode than bf16 at ≤16k on
> BOTH stacks (mlx-lm's own kv8 trails its bf16). "Best experience" and "L1"
> turned out to be the same thing today. Decision: naked = the l1 preset
> (`applyDecodeRoute` defaults the tier), quantized KV and every non-faithful
> kernel are opt-in (`--l2`/`--l3`/per-fork flags), and the L1 baseline is the
> base all future optimization must beat in a paired A/B to earn a default.

**`--l1/--l2/--l3` are pure ALIASES, not modes.** Each expands to a fixed set of the
individual per-fork flags — [`applyDecodeRoute`, cli.ts:752](../../src/cli.ts) just
`set()`s env vars, and a per-fork flag overrides the alias. Two invariants follow,
and they are the real design bar:

- **A user can reproduce any tier byte-for-byte by passing the individual flags.**
  `--l1` is nothing but "the fastest parity-holding value of each flag."
- **No preset may set anything that isn't also an individual flag.** There is exactly
  one bundle per tier; nothing bypasses the flag layer.

`MLX_BUN_FAITHFUL` violates both — it is a *second bundle* that sets choices
(compiled-geglu, `compiledLogitSoftcap`) which are **not exposed as flags at all**, so
`--l1` can neither reproduce nor reach them. Corollary: bit-exact-to-mlx-lm actually
*wants* compiled activations (mlx-lm itself `@mx.compile`s geglu/swiglu), so the
current `--l1` "unfused" description is backwards — **compiled is the L1 default**
(bit-exact + faster); unfused is a slower, same-parity opt-in.

## What is actually wrong today

Three overlapping "match mlx-lm" mechanisms exist and disagree:

- **Tier system** `--l1/--l2/--l3` ([`applyDecodeRoute`, cli.ts:752](../../src/cli.ts))
  — the correct axis, but `--l1` keeps `compiled-decode` on, leaves
  `MLX_BUN_FUSED_GELU` on (custom metal geglu, divergent), and does **not** route to
  the faithful compiled-geglu. So today `--l1` is not actually bit-exact for gemma.
- **`MLX_BUN_FAITHFUL` preset** ([faithful.ts](../../src/faithful.ts)) — flips a
  *different, smaller* set of defaults and **forces the gemma monolith**
  ([factory.ts:51](../../src/model/factory.ts)), abandoning the generated
  `gemma4-12b/e4b/26b` specialization. It also leaves `MLX_BUN_PERF_KERNEL` on
  (fires on every quantized-KV/OptiQ model), leaves kv-quant on, and never sets
  `MLX_BUN_CPM5_FAITHFUL` — so `=1` is neither a real L1 guarantee on OptiQ models
  nor faithful for MiniCPM5.
- **`Faithful*` subclasses** — `FaithfulMiniCPM5` (wired), and `FaithfulGemma4` /
  `FaithfulQwen3` / `FaithfulQwen35` / `FaithfulUniversalDense` (**unwired** — their
  headers claim factory dispatch that does not exist; `MLX_BUN_UNIVERSAL_FAITHFUL`
  lives only in a comment).

Two of these violate stated principles: **forcing the monolith** runs an optimized
model through the generic path (rejected), and the **preset is incomplete**.

Only `qwen3_moe` did it right: the production class **is** the faithful port, so it's
bit-exact-by-construction with no flag. That is the pattern to generalize.

### Current-state flag reference

| Flag | Default | Diverges from mlx-lm? | Notes |
|---|---|---|---|
| `MLX_BUN_PERF_KERNEL` | **ON** | **yes** — original kernel, not bit-exact | fires only on quantized KV; output-changing → L3-only |
| kv-quant | **config** for OptiQ | uniform=mlx-lm has it; mixed=optiq-only | off (bf16)=L1; uniform 4\|8=L1 in the L1 set (unfused SDPA == mlx-lm base.py); config (mixed)=L2 |
| `MLX_BUN_COMPILED_DECODE` | ON | no (whole-decode fusion, bit-exact) | structural; off in faithful preset |
| `MLX_BUN_FUSED_GELU` | ON | **yes** — custom metal geglu ≠ compiled geglu | output-changing vs mlx-lm dispatch |
| `MLX_BUN_FUSED_DECODE` | off | yes | L>1 only |
| `MLX_BUN_NO_FUSED_SDPA` | fused **on** | no — `ops.sdpa` is mlx's own kernel | faithful-aligned |
| `MLX_BUN_COMPILED_SWIGLU` | ON | no — matches mlx-lm `@mx.compile` | faithful-aligned |

The genuinely output-changing, must-be-off-for-L1 levers: **perf-kernel, kv-quant,
custom fused-gelu, fused-decode.** Compiled activations and `ops.sdpa` are
faithful-aligned and should stay on.

**Fork coverage gap.** `applyDecodeRoute` exposes only four forks —
`--compiled-decode`, `--perf-kernel`, `--fused-decode`, `--fused-sdpa`. The
activation-fusion choice (compiled-geglu vs custom fused-gelu; compiled-swiglu /
`useCompiledActivation`) has **no CLI fork** and is not in the TIERS presets. So the
alias invariant is broken: `--l1` cannot select the faithful compiled activation, and
you cannot reproduce the faithful setup with individual flags — only the out-of-band
`MLX_BUN_FAITHFUL` reaches it. Closing this gap is the crux of the fix.

## The decisive rule: "compiled" = L1, custom "fused" = L3

The whole flag pile collapses to one distinction, verified in-source 2026-07-04:

- **"compiled" kernels** (`@mx.compile` geglu/swiglu, `compiled-decode`) go through
  the **same libmlx** as mlx-lm → same graph → same kernel → **bit-exact**. These are
  the faithful kernels. L1-valid AND faster (they remove per-op host tax).
- **custom "fused" Metal kernels** are mlx-bun ORIGINALS, each with a proven residual
  vs mlx-lm → **NOT bit-exact → L3 only**:
  - `fused-gelu-kernel.ts` header: *"Still a perf kernel (not bit-exact)… the only
    residual is the pow/tanh math-lib difference"* (bit-exact vs our OWN unfused
    path, kl=0 — but not vs mlx-lm's math lib).
  - `fused-swiglu-kernel.ts`: MATCH variant *"Only residual: the metal exp() vs MLX's
    math lib"*; F32 variant *"NOT bit-exact → L3"*. Default off.
  - `fused-decode-kernel.ts` (`PERF_KERNEL`): online-softmax, envelope-gated, quant-KV
    only. Not bit-exact by construction.
- **kv-quant** is a cache-precision axis, not a kernel, and it is NOT a clean
  L1↔L2 boundary. **off (bf16) → L1**. **uniform `4|8` → L1** in the L1 kernel set
  (`--l1 --kv-quant 8` = fused-sdpa off + perf off): mlx-bun's `quantizedSdpaUnfused`
  (gemma4-base.ts) is **op-for-op identical** to mlx-lm's
  `quantized_scaled_dot_product_attention` (`mlx_lm/models/base.py` — same
  `mx.quantized_matmul` ×2 + `mx.softmax(precise=True)` + `where(…, finfo.min)` +
  `queries *= scale`), and mlx-lm exposes exactly this scheme via `--kv-bits`. So
  uniform-quant is **bit-exact L1 by construction** (a uniform-kv logit golden would
  confirm the measured number; `bench.ts --baseline-kv 8` runs the stock-mlx-lm side
  for the perf comparison). The FUSED / N-tiled prefill path (fused-sdpa ON — the
  naked default and `--l2`) is the **optiq-aligned** one, not mlx-lm. **config
  (per-layer mixed-precision) → L2** (optiq-only; mlx-lm has no per-layer analog).

**Decision table (serve decode flags):**

| Flag | Breaks mlx-lm parity? | L1 | L3 / naked | Relation to faithful |
|---|---|---|---|---|
| `MLX_BUN_COMPILED_SWIGLU` | no | ON | on | **is** faithful swiglu |
| compiled-geglu *(needs a fork)* | no | ON | on | **is** faithful geglu |
| `MLX_BUN_COMPILED_DECODE` | no (on==off) | ON | on | orthogonal free speed |
| `MLX_BUN_FUSED_SDPA` | no (`ops.sdpa`=mlx kernel) | on (bf16 no-op) | on | faithful-aligned; L2 lever |
| `MLX_BUN_FORCE_WIRE` / `EXPERT_OFFLOAD` | no (memory only) | user | user | orthogonal |
| `MLX_BUN_FUSED_GELU` | **yes** (pow/tanh) | **OFF** | if faster, KL-gated | competes w/ faithful geglu |
| `MLX_BUN_FUSED_SWIGLU`(`_F32`) | **yes** (exp/f32) | **OFF** | off (unproven) | competes w/ faithful swiglu |
| `MLX_BUN_PERF_KERNEL` | **yes** (online softmax) | **OFF** | on w/ kv-quant | unrelated original |
| `MLX_BUN_FUSED_DECODE` | **yes** | **OFF** | off | unrelated experiment |
| `--kv-quant` | off=L1; uniform `4\|8`=L1 in the L1 set (unfused SDPA==mlx-lm); config=L2 | **off (bf16)**, uniform ok | config | cache axis, not kernel (see kv note above) |
| `MLX_BUN_FAITHFUL` | — | **delete** | delete | illegal 2nd bundle → flags |
| `MLX_BUN_CPM5_FAITHFUL` | no | fold into `--l1` | — | A/B tool; likely retire |

So **L1 = all "compiled" flags on, all custom-"fused" flags off, kv-quant off** —
which is exactly what the `--l1` alias should expand to. After Phase 1 gives
compiled-geglu a fork, "faithful" stops being a separate concept: it's just the L1
flag values.

## Per-model target (the 13 supported models)

"Targeted" = a dedicated optimized file exists and MUST be used in every regime.
"Generic" = universal-dense fallback.

| Model | Dedicated file | Faithful-L1 today | Gap |
|---|---|---|---|
| MiniCPM5-1B-OptiQ | `minicpm5.ts` (+`-faithful`, `CPM5_FAITHFUL`) | ~yes (compiled-swiglu default) | `--l1` ⇒ kv off + perf off; confirm default == faithful (may retire `-faithful`) |
| Qwen3-Embedding-4B | `qwen3.ts` | ❌ unfused swiglu | make compiled-swiglu default; retire `FaithfulQwen3` |
| Qwen3.5-4B / 9B-OptiQ | `qwen3_5.ts` | ❌ `useCompiledActivation=false` | default it true; retire `FaithfulQwen35` |
| Qwen3.6-27B-OptiQ | `qwen3_5.ts` | ❌ same | same |
| Qwen3-30B-A3B | `qwen3-moe.ts` | ✅ by default | gate perf/kv by regime only |
| gemma-4-e4b/12B/26B-OptiQ | `generated/gemma4-*.ts` | ❌ faithful forces monolith | drop force-monolith; make compiled-geglu/softcap default |
| Qwen2.5-0.5B, Llama-3.2-1B/3B | `universal/dense.ts` | ❌ unfused swiglu | default compiled-swiglu; retire `FaithfulUniversalDense` |
| gemma-2-2b-it | `universal/dense.ts` | ✅ (gemma2 geglu not `@mx.compile`d upstream) | none |

## Plan

### Phase 1 — Global bit-exact wins (no output change) ✅ LANDED 2026-07-04

Landed on branch `faithful-decode-parity` (M1 Max, 32 GB). Changes: qwen3-dense
(`qwen3.ts`) and universal-dense (`universal/dense.ts` `swigluFn` default) now use
the shared `compiledSwiglu`; gemma `faithfulGegluActive` defaults ON via
`MLX_BUN_COMPILED_GEGLU` (kill-switch `=0`); custom `MLX_BUN_FUSED_GELU` metal geglu
demoted to explicit opt-in (`fusedGeluEnabled` default off); factory force-monolith
branch removed (gemma keeps its generated specialization). qwen3.5 MLP already
compiled (`useCompiledActivation` fields were vestigial). **Verified bit-exact
(`maxDiff===0`) vs mlx-lm:** `universal-parity` (Qwen2.5-0.5B, Llama-3.2-1B/3B,
gemma-2-2b) 6/6; `generated-parity` (12B + e4b generated vs monolith) 5/5;
`parity.test` (gemma-4-12B monolith greedy+logits vs mlx-lm goldens) 1/1. tsc 0,
hygiene green. qwen3-dense (Qwen3-Embedding) not on this box → verified by analogy
to the identical qwen3.5 MLP pattern. The already-global micro-fixes (native
`mlx_arange`, host-side bf16 scalars) need no change — they were never
`faithfulMode`-gated.

These change *dispatched kernels only*, not output, so they apply in **every**
regime (naked default included) and need no regime gate. Each is bit-exact + faster.

1. **Compiled activation default-on** for the dedicated classes that still run it
   unfused: `qwen3.ts`, `qwen3_5.ts` (`useCompiledActivation` → default true), and
   `universal/dense.ts` swiglu kinds. (qwen3_moe, minicpm5 already default-on.)
2. **Decouple compiled-geglu + `compiledLogitSoftcap` from `faithfulMode()`** in
   `gemma4.ts` (`faithfulGegluActive`) → make them the default; retire the custom
   `MLX_BUN_FUSED_GELU` metal geglu to explicit opt-in. This makes gemma bit-exact on
   the activation axis under `--l1` *and* naked default, in the generated files (which
   inherit the base MLP) without regenerating them.
3. **Drop the "force monolith under faithfulMode" branch** in `factory.ts` — the
   generated `gemma4-*` specialization keeps running; it already gates
   perf-kernel/fused-decode on flags, so `--l1` (perf/fused off) yields the L1 path
   while staying model-specific.
4. Confirm the already-global bit-exact micro-fixes (native `mlx_arange`, host-side
   bf16 scalars) apply on all paths.

**Verify per model:** bit-exact tokens **and** logprobs vs the mlx-lm oracle venv
(`/Users/joshrossi/Code/mlx-lm/.venv`), plus an xctrace shader-list diff where a
kernel-set claim is made (`.gputrace` isn't parseable — use the shader-list method).

### Phase 2 — Make `--l1` a pure alias over complete forks ✅ LANDED 2026-07-04

Landed: added `--compiled-activations on|off` (drives `MLX_BUN_COMPILED_GEGLU` +
`MLX_BUN_COMPILED_SWIGLU`) and `--fused-gelu on|off` (`MLX_BUN_FUSED_GELU`, the
custom L3 kernel) as per-fork flags in `applyDecodeRoute`; the `TIERS` presets now
set `compiledAct: true, fusedGelu: false` for l1/l2/l3, so `--l1` = { bf16 KV,
perf-kernel off, fused-decode off, **compiled activations on, custom fused-gelu
off** } and is byte-reproducible from individual flags. Fixed the `--l1` help text
(compiled activations, not "unfused"); documented both forks in `serve --help`, the
ready-card lever summary, `server-config.md`, and `cli.md`. Verified: tsc 0, help
renders the flags, and gemma `parity.test` is bit-exact vs mlx-lm under BOTH
`MLX_BUN_COMPILED_GEGLU=1` (default) and `=0` (uncompiled) — proving
`--compiled-activations off` is a valid same-parity opt-in and the env plumbing name
is honored. (qwen3/qwen3.5/universal compile swiglu unconditionally, so
`--compiled-activations off` only reverts gemma geglu + MiniCPM5 swiglu — documented.)

Original plan for reference:

First **close the fork-coverage gap**: expose the activation-fusion choice as an
individual per-fork flag (e.g. `--geglu compiled|fused|unfused` and the swiglu
equivalent, or booleans `--compiled-geglu` / `--fused-gelu` / `--compiled-swiglu`),
reading the same env vars the model files already check. Then wire it into the
`TIERS` presets in `applyDecodeRoute` so the `l1` alias sets it to the compiled
(bit-exact-fastest) value.

Result: `--l1` ⇒ { kv-quant off (bf16), perf-kernel off, fused-decode off,
custom-fused-gelu off, **compiled activations on**, model-specific file retained } —
and every one of those is an individual flag, so `--l1` is byte-reproducible by hand
and any single choice is overridable (`--l1 --fused-gelu on`). For MiniCPM5, `--l1`
implies whatever makes its decode bit-exact (its default may already qualify once
kv/perf are off — decide whether `FaithfulMiniCPM5` is still needed or retire it).

Fix the `--l1` help text: it is compiled activations + bf16 KV (not "unfused").

### Phase 3 — Retire the parallel axis ✅ LANDED 2026-07-04

Deleted `MLX_BUN_FAITHFUL`/`faithfulMode`: `src/faithful.ts` → `src/flags.ts` (keeps
only the generic `flagOn` helper); `generate.ts` compiled-decode default is now a
plain `flagOn(…, true)`. Deleted the four unwired subclasses (`gemma4-faithful`,
`qwen3-faithful`, `qwen3_5-faithful`, `universal/dense-faithful`) and their exclusive
hooks: `setFaithfulGeglu`/`_faithfulGeglu` gone (`faithfulGegluActive` → the simpler
`compiledGegluActive` = `flagOn("MLX_BUN_COMPILED_GEGLU", true)`), the dead
`useCompiledActivation` fields gone (qwen3.5 already compiles all three activation
sites unconditionally). **Kept `FaithfulMiniCPM5`** (`MLX_BUN_CPM5_FAITHFUL`) as the
one wired, tested, complete op-for-op A/B reference. Verified: tsc 0, repo-wide sweep
for the deleted concepts is clean, gemma `parity.test` + `minicpm5-faithful-parity`
green. Net: "faithful" is no longer a concept in the code — it's just the default
kernels, selected (or not) by the individual flags.

### Phase 4 — Docs + benchmark ✅ LANDED 2026-07-04 (numbers Josh-gated)

Docs updated: `features-matrix.md` (new `--compiled-activations` + `--fused-gelu`
rows), `server-config.md` + `cli.md` (Phase 2). Reworked `scripts/bench-levers.ts faithful-matrix`
+ `scripts/bench-serve.ts all` comparison 0 for the new model — since faithful is now the default,
the matrix measures what **removing** each faithful kernel costs and what the L3
custom kernels add on top (`− compiled-decode`, `− compiled activations`,
`+ custom fused-gelu`), all vs mlx-lm; tsc 0. **The actual numbers are Josh-gated**
(clean/rebooted machine — `bun scripts/bench-serve.ts all --redo`, or
`bun scripts/bench-levers.ts faithful-matrix`); loaded-machine absolutes are noise. Promote
quotable rows to `benchmarks/RESULTS.md` after the clean run.

## Status: consolidation complete

Phases 1–4 landed on `faithful-decode-parity`. The three overlapping "match mlx-lm"
mechanisms are now one: the individual flags, with `--l1/l2/l3` as pure aliases.
Faithful kernels are the default; `--l1` is the bit-exact-mlx-lm implementation;
naked default is best-experience. Only follow-ups: (a) live qwen3-dense parity on a
box that has Qwen3-Embedding; (b) the clean-machine bench numbers.

## Open decisions

- **`FaithfulMiniCPM5`**: retire (if `MiniCPM5Model` default is already bit-exact
  mlx-lm under `--l1`) or keep as the A/B harness?
- **Keep one A/B backend** per family for regression proofing, or delete all and
  lean on the oracle parity tests?
- **`MLX_BUN_FAITHFUL`**: delete, or alias to `--l1`?

## Risks

- Compiled activation must be **autograd-safe** on the training path (mlx-lm's
  `@mx.compile` threads the VJP; verified for cpm5/dense earlier — re-verify per
  family before defaulting on).
- Making compiled-geglu the naked default changes gemma's *default* dispatched
  kernels; confirm no downstream (vision, batching, generated specializations)
  assumes the unfused/custom path.
