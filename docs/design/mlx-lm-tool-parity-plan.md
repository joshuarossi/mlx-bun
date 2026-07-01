# mlx-lm tool parity — scoping plan

Scoping for the remaining mlx-lm CLI tools not yet covered by mlx-bun, plus
serve-time speculative decoding (`--draft-model`). Written against the oracle
venv (`/Users/joshrossi/Code/mlx-lm/.venv`, **mlx-lm 0.31.3**, **mlx-optiq
0.2.4** — note: newer than the 0.2.1 noted in CLAUDE.md), source read directly
from `site-packages/`. Sibling work in flight (not covered here): `fuse` /
`convert` / `perplexity` (another agent), `sft_scope`.

## What actually exists in mlx-lm 0.31.3

From `mlx_lm-0.31.3.dist-info/entry_points.txt` — all six named tools are real
console scripts, plus one this plan folds in because we already cover it:

| entry point | source file |
| --- | --- |
| `mlx_lm.cache_prompt` | `mlx_lm/cache_prompt.py` |
| `mlx_lm.evaluate` | `mlx_lm/evaluate.py` |
| `mlx_lm.upload` | `mlx_lm/upload.py` |
| `mlx_lm.awq` | `mlx_lm/quant/awq.py` |
| `mlx_lm.dwq` | `mlx_lm/quant/dwq.py` |
| `mlx_lm.gptq` | `mlx_lm/quant/gptq.py` |
| `mlx_lm.dynamic_quant` | `mlx_lm/quant/dynamic_quant.py` (sensitivity-scan + 4/5-bit split — **already covered** by `src/quantize/{sensitivity,allocator}.ts`; no work item) |

`mlx_lm.server --draft-model/--num-draft-tokens` lives in `mlx_lm/server.py`
(flags at :1782–1791) driving `speculative_generate_step` in
`mlx_lm/generate.py:473`.

**optiq's quant tooling (the L2 oracle), for calibration of the awq/dwq/gptq
decision:** `optiq convert` is per-layer **KL sensitivity scan + greedy
mixed-precision knapsack** (`optiq/core/sensitivity.py`, `optimizer.py`, with
block-floor/block-run guards and a latency-aware variant), verified by
`optiq/core/verifier.py` (perplexity / KL thresholds). It does **not**
implement AWQ/DWQ/GPTQ-style learned or activation-aware quantization — final
packing is stock `mx.quantize`. So optiq covers the *bit-allocation* half of
quant quality; the *learned-refinement* half (DWQ et al.) is genuinely
uncovered by both mlx-bun and optiq today.

---

## 1. `cache_prompt`

**What it does.** Prefills a prompt into a KV cache and saves it to a
safetensors file for later reuse (`mlx_lm/cache_prompt.py`; save/load are
`save_prompt_cache`/`load_prompt_cache` in `mlx_lm/models/cache.py:43,62`).
Consumers: `mlx_lm.generate --prompt-cache-file` (`generate.py:180,1974-1990`,
which also validates that `--kv-bits`/`--kv-group-size` match the loaded
cache) and `mlx_lm.chat`. The chat template is applied with
`add_generation_prompt=False, continue_final_message=True` so the cache ends
mid-conversation.

**CLI surface** (`cache_prompt.py:17-80`): `--model` (default `mlx_model`),
`--adapter-path`, `--trust-remote-code`, `--eos-token`, `--max-kv-size`,
`--prompt-cache-file` (required), `--prompt` (required, `-` = stdin),
`--kv-bits` (default none), `--kv-group-size` (64), `--quantized-kv-start`
(5000). Saved metadata: model path + tokenizer config.

**mlx-bun overlap.** `src/prompt-cache.ts` — in-memory, byte-capped
(`--prompt-cache <GiB>`, default 2), LRU, longest-strict-prefix `take()`,
adapter-namespaced. It is server-only and has **no disk serialization**; cache
entries are live MlxArrays and die with the process. `mlx-bun generate` has no
`--prompt-cache-file`. The building blocks exist: safetensors write machinery
in `src/quantize/safetensors-writer.ts`, cache state (K/V tensors + offset)
owned by the `Cache` implementations in `src/model/gemma4.ts`.

