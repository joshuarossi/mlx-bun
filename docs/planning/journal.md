# Engineering Journal

Ongoing, chronological record of AI/agent decisions, investigations, and
corrections — newest work appended under a dated heading. Purpose: bring
a fresh agent up to speed on *why* the code is the way it is. PLAN.md is
the what/when (phases, exit criteria); this is the narrative behind it.

## 2026-06-13 — MiniCPM5 starter port (branch `codex-minicpm5-starter-port`)

- Created a dedicated branch for the MiniCPM5 starter-model port.
  - Attempted `codex/minicpm5-starter-port`, but git ref creation was blocked by the sandbox/ref layout.
  - Used `codex-minicpm5-starter-port`.
- Corrected the execution order per Josh's direction:
  - Goldens first.
  - Build the port second.
  - Compare implementation against the goldens continuously.
- Downloaded `mlx-community/MiniCPM5-1B-OptiQ-4bit`.
  - Snapshot: `~/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`.
  - Verified by the repo downloader.
- Added MiniCPM5 snapshot constants to `tests/paths.ts`.
- Added `scripts/regen-minicpm5-goldens.ts`.
  - Uses `MLX_BUN_ORACLE_VENV=/Users/joshrossi/Code/mlx-lm-example/.venv`.
  - Drives stock `mlx_lm.load()` against the MiniCPM5 snapshot.
  - Writes `minicpm5-parity.json` and `minicpm5-logits-step*.bin`.
- Generated oracle goldens before porting.
  - Output dir on this machine: `goldens/apple-m1-max/`.
  - Prompt: `The capital of France is`.
  - Prompt ids: `[0, 608, 4894, 304, 6918, 357]`.
  - Logit steps: 4.
  - Greedy tokens: 100.
- Inspected MiniCPM5 config and tensor layout.
  - `model_type: "llama"`.
  - 24 full-attention layers.
  - Hidden size 1536.
  - 16 query heads, 2 KV heads.
  - Head dim 128.
  - RoPE theta 5,000,000.
  - RMS norm epsilon `1e-6`.
  - SiLU/SwiGLU MLP.
  - Untied embeddings with quantized `lm_head`.
  - Weight paths are standard `model.layers.N.*`, plus `model.embed_tokens`, `model.norm`, and `lm_head`.
- Decision: first implementation is the naive Llama path only.
  - No compiled decode.
  - No fused custom kernels.
  - No speculative decode.
  - No vision path.
  - Compare against goldens before optimizing.
- Added initial Llama port edits.
  - `src/config.ts`: flat Llama config defaults, full-attention layer types, default RoPE params.
  - `src/mlx/ffi.ts` / `src/mlx/ops.ts`: `mlx_sigmoid` binding for SwiGLU.
  - `src/model/minicpm5.ts`: concrete MiniCPM5 graph mirroring `mlx_lm.models.llama`.
  - `src/model/factory.ts`: dispatch this known `model_type === "llama"` artifact to `MiniCPM5Model`.
  - `src/generate.ts`: widen runtime model type and gate compiled decode to Gemma-only.
- Added `tests/minicpm5-parity.test.ts`.
  - Reads the MiniCPM5 goldens.
  - Runs the new `MiniCPM5Model`.
  - Initially required 12 greedy ids and the first 4 logit vectors; expanded to the full 100-token golden after the first green run.
- First MiniCPM5 parity run passed immediately.
  - Command: `bun test tests/minicpm5-parity.test.ts`.
  - Result: 12/12 greedy ids matched; first 4 full-logit vectors were bit-exact.
  - Decision: expand the test to the full 100-token golden before starter wiring.
- Expanded MiniCPM5 parity to 100 greedy tokens.
  - Command: `bun test tests/minicpm5-parity.test.ts`.
  - Result: 100/100 greedy ids matched; first 4 full-logit vectors remained bit-exact.
  - Decision: naive Llama graph is correct enough to proceed to integration wiring.
