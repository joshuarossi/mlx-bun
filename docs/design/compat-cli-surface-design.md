# Compat CLI surface + parity harness — design

Status: design (2026-06-12). Engineering tracking lives in PLAN.md
Phase 17. UX/DX rationale lives in PRODUCT_ROADMAP.md ("The three
modes"). This doc is the surface contract: every verb, the flag
vocabulary, how optiq is absorbed, the parity harness, and **the
matrix of what we still lack**.

## Goal

Design mlx-bun's entire CLI/flag surface from scratch (nothing is
published, nothing is set in stone) so that one coherent set of verbs
serves three audiences at three depths — automatic / compat /
stick-shift (see PRODUCT_ROADMAP). mlx-lm is the vocabulary we borrow,
because it is the Apple-WWDC-referenced default and outweighs the
alternative ~425× on monthly installs (1.64M vs 3.85k; mlx-lm 5.8k
stars / 765 forks; mlx-optiq has no public repo — measured
2026-06-12).

## Scope boundary: surface parity ≠ architecture parity

This is CLI/flag-**surface** parity. It is NOT a promise to run every
model architecture mlx-lm supports — the design principle "scope is the
survival strategy: target Gemma, Qwen, one MoE; not parity with mlx-lm's
dozens" still holds. A compat verb invoked against an unsupported
architecture returns a clear `architecture not supported by mlx-bun yet
(supported: …)` error, never a silent failure or a wrong answer. The
flag is accepted; the model may not be.

## The three laws (from PRODUCT_ROADMAP, restated as surface rules)