**Port plan.**
- `src/prompt-cache-io.ts` (new): `savePromptCache(file, caches, meta)` /
  `loadPromptCache(file)` — serialize each layer's K/V (+ scales/biases for
  quantized caches, ring state for rotating caches) plus
  `{modelId, tokens, kvBits, kvGroupSize, offset[]}` metadata. Mirror
  mlx-lm's per-class `state`/`meta_state` split rather than inventing a format.
- `src/cli.ts`: new `cache-prompt` subcommand (model resolve via `Registry`,
  prefill via the serving prompt path — reuse `promptIdsFor`, per the
  eval-reuse lesson) and a `--prompt-cache-file` flag on `generate`.
- Optional follow-up: `mlx-bun serve --prompt-cache-file` to pre-warm the
  server's `PromptCache` at startup.

**Oracle / tiers.** L1 bit-exact, two gates: (a) round-trip — greedy
generation from a loaded cache file must be token-identical to single-shot
generation over prompt+continuation; (b) cross-oracle — same prompt cached by
`mlx_lm.cache_prompt` and by us produce token-identical continuations from
each runtime. Byte-level file compatibility with mlx-lm's format is a stretch
goal, not the bar.

**Effort:** M. **Risky parts:** serializing `RotatingKVCache` ring state and
quantized-cache triples correctly; offset/window metadata; refusing stale
caches (model mismatch) loudly.

**Recommendation: build later.** The in-memory server cache already covers
the interactive/agent use-case; the file workflow mainly serves scripted CLI
runs. Cheap, real parity, not urgent.

---

## 2. `evaluate`

**What it does.** An adapter that registers mlx-lm as an
**lm-evaluation-harness** backend (`mlx_lm/evaluate.py:71` —
`@register_model("mlxlm") class MLXLM(LM)`) implementing `loglikelihood`
(prefix-grouped, batched scoring with KV reuse), `loglikelihood_rolling`, and
`generate_until` (via `batch_generate`), then calls
`lm_eval.simple_evaluate(...)` (`evaluate.py:489`). The task library, few-shot
formatting, and metrics all live in the third-party `lm_eval` package —
that's the bulk of the tool.

**CLI surface** (`evaluate.py:397-458`): `--model` (req), `--tasks` (req,
nargs+), `--output-dir`, `--batch-size` (16), `--num-shots`, `--max-tokens`,
`--limit`, `--seed` (123), `--fewshot-as-multiturn`, `--apply-chat-template`
(tri-state), `--chat-template-args` (JSON), `--confirm-run-unsafe-code`,
`--trust-remote-code`, `--temp`/`--top-p`/`--top-k`.

**mlx-bun overlap.** `src/eval/` (runner with `generateText` on the real
serving path + `greedyDecodeBitExact`, task set, KL machinery in
`src/eval/kl.ts`), results in `~/.cache/mlx-bun/evals.sqlite`
(`src/evaldb.ts`), CLI `mlx-bun benchmark` / `mlx-bun evals`. And the L2
oracle already ships a full benchmark suite: `optiq eval`
(kl/gsm8k/mmlu/ifeval/bfcl/humaneval/hashhop + Capability_Score).

**Port plan.** Do **not** port lm-eval to Bun — reimplementing the task
library is XL and permanently chasing upstream. Two-part coverage instead:
1. **Shim (S):** document + smoke-test running the oracle venv's `lm_eval`
   against a running mlx-bun server via its OpenAI `local-completions` /
   `local-chat-completions` backend (mlx-bun's `/v1` already speaks the
   contract; needs `logprobs`/`echo` support checked for loglikelihood tasks
   — generation tasks work today). One doc page + a
   `scripts/lm-eval-shim.sh`.