- Added shared supported-model predicate.
  - `src/model/support.ts`: supports `gemma4*` and `llama`.
  - CLI and server library support checks now use the same predicate.
- Swapped the first-run starter repo to `mlx-community/MiniCPM5-1B-OptiQ-4bit`.
  - Recommended Gemma download still runs in the background for the machine profile.
- Widened server context model type to `RuntimeModel`.
- Updated public/library/docs surfaces.
  - `src/index.ts` exports `MiniCPM5Model` and `RuntimeModel`.
  - `src/lora.ts` accepts `RuntimeModel` so server construction is type-consistent.
  - README quickstart and supported-model table now include MiniCPM5.
  - PLAN Phase 16 and publishing gate now record MiniCPM5 Track A as chosen/ported.
- Process/testing note from Josh:
  - Running the full sharded suite can start Bun test processes that load large models and in-process servers.
  - Do not run the full suite again casually during this branch; use focused MiniCPM5 parity/smokes unless Josh explicitly wants the full model-loading suite.
  - The suspected large Bun process was already killed before inspection; `ps` showed no remaining Bun processes afterward.
- Test-proof correction:
  - Josh called out that the `bun:test` pass looked suspiciously fast and was not good enough evidence as presented.
  - Verified with an explicit one-off script that config/weights/model construction occurs and first eval touches the model (`weightsBytes` about 0.907 GB, first argmax token 8181).
  - Added `scripts/check-minicpm5-port.ts`: hard check, no skip guards, requires snapshot + goldens, prints open/construct/eval timings, and compares 100 oracle tokens plus first 4 logit vectors.
  - Hard-check result:
    - `open`: 4.1 ms.
    - `construct`: 2.0 ms.
    - `first eval`: 81.7 ms.
    - `decode`: 100 tokens in 691.8 ms.
    - `parity`: 100/100 greedy ids, 100/100 full-logit vectors bit-exact.
  - Explanation: `Weights.open` and model construction are lazy/mmap-backed; the model is actually touched at eval time, not construction time.
- Oracle-strength correction:
  - Josh clarified that oracle parity means bit-for-bit comparison against oracle logits, not just token agreement plus a few early logits.
  - Changed MiniCPM5 golden regeneration to dump full last-position logits for all 100 decode steps.
  - Changed the hard check and parity test to require/compare all 100 logit binaries.
- MiniCPM5 parity matrix:
  - Standard bf16 KV mode must match stock `mlx-lm`.
  - Mixed precision KV mode using the shipped `kv_config.json` must match `mlx-optiq`.
  - Server default should use the shipped mixed-KV config.
  - `--kv-quant off` must remain the standard-cache mode.
  - Added `scripts/regen-minicpm5-kv-goldens.ts` and `tests/minicpm5-kv-parity.test.ts` for the OptiQ mixed-KV path.
- Strengthened `tests/minicpm5-parity.test.ts` after Josh's pushback.
  - Removed skip guards for this MiniCPM5 proof.
  - Requires the downloaded snapshot and MiniCPM5 goldens.
  - Constructs the model inside the test body, asserts `weightsBytes > 900 MB`, and prints open/construct/first-eval/decode timings.
  - The logit comparison is full-vector last-position logits from the same golden prompt; `lastPositionLogits()` forces evaluation via `toFloat32()`.
- Live chat failure diagnosis:
  - Josh opened `/chat`, sent `hi there`, and saw an empty assistant bubble.
  - Direct curl to `/v1/chat/completions` returned `QuantizedKVCache: use updateAndFetchQuantized`.
  - Cause: MiniCPM5 ships `kv_config.json`; the server applied mixed KV quant by default, but `MiniCPM5Model` only supports bf16 KV so far.
  - Temporary workaround was to serve MiniCPM5 bf16 KV only; this was later reverted once MiniCPM5 got QuantizedKVCache parity.
  - Also fixed `/chat` to surface streamed `{ error }` SSE payloads instead of swallowing them into an empty assistant bubble.
  - Verified with a temporary in-process server on an ephemeral port:
    - `/stats` reported KV mode `bf16`, 24 bf16 layers.
    - `/v1/chat/completions` for `hi there` returned HTTP 200 with assistant text.
    - Observed default MiniCPM5 behavior includes `<think>`; non-thinking starter UX still needs template/config handling.