1. **One surface, mlx-lm vocabulary.** `mlx-bun.<verb>` is a pure alias
   of `mlx-bun <verb>`. Adopt mlx-lm's flag name wherever it is the
   standard; name a flag ourselves only where mlx-lm has no concept for
   it (free to beat optiq's name there).
2. **Superset, never intersection.** Every documented mlx-lm flag
   behaves faithfully so scripts drop in unchanged; we never gate a free
   capability to resemble an upstream (OpenAI+Anthropic+Responses all
   stay on).
3. **Gate only on conflict.** A capability is always on unless leaving
   it on would degrade the automatic or compat experience (changes
   output determinism, trades quality, surprises a script) — only then
   does it move behind a stick-shift flag.

## Verb map (the spine = mlx-lm)

Each verb is reachable as `mlx-bun <verb>` and the dotted alias
`mlx-bun.<verb>`. Flags follow `mlx_lm.<verb> --help` exactly for the
shared subset; optiq-only features are additive (marked ⊕).

| Verb | Maps to | mlx-bun engine today | Notes |
|---|---|---|---|
| `generate` | mlx_lm.generate | ✅ `generate.ts` (no CLI verb) | wire verb + full flag set |
| `chat` | mlx_lm.chat | engine ✅, web chat ✅; no terminal REPL (`tui.ts` is help-formatting) | build REPL frontend over `generate` |
| `server` | mlx_lm.server / optiq serve | ✅ `serve` | rename flags; ⊕ `--kv-config`, `--anthropic` honored (default on) |
| `convert` | mlx_lm.convert + optiq convert | ❌ | quant pipeline; ⊕ `--target-bpw/--candidate-bits/--reference` |
| `lora` | mlx_lm.lora + optiq lora | serve/hot-swap ✅, train ❌ | `--train/--test`; ⊕ `--rank-scaling by_bits\|by_kl`; `lora info` |
| `fuse` | mlx_lm.fuse | ❌ | fuse adapters, dequant, GGUF export, upload |
| `cache_prompt` | mlx_lm.cache_prompt | runtime ✅, CLI ❌ | precompute + save reusable KV cache file |
| `benchmark` | mlx_lm.benchmark / optiq benchmark | ✅ `benchmark` | flag-name parity (`-p/-g/-b/-n`); ppl half ❌ |
| `evaluate` | mlx_lm.evaluate / optiq eval | ❌ (`evals` = our bench viewer) | task harness; ⊕ optiq task names |
| `perplexity` | mlx_lm.perplexity | ❌ | ppl on HF dataset |
| `upload` | mlx_lm.upload | ❌ | push MLX dir to HF |
| `manage` | mlx_lm.manage | ✅ `get`/`scan`/`ls` | add `--delete/--pattern/--scan` parity |
| `kv-cache` | optiq kv-cache | runtime ✅, profiler ❌ | per-layer sensitivity → `kv_config.json` |
| `latency` | optiq latency | ✅ `fit` | alias + `--calibrate` |
| `awq` | mlx_lm.awq | ❌ | activation-aware quant |
| `dwq` | mlx_lm.dwq | ❌ | distilled quant |
| `dynamic_quant` | mlx_lm.dynamic_quant | ❌ | sensitivity mixed-bit (overlaps convert/TurboQuant) |
| `gptq` | mlx_lm.gptq | ❌ | GPTQ |
| `share` | mlx_lm.share | ❌ | distributed cache share (lowest priority) |

Our own verbs stay (`fit`, `pi`, `harness`, `doctor`, no-args
appliance) — they are the automatic/stick-shift surface and have no
mlx-lm equivalent. See the native-surface section below.

## mlx-bun-native surface (the differentiators)

These have NO mlx-lm/optiq equivalent — they are not parity items, they
are what makes mlx-bun *more* than a faster mlx-lm. The compat layer
(Phase 17) is the "drop-in for mlx-lm" half; this is the "more than
mlx-lm" half.

### pi — the built-in agentic coding CLI

(Phase 16; full plan in **docs/pi-builtin-investigation.md**.) pi is an
MIT, Bun-native (`bun build --compile`) coding agent — the "CLI
experience inside our package" that neither Python package has. Three
modes building toward an embedded flagship:

1. **`mlx-bun harness pi`** (P1, exists) — configure the user's
   EXISTING pi to use mlx-bun's models, via a generated extension that
   dynamically discovers models from our `/v1/models`. No models.json
   surgery; reversible.
2. **`mlx-bun pi`** (P2, exists) — start the server (reuse if healthy)
   and launch the user's pi against it with a session-scoped provider;
   all remaining argv passes through (`-p`, `--mode rpc`, `--continue`,
   `@file`). One command → agent on a local model.
3. **Embedded pi** (P3/P4, Phase 16 `[~]`, flagship) — pi's
   `InteractiveMode` in-process inside the single binary, no prior pi
   install; `-p`→`runPrintMode`, `--mode rpc`→`runRpcMode` preserved.
   The appliance moment: one binary, one command, a real agent on a
   local model.

### Built-in web UI (OptIQ-Lab parity, pi-powered)

The web UI's agent backbone is pi's RPC / `AgentSession.subscribe()`
event stream (investigation Option 4) — the SAME events drive the
embedded TUI and the browser, so tool calls / steering / progress come
for free. Tiles: chat ✅; quantize / fine-tune / training-data gate on
the capability matrix.

## Flag-vocabulary reconciliation (where we currently diverge)

- `serve --kv-quant N` → adopt mlx-lm's `--kv-bits` + `--kv-group-size`
  + `--quantized-kv-start` (keep `--kv-quant` as a deprecated alias).
- `serve --prompt-cache` → mlx-lm's `--prompt-cache-size` (entries) +
  `--prompt-cache-bytes` (our byte-cap is already the right model).
- Our runtime levers (`--compiled-decode`, `--perf-kernel`,
  `--fused-decode`, `--fused-sdpa`, `--force-wire`) have no mlx-lm
  equivalent → keep, these are stick-shift flags.
- Adopt mlx-lm's sampling names verbatim: `--temp`, `--top-p`,
  `--top-k`, `--min-p`, `--max-tokens/-m`, `--seed`, `--xtc-*`.

## What we still lack — capability gap matrix

Legend: ✅ have · 🔌 wiring-only (engine exists, needs verb/flags) ·
🟥 missing capability (real build). The compat **layer** is the 🔌
column; the 🟥 column is the capability matrix that fills in behind it.

| Capability | Verb(s) | Status | Bucket / owning phase |
|---|---|---|---|
| One-shot generate | `generate` | 🔌 | Phase 17 (compat) |
| Chat REPL | `chat` | 🔌 | Phase 17 |
| OpenAI/Anthropic/Responses serve | `server` | ✅ | done (Phase 4/11) |
| Server flag parity | `server` | 🔌 | Phase 17 |
| Benchmark (throughput) | `benchmark` | ✅ flags 🔌 | Phase 17 |
| Latency prediction | `latency`/`fit` | ✅ | done; `--calibrate` 🔌 |
| Model cache manage | `manage` | 🔌 | Phase 17 |
| Precompute prompt cache | `cache_prompt` | 🔌 | Phase 17 |
| LoRA serve / hot-swap | `lora` (serve) | ✅ | done (Phase 8) |
| `lora info` reporting | `lora info` | 🔌 | Phase 17 |
| **HF→MLX convert → new model artifact** | `convert` | 🟥 | Model-quant (new phase) |
| **Sensitivity / mixed-precision weights** | `convert`, `dynamic_quant` | 🟥 | Model-quant |
| **AWQ / DWQ / GPTQ (weights)** | `awq`/`dwq`/`gptq` | 🟥 | Model-quant |
| KV-cache quant: bf16 / uniform / **mixed per-layer** (kv_config.json) | `server` (`off`/`N`/`config`) | ✅ | done (Phase 9/10; config.ts reads, generate.ts applies per-layer) |
| KV sensitivity *profiler* (authors a NEW kv_config.json) | `kv-cache` | 🟥 | model-prep, low pri (shipped artifacts already include one) |
| TurboQuant — optional extra quant *method* (rotation VQ) | scheme, not a verb | 🟥 | Phase 13 (KV plumbing already exists) |
| **LoRA / DoRA / full training** | `lora --train` | 🟥 | Training (new phase) |
| **Sensitivity-aware rank scaling** | `lora --rank-scaling` | 🟥 | Training |
| **Fuse adapters (+GGUF/upload)** | `fuse` | 🟥 | Training |
| **lm-eval-harness tasks** | `evaluate` | 🟥 | Eval (new phase) |
| **optiq eval suite (kl/gsm8k/ifeval/bfcl/hashhop…)** | `evaluate` | 🟥 | Eval |
| **Perplexity** | `perplexity` | 🟥 | Eval |
| **HF upload** | `upload` | 🟥 | Distribution |
| **Distributed share** | `share` | 🟥 | Distribution (lowest pri) |
| **Web UI: quantize** | `lab`/UI | 🟥 | gated on Quantize |
| **Web UI: fine-tune** | `lab`/UI | 🟥 | gated on Training |
| **Web UI: training-data template + gen** | `lab`/UI | 🟥 | new (no engine dep) |
| Web UI: chat | `/chat` | ✅ | done (publishing gate 2) |
| **Native: pi configure existing** (`harness pi`) | — | ✅ (P1) | Phase 16 |
| **Native: pi launch existing** (`mlx-bun pi`) | — | ✅ (P2) | Phase 16 |
| **Native: pi embedded in binary** | — | 🟡 (P3/P4) | Phase 16 (flagship) |

Summary: serving and the read-only/measurement verbs are **🔌
wiring-only** — the compat layer ships over what the engine already
does. The real capability work splits along two axes:

- **Model quantization** (offline, makes a new artifact): `convert`,
  `awq`, `dwq`, `gptq`, `dynamic_quant`. Its own new phase.
- **Inference-time KV-cache quant** (online, no artifact): bf16 /
  uniform / **mixed per-layer** from kv_config.json all ✅ today
  (Phase 9/10 — we read & apply shipped configs). The only KV gaps are
  optional and not inference plumbing: a *profiler* to author a new
  kv_config.json (model-prep, low pri) and extra methods like TurboQuant
  (Phase 13).
- **Training**: LoRA/DoRA/full + `fuse`.
- **Eval**: harness + `perplexity`.
- **Distribution**: `upload`/`share`.

The OptIQ-Lab web-UI tiles gate on these: quantize ← model-quant,
fine-tune ← training, training-data ← independent, chat ✅.

Plus the **native half** (no parity equivalent — the differentiators):
the pi agentic coding CLI (Phase 16: `harness pi` + `mlx-bun pi` exist;
embedded single-binary pi is the flagship) and the web UI, both riding
pi's `AgentSession` event stream. Compat makes us a drop-in for mlx-lm;
the native half makes us more than it.

## Parity harness (turns "drop-in" into a passing test)

Same discipline as logit parity. For each compat verb, a test diffs
mlx-bun against the Python oracle in `/Users/joshrossi/Code/mlx-lm/.venv`:

- **Flag-surface parity**: parse `mlx_lm.<verb> --help`, assert every
  documented flag is accepted by `mlx-bun <verb>` (or explicitly
  rejected with a clear message — never silently ignored).
- **Behavior parity** where deterministic: `generate --seed --temp 0`
  output, `manage --scan` listing shape, `cache_prompt` round-trip,
  `benchmark` column schema.
- **Gap honesty**: a not-yet-built verb (`convert`, `evaluate`, …)
  exits non-zero with `not implemented in mlx-bun yet` — the harness
  asserts the message, so gaps are visible, not silent.

Gated by `benchmark.sh`-style preflight only where it measures speed;
correctness diffs need no clean machine.

## Build sequencing

1. **Phase 17 — this layer**: verb router + dotted aliases + flag
   vocabulary + reconcile existing commands + parity harness, over
   existing capabilities (`generate`, `chat`, `server`, `benchmark`,
   `manage`, `cache_prompt`, `lora info`, `latency`). Honest stubs for
   🟥 verbs.
2. Model quantization (new phase) → `convert`/`dynamic_quant`/`awq`/
   `dwq`/`gptq` (new model artifacts) + web-UI quantize tile.
3. Inference-time KV quant → already done (bf16 / uniform / mixed
   per-layer via kv_config.json, Phase 9/10). Optional later: a profiler
   to author new configs (low pri) + the TurboQuant method (Phase 13).
4. Training → `lora --train`/`fuse` + web-UI fine-tune tile.
5. Eval → `evaluate`/`perplexity`.
6. Distribution → `upload`/`share`.
7. Web UI training-data tile (independent of engine work).