2. **Native (only if a gap shows):** add a `loglikelihood` scoring mode to
   `src/eval/runner.ts` (one forward, `take_along_axis` on log-softmax — the
   same scoring loop as `evaluate.py:107-138`) so our own tasks can do
   multiple-choice; that's an S add-on with a direct numeric oracle
   (`MLXLM._score_fn` outputs on fixed inputs).

**Oracle / tiers.** Not a bit-exactness surface end-to-end; gate the scoring
primitive (loglikelihood per token vs oracle `_score_fn`, exact fp32 match on
fixed inputs = L1-style), and gate task *scores* statistically (same task,
same limit, matching accuracy).

**Effort:** S (shim) / M (native loglikelihood). **Risky parts:**
loglikelihood-via-HTTP needs prompt-logprob echo, which most local /v1 servers
(ours included) don't fully implement — that's the one real feature gap to
check first.

**Recommendation: cover-via-existing** (own eval suite + optiq eval as
quality oracle) **+ the S-sized lm-eval-over-HTTP shim**; skip a native port.

---

## 3. `upload`

**What it does.** 22-line wrapper (`mlx_lm/upload.py`) around
`mlx_lm.utils.upload_to_hub(path, repo)` — creates the repo and uploads a
model folder (with generated model card) via `huggingface_hub`.

**CLI surface:** `--path` (default `mlx_model`), `--upload-repo`.

**mlx-bun overlap.** Essentially done: `src/hf-push.ts` implements the whole
HF HTTP protocol natively (create-repo → preupload → LFS batch/S3 → NDJSON
commit), token management (`~/.mlx-bun/hf.json` → `$HF_TOKEN` → HF cache
token), LFS suffix + 10 MB threshold rules. It's wired to the web push routes
(`/api/{quantize,finetune,dataset}/push` in `src/server.ts`) but has **no CLI
command**.

**Port plan.** One new `case "upload"` in `src/cli.ts`: resolve `--path` (or
a registry query) → `uploadToHub(dir, repo)`; accept `--upload-repo` as the
mlx-lm-named alias for `--repo`. Optional: generate a small model card noting
mlx-bun + quant recipe, as `upload_to_hub` does.

**Oracle / tiers.** Functional, not numeric: round-trip test (upload a tiny
artifact → `mlx-bun get` it back → hash-compare files). No tier gate.

**Effort:** S. **Risky parts:** none new — the risky code already runs in
production via the Lab routes.

**Recommendation: build now.** Trivial, and the in-flight `convert`/`fuse`
work plus `quantize` all produce directories that want a publish verb.

---

## 4. `awq`

**What it does.** Activation-aware weight quantization
(`mlx_lm/quant/awq.py`): per transformer block, capture layer inputs with
`Catcher` modules, grid-search (`--n-grid`, default 20) per-channel **scales**
(balancing activation vs weight magnitudes) and **clip** thresholds to
minimize block-output MSE under quantization, with a per-block fallback to
plain quantization if the loss didn't improve (`awq.py:452-505`). Requires a
hand-written per-architecture `AWQConfig` (which norms feed which
projections); registry at `awq.py:143`: llama, mistral, qwen2, qwen3,
gemma3_text, gemma3, deepseek_v2. Calibration data: fixed gist download,
`quant/utils.py:load_data` (`~/.cache/mlx-lm/calibration_v5.txt`). Embeddings
and lm_head quantized separately (`--embed-bits/--embed-group-size`).

**CLI surface** (`awq.py:533-547`): `--model/-m`, `--mlx-path`, `--bits` (4),
`--group-size` (64), `--embed-bits` (4), `--embed-group-size` (32),
`--num-samples` (128), `--sequence-length` (512), `--n-grid` (20), `--seed`
(123). Distributed-aware (`mx.distributed`).