- Naming/scope correction from Josh:
  - This branch should not become a generic Llama platform.
  - Renamed the concrete model file/class to `src/model/minicpm5.ts` / `MiniCPM5Model`.
  - The config still says `model_type: "llama"` because that is the upstream artifact; factory dispatch treats that as this known MiniCPM5 starter artifact for now.
  - Re-ran focused parity after the rename: 100/100 greedy ids matched; first 4 logits bit-exact.
- Tightened support recognition so this is not generic Llama support.
  - Registry/library support uses repo id `MiniCPM5-1B-OptiQ-4bit` plus `model_type: "llama"`.
  - Factory dispatch checks the known MiniCPM5 config shape before constructing `MiniCPM5Model`.
  - Other Llama configs throw unsupported instead of silently using the MiniCPM5 graph.
  - Re-ran focused parity after this tightening: 100/100 greedy ids matched; first 4 logits bit-exact.
- Completed the oracle-strength MiniCPM5 parity matrix.
  - Standard cache mode matches stock `mlx-lm`: 100/100 greedy ids and 100/100 full last-position logit vectors are bit-exact.
  - Mixed precision cache mode matches `mlx-optiq` with the shipped `kv_config.json`: 100/100 greedy ids and 100/100 full last-position logit vectors are bit-exact.
  - `MiniCPM5Model` now consumes `QuantizedKVCache` directly and routes quantized triples through `quantizedSdpa`.
  - Production generation now mirrors OptiQ's quantization order: first prompt prefill runs bf16, then populated caches are quantized before decode.
- Restored MiniCPM5 server default to mixed KV from `kv_config.json`.
  - Temporary in-process server `/stats` reported `mixed (kv_config.json)`, 6 kv8 layers and 18 kv4 layers.
  - `kvQuant: off` reported 24 bf16 layers and still served chat correctly.
  - Non-streaming and streaming `/v1/chat/completions` returned HTTP 200 without the prior `QuantizedKVCache: use updateAndFetchQuantized` error.
- Read the MiniCPM5 OptiQ manual.
  - MiniCPM5's template contract is `chat_template_kwargs.enable_thinking`.
  - Default starter behavior is no-think (`enable_thinking=false`), matching the manual's fast direct-answer mode.
  - Explicit `chat_template_kwargs: { "enable_thinking": true }` opens the `<think>` reasoning channel.
  - Server prompt rendering now forwards that flag and defaults MiniCPM5 to no-think when absent.
- Pi harness correction after Josh's pushback:
  - Mistake: briefly changed branch code toward `~/.pi/agent/models.json` upsert and described the generated extension as stale.
  - Correction: reverted branch code/docs/tests back to the existing extension-based live-discovery methodology; the generated extension is the path that worked for Gemma and must remain first-class.
  - Note: I had already run the harness while debugging, which modified Josh's local pi config outside the repo. Do not mutate that again without explicit instruction.
- MiniCPM5 tool-call corruption fix:
  - Reproduced Josh's broken output: `name="read"> name="path">...`.
  - Root cause: the server applied Gemma's tool sentinel token ids globally. In MiniCPM5, token 49 decodes to literal `<`, and `<function` / `<param` are added special tokens stripped by `decode(..., true)`.
  - Ported the OptiQ behavior: tool parsing is decoded-text based and active only when tools are declared. Gemma keeps its family sentinel path; MiniCPM5 tool-active decoding preserves special tokens and parses native `<function name="..."><param name="...">...` XML into OpenAI `tool_calls`.
  - Added `tests/minicpm5-tools.test.ts`, covering non-streaming and streaming tool calls with the real MiniCPM5 snapshot.