**mlx-bun overlap.** `src/quantize/` already does calibration-driven quality
work — per-layer KL sensitivity (`sensitivity.ts`) + mixed-precision knapsack
(`allocator.ts`), i.e. the optiq approach; that attacks the same quality goal
by *bit allocation* rather than *weight conditioning*. No scale/clip search
exists. optiq itself ships no AWQ (verified above), so there is **no L2
oracle path** — the only oracle is `mlx_lm.awq` itself.

**Port plan (if built).** `src/quantize/awq.ts` (scale/clip grid search —
needs per-block input capture, which means a tapped block forward like
`forwardTapped` in `src/spec/dspark/generate-dflash.ts:34`, generalized),
`src/quantize/awq-configs.ts` (per-arch registry for our ported models:
gemma3/gemma4, qwen, minicpm — note upstream has no gemma4/minicpm configs;
we'd be authoring those, unoracled), calibration loader reusing
`quantize/calibration.ts`, CLI or Lab-API entry. Oracle: run `mlx_lm.awq` in
the oracle venv on a small supported model (fixed seed + shared calibration
file) and compare final weight tensors — deterministic given identical
calibration batches, so weight-level parity is the L1-style gate; then
KL/perplexity via existing `src/eval/kl.ts` for quality claims.

**Effort:** L. **Risky parts:** per-arch config authoring for models mlx-lm
doesn't cover (no oracle); block-capture instrumentation on our hand-written
(non-module-tree) forwards; grid search runtime on 24–32 GB machines.

**Recommendation: build later (likely skip).** The L2 mixed-precision path is
our quant-quality story; only revisit if KL evals show our 4-bit uniform tier
losing to community AWQ artifacts.

---

## 5. `dwq`

**What it does.** Distilled weight quantization (`mlx_lm/quant/dwq.py`):
quantize the model, then **unfreeze only the quantization `scales`/`biases`**
of sub-8-bit affine layers (`dwq.py:90-100`) and train them against the bf16
teacher with a temperature-2 KL loss on top-1024 teacher logits
(`kl_div_loss`, `dwq.py:108-118`), Adam @ 1e-6, params accumulated in f32.
Teacher logits can be precomputed to disk (`--target-dir`, top-1024 +
indices as safetensors, `compute_dwq_targets`) so teacher and student never
need to be resident together. Warns if final val loss regressed. This is the
method behind most good mlx-community 4-bit artifacts.

**CLI surface** (`dwq.py:242-304`): `--model/-m` (teacher, req),
`--quantized-model` (optional pre-quantized student), `--mlx-path`, `--bits`
(4), `--group-size` (64), `--num-samples` (2048), `--max-seq-length` (1025),
`--seed`, `--learning-rate` (1e-6), `--batch-size` (4), `--data-path`
(default `allenai/tulu-3-sft-mixture`), `--grad-checkpoint`, `--target-dir`,
`--targets-only`, `--pipeline`.

**mlx-bun overlap.** Strong: full training stack (`src/train/` — trainer,
gradient checkpointing, segmented backward, flash-CCE), KL machinery
(`src/eval/kl.ts`), quantized-model load/save (`src/quantize/`), dataset
plumbing from the train CLI. Missing pieces are specific: (a) treating
quantized-layer `scales`/`biases` as trainable leaves (trainer is
LoRA-parameter-shaped today), (b) the KL-on-top-k distillation loss +
target-precompute pipeline, (c) f32 master-weights accumulation for bf16
models. Neither optiq nor mlx-bun has this today; optiq's trainer is mlx-lm's
tuner, so the oracle is direct.

**Port plan.** `src/train/dwq.ts` (loss + loop, reusing trainer infra),
`src/quantize/` hook to enumerate trainable quant params, target-precompute
script writing the same `{logits, indices}` safetensors shards, CLI
`mlx-bun train --method dwq` (or `mlx-bun dwq`). **Memory note for this
hardware:** always use the `--target-dir` two-phase flow (teacher pass, then
student-only training) — teacher+student resident together won't fit for
interesting models on 24/32 GB.

**Oracle / tiers.** Training-parity style gate (the mlx-lm-tuner-copy
standard): fixed seed/data/targets → first-N-step loss values match
`mlx_lm.dwq` bit-for-bit (or to bf16-accumulation tolerance, documented);
artifact quality gated by KL-vs-teacher and perplexity via existing eval,
plus "final val ≤ initial val" as upstream checks.

**Effort:** L. **Risky parts:** unfreezing quant params without disturbing
the LoRA-shaped trainer contract; matching `iterate_batches` order for the
step-parity gate; seq-len ceilings during the teacher pass on big models
(same wall as e4b training).

**Recommendation: build later — but first of the three quant tools.** It's
the one with real artifact-quality payoff, it composes with (rather than
duplicates) the L2 mixed-precision allocator (DWQ-refine an optiq-allocated
model), and it fits the training-first identity. Schedule after `sft_scope`
lands to avoid trainer churn.

---

## 6. `gptq`

**What it does.** GPTQ (`mlx_lm/quant/gptq.py`): accumulate per-layer input
Hessians `H = ΣxᵀX` via `Catcher` wrappers on every `nn.Linear`/
`SwitchLinear` (`gptq.py:40-49`), Cholesky-invert on the CPU stream
(`gptq.py:78-86`), then per-group error-propagating rounding
(`gptq.py:95-142`); non-GPTQ layers get `--fallback-bits` (default 6).
Architecture-agnostic (no per-model registry, unlike AWQ). Same calibration
loader as AWQ.

**CLI surface** (`gptq.py:162-199`): `--model/-m`, `--mlx-path`, `--bits`
(4), `--group-size` (64), `--fallback-bits` (6), `--fallback-group-size`
(64), `--num-samples` (-1 = all), `--sequence-length` (512), `--seed` (123).

**mlx-bun overlap.** Same as AWQ: `src/quantize/` covers bit-allocation
quality, nothing covers Hessian-conditioned rounding; optiq ships no GPTQ.
The mixed shape is interesting though: GPTQ's *output* is expressible in our
existing per-layer quantization config (`config-writer.ts` /
`quantization` config section) — only the solver is new.

**Port plan (if built).** `src/quantize/gptq.ts`: per-layer input capture
(shared instrumentation with the AWQ item — build once), Hessian accumulation,
Cholesky via mlx-c on the CPU stream (**verify `mlx_linalg_cholesky` /
`cholesky_inv` are bound in `src/mlx/` first** — if absent, that's new FFI
surface), the rounding loop, then reuse `safetensors-writer.ts`. Being
arch-agnostic, it needs no per-model registry — meaningfully cheaper than AWQ.

**Oracle / tiers.** `mlx_lm.gptq` on a small model with shared calibration
file + seed → weight-tensor parity (the algorithm is deterministic); then KL /
perplexity quality gate. L1-style, single oracle.

**Effort:** M–L (M if the capture instrumentation exists from DWQ/AWQ work
and cholesky is already bound; L otherwise). **Risky parts:** cholesky FFI
availability; the inner rounding loop's `mx.eval` cadence (upstream evals per
group element — naive porting is slow); MoE `SwitchLinear` equivalents.