- Full-branch review pass after Josh reported "a lot of bugs" vs the Gemma 4 port quality. Four real defects found and fixed:
  1. **Multi-turn tool conversations crashed at render time.** MiniCPM5's template uses `[a, b]|min` in its assistant tool-call-history branch; `@huggingface/jinja` 0.5.9 has no `min`/`max` array filter, so every second round of an agent loop returned 400 `prompt build failed: Unknown ArrayValue filter: min`. This is why pi looked broken. Fix: `ChatTemplate.load` rewrites `[a, b]|min`/`|max` into conditional expressions. Verified byte-for-byte against the oracle venv's `apply_chat_template` for the agent round-trip case (`tests/minicpm5-template.test.ts`); Gemma template parity stays bit-exact.
  2. **Streaming with tools declared buffered the entire response.** `buffered-text` mode returned "" for every token and dumped everything at flush — pi streams nothing until the end, and prose before a tool call was dropped entirely when a call parsed. Fix: ported the oracle's incremental behavior (`_QwenXMLToolCallStreamParser` buffers only from the tool marker on): content streams live with a StopMatcher-style hold-back on `<tool_call>`/`<function` prefixes; only the markup is withheld; parse-failure falls back to releasing the raw text.
  3. **Tool param values were JSON-coerced regardless of schema.** `<param name="path">2025</param>` became the number 2025. Oracle (`_decode_tool_parameter_value` + `_tool_parameter_schema`) keeps string-typed params as raw text. Ported; also made the `<param>` regex CDATA-safe (a `</param>` inside CDATA no longer truncates the value). Unit tests added.
  4. **Sampling ignored the model's `generation_config.json`.** The server hardcoded temp 0.7 / no top-p; optiq serve injects the author-recommended sampling (`optiq/runtime/gen_config.py`) as defaults. Ported: `loadContext` reads `generation_config.json` (MiniCPM5: temp 0.9, top_p 0.95; Gemma: temp 1.0, top_k 64, top_p 0.95) and `toOptions` uses it when the request omits the field. Explicit request values still win. This was the likely "quality" gap on a 1B model.
  - Verification: MiniCPM5 parity (bf16 + mixed-KV) still 100/100 bit-exact; minicpm5-tools, tool-call, chat-template, tools-template, parity (Gemma 12B), server-tools, and server suites all green. Live two-turn agent round-trip (tool call → tool result → final answer) confirmed working in-process.

## 2026-06-16 — Segmented-backward LoRA training (PRs #9–10)

Long-context LoRA training was OOMing: MiniCPM5 @4096 spiked to ~25.5 GB full
backward because all activations had to stay live simultaneously.  The
segmented-backward design threads the backward segment-by-segment so only one
segment's activations are resident at a time.

The key implementation decision was to drive the per-segment backward with
`mlx_vjp` (a new `Vjp` binding in `autograd.ts`) rather than a surrogate
`value_and_grad` over a reconstructed loss.  The surrogate path leaked roughly
one activation buffer per segment per step because mlx `eval` does not detach;
`mlx_vjp` is explicit about what it differentiates and stops the leak.
Segment-boundary tensors are materialized as graph-free leaves via
`fromBytesCopy` for the same reason.