**Recommendation: skip for now.** Dominated by DWQ on quality-per-effort and
by the L2 allocator on the positioning story; keep on the list only as a
follow-on if we build the shared capture instrumentation anyway.

---

## 7. `serve --draft-model` / `--num-draft-tokens` (speculative decoding at serve time)

This is the concrete, hand-to-an-implementer plan.

### What mlx_lm.server does (read: `server.py`, `generate.py`)

- **Flags** (`server.py:1782-1791`): `--draft-model` (path/repo, default
  None), `--num-draft-tokens` (default **3**; `mlx_lm.generate`'s default is
  2 — copy the server's 3).
- **Loading** (`ModelProvider._load`, `server.py:326-381`): draft loaded with
  plain `load()`; **vocab-size mismatch is a warning, not an error**
  (`:363-368`); draft path is part of `model_key`, and requests can override
  per-request (`draft_model`, `num_draft_tokens` in the body,
  `server.py:1164-1166`, validated ≥ 0 at `:1237`). No memory-budget check
  (mlx-lm has none; we do — see below).
- **Lane routing:** `is_batchable = draft_model is None` (`server.py:371`) —
  a draft model forces every request down `_serve_single`
  (`server.py:922-988`), i.e. **spec decode is serial-lane-only upstream
  too**. Distributed mode rejects draft models outright (`:327-332`).
- **Prompt cache composition** (`server.py:970-973`): one cache list =
  target's caches with the draft's caches **appended**;
  `speculative_generate_step` splits it back at `len(model.layers)`
  (`generate.py:526-527`). The server's LRU prompt cache therefore stores
  both models' KV per entry, keyed by a model_key that includes the draft
  path.
- **The loop** (`speculative_generate_step`, `generate.py:473-654`): prefill
  both models on the prompt; per round draft `n = min(remaining,
  num_draft_tokens)` tokens autoregressively from the draft model (sampled
  with the *same request sampler*), run **one target forward over
  `[pending, ...drafts]`** (n+1 positions), sample the target per position,
  and accept the longest prefix where target token == draft token — **exact
  token-match acceptance, not distribution-level rejection sampling** — then
  emit the target's token at the first mismatch (or the bonus token if all
  accepted), and `trim_prompt_cache` both caches by the rejected count
  (`:589-591`). Requires trimmable caches (`:529-533` raises otherwise);
  kv-quant composes via `maybe_quantize_kv_cache` on both caches. When all
  drafts accept, the last draft token is re-fed to the draft model next round
  (`:645-648`). `logits_processors` are threaded through with a `prev_tokens`
  replay (`:559-575`).

### mlx-bun v1 scope and design

**Scope:** two-full-model speculative decoding on the **serial lane only**,
Gemma4 + the other ported archs, greedy and sampled; per-request overrides
deferred (server-level flag only in v1 — our single-user model makes
per-request draft switching pointless).

**1. Drafter abstraction — `src/spec/source.ts` (new).** One interface so the
mlx-lm two-model drafter, the optiq `GemmaAssistantDrafter`
(`src/spec/drafter.ts`), and later DSpark's `DflashDrafter`
(`src/spec/dspark/module-dflash.ts`) sit behind the same verify loop:

```ts
interface DraftSource {
  /** Process prompt tokens (two-model: prefill the draft model's cache;
   *  assistant/dflash: no-op — they read the target's state). */
  prefill(ids: number[]): void;
  /** Propose up to n tokens given the last committed token and the target's
   *  step context (last hidden slice + donor KV views — unused by the
   *  two-model source). */
  draft(last: number, n: number, ctx: TargetStepCtx): number[];
  /** kAccept of n drafts accepted; correction token emitted. Two-model:
   *  trim draft cache by max(n - kAccept - 1, 0) per mlx-lm's rewind rule
   *  (generate.py:589-591) and note the all-accepted re-feed. */
  commit(n: number, kAccept: number, correction: number): void;
  /** Resident bytes for admission accounting. */
  readonly weightsBytes: number;
  kvBytesAt(ctx: number): number;
  dispose(): void;
}
```

`TargetStepCtx = { lastHidden?: MlxArray; donors?: SharedKv; position: number }`
— produced by the serial generation loop; the two-model source ignores it,
which is exactly what lets the assistant/dflash drafters slot in later
(they're the ones that need it; `specGenerate` in `src/spec/generate.ts`
already computes both).

**2. Two-model source — `src/spec/two-model.ts` (new).** Owns a second
`RuntimeModel` (own `Weights.open`, own cache list, own config). `draft()` is
n sequential decode steps sampled with the request sampler (mirror
`_draft_generate`, `generate.py:593-601`, including `async_eval` pipelining).
Sampler parity matters: mlx-lm drafts with the same sampler as the target —
greedy drafting under a temperature>0 request is *not* parity.