Phase A (MiniCPM5, PR #9) landed first: grads bit-exact vs the full backward
(relNorm 0.000%), peak 10.91 → 3.29 GB @2048, no leak, trains end-to-end via
`TrainConfig.segmentSize`.  The default training attention is `ops.sdpa`
(correct gradients, one fused kernel); `MLX_BUN_TRAIN_ATTN=flash` is an
opt-in for bit-exact grad comparison against the full backward only, because
`ops.sdpa` has a pre-existing eager-vs-autograd asymmetry in bf16 (~6%) that
is unrelated to the segmentation mechanism — the segmented path works
correctly under either setting.

Phase B (e4b / Gemma4, PR #10) was harder: e4b's KV-shared donor pattern
means multiple sharer segments reference the same K/V tensors produced by a
single producer segment, requiring cotangent accumulation across sharers before
the producer vjp can run.  Implemented `SegmentedBackwardGemma4` with a
two-boundary stream (per-layer-input + donor K/V) and a multi-output producer
vjp `[h, donorK, donorV]` with accumulated `[dh, dKV.k, dKV.v]` cotangents.
Grads are bit-exact for single-consumer donor reuse and 0.97% bf16-class for
multi-consumer accumulation (confirmed the full backward also sums in bf16, so
this is order-of-operations noise, not a logic bug).  e4b trains at 8 K context
(~17.5 GB, segSize=2) where the full backward would OOM (~70 GB).

A contiguity fix was also required: donor K/V are transposed views, so
`detachLeaf` must row-major-copy them before `rawBytes` reads linearly.

## 2026-06-16 — Qwen3.5 / MiniCPM5 reasoning-channel fix (PR #12)

Two serving-layer bugs left reasoning-capable models unusable in chat:

The first was a role-name mismatch.  pi-ai renames the system role to
`developer` for reasoning models.  Our chat templates only accepted
system/user/assistant/tool and returned 400.  The turn completed with
`stopReason: "error"` without throwing, so the browser saw an empty turn with no
error shown.  Fix: `normalizeMessages` maps developer→system (genuine OpenAI
compat — OpenAI itself uses the developer role), and `mapEventToFrames` surfaces
a `stopReason:"error"` turn as a visible error frame instead of silently
discarding it.

The second was reasoning leaking into content.  Qwen3.5 and MiniCPM5 templates
prime an *open* `<think>` tag in the generation prompt, so the model's first
token is the closing `</think>` — the opening tag never appears in the decoded
stream.  `ThinkingTagSplitter` was waiting for the open tag before routing
reasoning content into the OpenAI `reasoning_content` channel, so all of it
leaked into `content` instead.  Fix: `promptEndsInOpenThink` detects this
condition and seeds `ThinkingTagSplitter` via `startInThinking` so the splitter
begins in the reasoning state.

## 2026-06-16 — Adapters end-to-end (PR #13)

The goal was to make LoRA adapter switching a first-class operation in both the
web chat UI and the Pi CLI, without building a custom protocol — lean on Pi's
`before_provider_request` hook instead.

Server-side: `GET /v1/adapters/available` scans the two adapter stores
(`~/.cache/mlx-bun-finetunes`, `~/.cache/mlx-bun/adapters`) and returns
`{id, path, rank, scale, mounted}` for weight-bearing checkpoints (dataset-only
dirs are skipped).  `lora.ts` gained `listAvailableAdapters` for the scan and
base-model detection so the web selector can filter to compatible adapters only.

Pi hook: `pi-web.ts` registers `pi.on("before_provider_request")` to inject the
per-connection selected adapter into every outgoing provider payload using the
existing inline-extension pattern.  A `set_adapter` WebSocket message sets the
selection; default none leaves the payload unchanged so the base model runs.

Web chat: an adapter dropdown was added next to the Thinking pill, populated
from `/v1/adapters/available` on ready.  Selecting fires an idempotent `POST
/v1/adapters` then a `set_adapter` WS message.

CLI: `extensions/mlx-bun-adapter.ts` is a shipped Pi extension exposing
`/adapter <id> | off | list` and the same hook.  Both UIs control adapters
through Pi; no separate plumbing.

## 2026-06-17 — First-run onboarding UX

The previous startup story required knowing the right model ID, running a
separate download command, and manually opening a browser.  The new path:
`mlx-bun serve` (or bare `mlx-bun`) auto-downloads the starter if absent,
starts the server, and opens the chat UI.  If a localhost tab is already open it
focuses that tab rather than opening a duplicate (`--no-open` to skip).

The web chat empty state was updated with mlx-bun-centric starter chips and a
download-aware greeting.  A live background-download pill shows progress.  The
system prompt briefs the model on mlx-bun and its own identity, with framing
appropriate to MiniCPM5 being a fast starter while a larger model optionally
loads in the background.

`chat-template.ts` also tightened `supportsThinking` to require the `<think>`
channel we actually split, so e4b / harmony-format models no longer leak raw
reasoning markers into content for users who haven't configured a thinkingFormat.

The runtime-isolation design doc (`docs/design/runtime-isolation.md`) was also
written this session: inference running in-process on the Bun event loop is a
known UI-lag footgun when the GPU is busy.  The doc proposes moving inference to
a subprocess; the work is explicitly deferred (design, not started) — written
now so the root-cause analysis is available cold.

## 2026-06-17 — SigLIP vision sidecar for gemma-4 e4b

Ported optiq's `vlm/gemma4` SigLIP encoder as `src/vision/siglip.ts`: a 16-layer
vision transformer with clippable linears (trained clip bounds), manual-f32
RMS norms on q/k/v, on-device 2D RoPE, fused SDPA at scale=1.0, and GeGLU →
3×3 avg-pool → `MultimodalEmbedder` → `/embed_scale`.

The tower selection is driven by `vision_config.model_type`: e2b/e4b get
SigLIP, the 12B gets the existing encoder-free tower.  Lazy loading means
text-only sessions never pay for it.  `gemma4.ts`'s `forwardEmbeddings` was
extended to support per-layer-input models (e2b/e4b) — it previously threw for
that path — threading zeroed image-token ids into the per-layer forward matching
optiq's `where(text_mask, ids, 0)`.

Parity: every mlx primitive is bit-exact vs the optiq oracle (verified
model-free via `op-parity-{dump.py,check.ts}` — rms_norm, gelu, matmul, clip,
cos, sin, full multidim RoPE, sdpa, pool).  The residual ~1% feature divergence
is sub-bf16 full-graph composition order amplified by the encoder's scale=1.0
peaked softmax (the topped-out softmax distribution is highly sensitive to small
pre-softmax shifts in bf16).  The acceptance bar was exact spliced ids + greedy
prefix + grounded output, which passes.  Driving the residual to zero would
require matching optiq's exact op ordering across the full encoder; deferred as
a TODO.

## 2026-06-17 — Distribution: npm, bunx, Homebrew signed/notarized, direct download

The question was how to ship a standalone binary that runs on a user's Mac
without requiring Bun, Python, or anything else.  We settled on four parallel
install paths rather than picking one.

**npm / bunx**: `bunx mlx-bun` for users already in the Bun ecosystem.  A
`publish-release.sh` script and `bun run publish` alias handle the npm side.
Published as v0.0.4.

**Homebrew**: `scripts/release-binary.sh` builds a standalone binary, signs it
with a Developer ID (nested Mach-O first, then the executable with JIT
entitlements from `packaging/entitlements.plist`), notarizes via `AC_PROFILE`, and
produces a clean tarball + sha256 for the formula.
`packaging/homebrew/mlx-bun.rb` is the formula source of truth (self-contained
`libexec` bundle + `bin` symlink; Bun `realpath`s `execPath` so sibling dylibs
resolve after relocation).  The tap lives at `joshuarossi/homebrew-tap`.
`scripts/publish-release.sh` auto-syncs the formula sha256 on each release.
One fix was required: `--disable-library-validation` in the entitlements so
brew-relocated dylibs load without `CS_RESTRICT` blocking them.

**Direct download**: the notarized tarball passes Gatekeeper even when
downloaded via browser + Finder (quarantine worst case), so a stable versionless
URL (`releases/latest/download/mlx-bun-arm64.tar.gz`) is published alongside the
versioned asset and documented as a one-liner curl install.

**Embedded library**: existing path, unchanged (`docs/reference/embedding.md`).