**3. Verify loop — extend the serial lane.** The hook point is the serial
generation function the gateway calls (`serialRun` →
`runGeneration`, `src/server.ts:966-1001`; gateway in
`src/serve/generation-gateway.ts:89-183`). Add a speculative variant of the
decode loop (new `src/spec/serve-loop.ts`, structured like
`specGenerate` at `src/spec/generate.ts:157-232` but sampler-aware and
callback-streaming):

- per round: `drafts = source.draft(next, n, ctx)`; one target forward over
  `[next, ...drafts]`; sample per position with the request sampler over
  **batched** lm-head logits (this matches both oracles — mlx-lm and optiq
  batch the verify head; see the header comment in `src/spec/generate.ts`);
- accept longest exact-match prefix; emit accepted tokens + correction
  **through the existing onToken pipeline one at a time, in order** — the
  stop-sequence state machine and detokenizer must see a burst of ≤ n+1
  tokens per iteration (today's loop emits exactly 1; audit stop-match
  rollback across a burst — this is the subtle part);
- trim the target caches by `n - kAccept` (all our serial caches implement
  `isTrimmable()`/`trim()` — see `src/spec/generate.ts:213-220`); on a
  rotating cache whose ring has wrapped, **fall back to non-speculative
  decode for the rest of the generation** (upstream throws; a serve endpoint
  shouldn't).

**4. Flags + loading.** `serverRuntimeFlags()` in `src/cli.ts` gains
`--draft-model <query>` (registry-resolved like the main model) and
`--num-draft-tokens` (default 3). Load the draft in `loadContext`
(`src/server.ts:177-231`) after the main model. Tokenizer check: compare
vocab sizes; warn like upstream, and additionally hard-fail if tokenizer
families differ (we can detect; upstream's silent garbage mode isn't worth
inheriting).

**5. Memory admission (`fit`) interaction.** mlx-bun refuses/limits at load
via `fit()` (`src/fit.ts:172-229`; server check `src/server.ts:1012-1022`).
With a draft: effective usable bytes for the target =
`memoryBudget − draftWeightsBytes − draftKvBytesAt(ctx)` (draft KV grows with
the same context; compute with the draft's own config via `kvBytesAt`). Call
`fit()` for the target with that reduced `usableBytes`; refuse startup if
`maxSafeContext < 1` and log the draft-adjusted max context. Also surface the
pair in `mlx-bun fit` later (nice-to-have: `fit <target> --draft <draft>`).

**6. Prompt cache composition.** Two options; take the mlx-lm-shaped one:
`PromptCache` entries for spec requests store `caches:
[...targetCaches, ...draftCaches]` and the entry namespace gains the draft id
(extend the existing adapter-ns mechanism, `src/server.ts:974`) so
non-spec/spec entries never cross. `take()`/`put()` byte accounting already
sums whatever arrays the entry holds — no change needed there.

**7. Composition rules (v1):**
- **Serial lane only** — with `--batch N` + `--draft-model`, route requests
  like kv-quant does today (explicit spec ⇒ serial lane;
  `willBatch` in `generation-gateway.ts:113-127` gains `hasDraft`). Upstream
  behaves the same (`is_batchable = draft is None`).
- **kv-quant:** upstream composes (quantized caches are trimmable). v1: allow
  `--kv-quant off|4|8` with spec; gate `config` mode behind a follow-up
  (per-layer mixed configs make the trim/fallback matrix bigger).
- **Adapters/vision/logprobs:** out of scope v1 — reject the combination
  loudly, revisit.
- **Perf levers:** compiled-decode replays a 1-token decode graph — the n+1
  verify step won't hit it; run the spec loop eager v1 (flag interplay
  documented, not silently wrong).

**8. Oracle / verification.**
- **L1 gate:** greedy, fixed prompts: token-for-token equality with
  `mlx_lm.server --draft-model` / `stream_generate(draft_model=…)` from the
  oracle venv, same target/draft pair. Compare **spec-vs-spec**, not
  spec-vs-stock: both runtimes' spec paths batch the verify lm-head and
  legitimately diverge from stock decode at bf16 knife-edges (documented in
  `src/spec/generate.ts` header). Extend `scripts/oracle-spec.py` +
  `scripts/spec-bench.ts` for the A/B.
- **Acceptance-rate telemetry:** emit `drafted/accepted/targetCalls` in the
  response `usage`-adjacent stats (the `SpecStats` shape already exists) and
  into the benchmark path.
- **Perf gate:** `./benchmark.sh`-quality numbers on the current machine
  (label host/chip/RAM per the eval-DB rule): target/draft pair from the
  local registry, decode tok/s spec vs non-spec at the same flags, recorded
  in `benchmarks/RESULTS.md` only if reproduced on an idle machine.
- **Fallback correctness:** rotating-cache-wrap fallback test (long
  generation past the sliding window keeps producing = the non-spec
  continuation).

**9. Later: DSpark/assistant behind the same flag.** `--draft-model` value
dispatch by artifact: full model dir ⇒ `TwoModelSource` (L1); a
`gemma4_assistant` artifact (config `model_type` / tensor presence, as
`src/spec/drafter.ts:99-110` already sniffs) ⇒ an `AssistantSource` wrapping
`GemmaAssistantDrafter` (L2 — oracle is optiq's `spec_generate`); a DSpark
checkpoint ⇒ `DflashSource` wrapping `DflashDrafter` (L3 — KL/quality-gated,
per `docs/design/dspark-speculative-decoding.md`; its verify loop in
`src/spec/dspark/generate-dflash.ts` already has the greedy/sampling verdicts
to fold in). The serve loop, admission accounting, prompt-cache namespacing,
and stats do not change — only the source.

**Effort:** M (≈2 new files + flag/admission/prompt-cache plumbing; the
verify loop is ~200 lines with two in-repo references and a direct oracle).
**Risky parts:** multi-token bursts through the stop-sequence/detokenizer
pipeline; prompt-cache entry shape + namespacing; sampler parity in the draft
step; rotating-cache wrap fallback.

**Recommendation: build now** (first serving-side item after the in-flight
work): direct mlx-lm parity gap, big single-user win on this hardware class,
and it lays the interface DSpark needs to ever leave research.

---

## Proposed build order

Context: `fuse`/`convert`/`perplexity` are being built right now by another
agent; `sft_scope` is in flight. Order chosen to avoid touching the same
files as in-flight work first, and to sequence trainer-touching work after
`sft_scope`.

1. **`upload` CLI** — S, zero-risk, unblocks publishing the artifacts the
   in-flight `convert`/`fuse` work produces. (`src/cli.ts` +
   `src/hf-push.ts`, no overlap with in-flight files beyond a cli.ts case.)
2. **`serve --draft-model` (two-model, serial lane)** — M, flagship parity
   feature; includes the `DraftSource` interface.
3. **lm-eval shim for `evaluate`** — S, doc + script + a `/v1`
   logprobs-echo check; declares the tool covered-via-existing.
4. **`cache_prompt` + `generate --prompt-cache-file`** — M; KV serialization
   also future-proofs prompt-cache persistence for serve.
5. **`dwq`** — L, **after `sft_scope` lands** (both touch the trainer);
   two-phase target-precompute flow mandatory on this hardware.
6. **Assistant/DSpark sources behind `--draft-model`** — M, once (2) exists;
   L2 oracle = optiq spec_generate, L3 = KL-gated.
7. **`awq` / `gptq`** — L / M–L, parked: build only if KL evals show the
   L2 mixed-precision + DWQ stack losing to community AWQ/GPTQ artifacts.
   (`dynamic_quant`: covered today by `src/quantize/` — no work item.)
