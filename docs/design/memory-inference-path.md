# Memory inference path rework — The Dreaming

Status: BUILT + VERIFIED (2026-06-28). Templating fix + single-model reuse
land and are ready; batching is implemented but is a measured *loss* for
the real memory workload (see "Verification results" below). Owner: memory
pipeline.

> ## Verification results (2026-06-28, M-series GPU, e4b OptiQ-4bit)
>
> Ran on `~/.cache/.../chunk-data-le4000/valid.jsonl` (HELD-OUT, not
> training rows) + the live vault (`memory.sqlite`, 2096 convs).
>
> 1. **tsc = 0** (whole repo). Non-GPU suite green:
>    `tests/memory-templating.test.ts` → 7/7 pass (4 CPU message-shape, 2
>    CPU training-parity, 1 GPU batched-order).
> 2. **Templating matches training — CONFIRMED.** `memoryPromptIds("chunk",
>    {system: CHUNK_SYSTEM, user}, …)` is **byte/id-identical** to
>    `encodeSftRow`'s prompt region for a real train row (the CPU parity
>    test asserts `ids.length` + `ids` equal and the rendered text starts
>    `<bos><|turn>system`). `CHUNK_SYSTEM` equals `messages[0].content`
>    verbatim. The chunk stage now decodes ON-distribution.
> 3. **Chunk adapter on-distribution — CONFIRMED.** On the 4 held-out
>    multi-chunk valid rows (7/10/11/35) the corrected `system+user` path
>    produced valid JSON with **all anchors in range** (4/4 each, except
>    row 11 which collapsed 2→1 — same as the old path) and faithful
>    labels (e.g. "Wonder Valley homestead land size and payment").
>    Caveat: the OLD user-only path on the SAME adapter *also* produced
>    valid in-range JSON on these rows — the adapter generalizes, so the
>    behavioral delta is minor (label phrasing). The load-bearing win is
>    the byte-exact training-contract match, not a dramatic quality jump on
>    these easy/short held-out rows (the valid set is ~90% single-chunk).
> 4. **Batching — IMPLEMENTED, but NOT a speedup for memory stages.**
>    - 8 extract-style prompts (~400-token prefills, maxTokens=96):
>      **batched 9345ms vs serial 5001ms = 0.54x (≈1.9x SLOWER)**, 8/8
>      exact match.
>    - 8 short replies (maxTokens=24): batched 2085ms vs serial 1067ms =
>      0.51x SLOWER, **7/8** match (row 6 "H2O" vs "Water" — the documented
>      near-tie decode-path divergence, `runner.ts:104-108`, not an
>      ordering/contamination bug).
>    - 16 short uniform one-liners (maxTokens=64): serial(width=1) 6168ms
>      vs batched 5139ms (width=8) = **~1.2x faster** — batching only wins
>      for many short *uniform* prompts where prefill-pad waste is small.
>
>    Root cause: the bit-exact serial path prefills each sequence with one
>    efficient single-sequence forward; the `BatchScheduler` pads to the
>    batch's max prompt length, so heterogeneous long prefills (exactly the
>    EXTRACT/chunk shape) waste compute and lose to serial.
>
> **Recommendation:** ship the templating fix + single-model reuse (the
> real wins); **default `MLX_BUN_MEMORY_BATCH=1`** (serial bit-exact) until
> the scheduler grows length-bucketed / ragged prefill — current batching
> regresses the EXTRACT stage AND can diverge on near-ties. Re-segmenting
> the corpus on the corrected on-distribution path is *principled but
> low-urgency* (old output was already valid in-range; delta is modest).

*(Original design statement below — superseded; the rework is BUILT, see the
banner at the top of this file.)*

Scope: the local-model call seam used by every Dreaming stage
(`src/memory/*` → `callLocal` → `src/eval/runner.ts generateText`). Two
defects, one rework.

## Problem (verified)

1. **Off-distribution chunk decode (correctness).** The `memory-chunk`
   adapter (`e4b-chunk-300`) was SFT'd on rows shaped
   `{messages:[{role:"system",…},{role:"user",…},{role:"assistant",…}]}`
   and training renders the *full* message list, system turn included
   (`src/train/dataset.ts:86-88`, `:98-101`). The e4b chat template emits
   a **distinct** `<|turn>system\n…<turn|>\n` block when
   `messages[0].role in ['system','developer']`
   (`chat_template.jinja:179-204`) — this is the Gemma-4 `<|turn>…<turn|>`
   format that supports a native system role. But live inference renders
   the prompt as a **single user turn**:
   `tm.template!.render([{ role: "user", content: body }], …)`
   (`src/eval/runner.ts:139-141`), so the entire system segment is
   dropped. Verified rendered shapes on the real e4b snapshot:
   - training: `"<bos><|turn>system\n{SYS}<turn|>\n<|turn>user\n{USER}<turn|>\n<|turn>model\n"`
   - live:     `"<bos><|turn>user\n{USER}<turn|>\n<|turn>model\n"`

   The chunk adapter is decoded with its trained system prompt missing — a
   real distributional gap, not cosmetic.

2. **Single-loaded + serial (throughput).** `callLocal`
   (`src/memory/model.ts:62-75`) loads its **own** `TaskModel` per
   `(stage, adapter-present)` key (`:46-57`) and decodes serially through
   `greedyDecodeBitExact` (`runner.ts:109-131`), one forward loop per
   call. The hot stages are embarrassingly parallel (EXTRACT: one 128-tok
   call per chunk over thousands; ROUTE/SECTION: 4–16-tok binary gates;
   SEGMENT: one 2048-tok call per conversation) but run one at a time.

The server already solves (1): `server.ts:977` renders the **whole**
`normalizeMessages(req.messages)` array (system + user + …) through the
same `ChatTemplate`, so system lands as its distinct block. The fix is to
make the memory path do the same, and to route batchable stages through
the in-process continuous-batching engine.

## (a) Routing decision — in-process gateway, NOT the HTTP server

**Decision: drive an in-process `BatchScheduler` (via a thin
`MemoryExecutor`) over ONE shared `RuntimeModel`.** Not the HTTP server.

Rationale:
- **No-start-servers rule** (CLAUDE.md): an agent/bootstrap job cannot
  `mlx-bun serve`; the HTTP route presupposes an externally-managed
  server. Coupling the offline bootstrap to a running server is fragile.
- **The gateway/scheduler are pure objects.** `GenerationGateway`'s
  constructor is `new GenerationGateway(model, batch, serialRun)`
  (`generation-gateway.ts:77-83`) — no HTTP. `BatchScheduler`'s is
  `new BatchScheduler(model, { maxBatch, lock })`
  (`batch-scheduler.ts:101`). Both are constructible in-process over a
  `loadTaskModel(...).model`.
- **Per-request adapter does not batch on the server anyway.** Any request
  with an adapter is forced to the serial lane on the server too
  (`willBatch` excludes `hasAdapters`, `generation-gateway.ts:103`;
  `server.ts:1570-1577`). So HTTP buys us nothing for the one adapter we
  have (chunk) and adds a process boundary.
- **The workload is exactly what continuous batching targets** — a long
  offline sweep over all eligible conversations/chunks
  (`chunk.ts:220-286`; the extract/route/section hot loops).

**Fallback:** when only one row is in flight (N==1) or batching is
disabled, `MemoryExecutor` decodes through the **existing bit-exact greedy
path** (`greedyDecodeBitExact`, `runner.ts:109-131`) so single calls keep
token-for-token parity. The in-process scheduler is the throughput lane,
not a hard dependency.

We construct the executor directly over `BatchScheduler.submit` rather
than `GenerationGateway.run`, because `gateway.willBatch` hard-excludes
adapters (`:103`) — routing the chunk stage through `run()` would silently
fall back to serial. Driving `scheduler.submit()` directly lets us manage
`loraState.active` ourselves for the chunk batch (see (c)).

## (b) Templating — system vs user per stage

The new seam renders a **message array** through the same template path
the server uses, instead of wrapping `body` as a lone user turn.

Render contract (mirrors `server.ts:977-980`):
```
const rendered = template.render(messages, { addGenerationPrompt: true });
const ids = tokenizer.encode(rendered, /* addSpecialTokens */ false); // template emits BOS
// BOS-dedupe identical to promptIdsFor (server.ts:979-980)
```
`messages` is `[{role:"system",content:SYS}, {role:"user",content:USER}]`
(system omitted when a stage has none → user-only, today's shape). This is
byte-identical to how `encodeSftRow` builds the prompt region
(`dataset.ts:98-101`, `render(promptMessages, {addGenerationPrompt:true})`).

**Per-stage system/user split:**

| stage string | adapter | system (instruction + policy) | user (content to operate on) | maxTokens |
|---|---|---|---|---|
| `chunk` | `memory-chunk`→e4b-chunk-300 | **exact trained system** (below) | `CHUNK_PROMPT` body + inlined Meta pages + `Here is the conversation:` + `formatConversation(...)` | 2048 |
| `entity` | base | extraction instruction + Entities policy | chunk/text to extract from | 128 |
| `route` | base | `You answer only 'yes' or 'no'.` + Bucketing policy | the disambiguate/engagesAsSubject question | 4 |
| `section` | base | binary / new-section instruction | title/section/gist content | 4 / 16 |
| `synthesis` | base | editorial/synthesis instruction + editorial policy | entity/chunks/article-body | 8–512 |
| `editor` | base | section-editorial instruction + Editorial_Guidelines | section body to edit | 160–512 |

**Chunk stage system prompt is load-bearing and MUST match training
byte-for-byte.** Add a constant to `src/memory/chunk.ts` reproducing the
trained `messages[0].content` verbatim (from
`~/.cache/mlx-bun/mlx-bun-finetunes/chunk-data-le4000/train.jsonl`):

```
export const CHUNK_SYSTEM = `You are a precise conversation-segmentation engine, not a coding assistant and not a chat assistant. You receive ONE conversation transcript and return its topic segmentation.

Absolute output contract (overrides any conversational instinct):
- Your entire response MUST be a single JSON object, parseable by JSON.parse with no edits.
- No prose, no preamble, no explanation, no follow-up question, no markdown code fences, no tool calls. The first character you emit is "{" and the last is "}".
- Never ask for clarification or more data — the transcript in the message IS the data. If it has no meaningful content, return {"chunks": []}.
- Use only message UUIDs present in the provided transcript; never invent or alter a UUID.

Follow the segmentation rules and JSON schema in the message exactly.`;
```

The chunk SEGMENT call becomes `callLocal("chunk", { system: CHUNK_SYSTEM,
user: promptHead() + formatConversation(...) }, {maxTokens})`.

**Secondary: chunk USER-turn content drift.** The live `CHUNK_PROMPT`
(`chunk.ts:30-69`) also diverges from the trained user turn on four axes
and these matter for true on-distribution behavior, but are a SEPARATE
fix from the role bug:
- (a) `chunk.ts:32` adds `Use ONLY content from the conversation provided
  below; never copy any name…` — absent in training.
- (b) `META_POLICY_PAGES = ["Chunking","Topics_to_Ignore"]` (`chunk.ts:72`)
  inlines **2** pages; training inlined **8** (Article_Conventions,
  Bucketing, Buckets, Category_Definitions, Chunking,
  Editorial_Guidelines, Synthesis_Pipeline, Topics_to_Ignore).
- (c) label guidance rewritten to abstract GOOD/BAD shape vs trained
  inline examples (`chunk.ts:55-57`).
- (d) training POLICY line names the vault path `/Users/joshrossi/Dreaming/Meta/`;
  live drops it.

Recommendation: land the **role fix first** (biggest, cheapest win), then
reconcile the user turn to the trained shape *or* retrain `e4b-chunk-300`
against the current `CHUNK_PROMPT`. Pick one; do not leave it
half-aligned. The role fix alone moves the chunk stage substantially
closer to its training distribution.

For the **base** stages (everything except chunk), the system/user split
is a quality choice for the base instruct model (which was trained to
honor a system turn) — apply it, but there is no trained adapter to match,
so byte-exactness is not required there.

## (c) Batching — per-stage homogeneous-adapter batches

`loraState.active` is a **single global field** on the model, set by
`generate()`'s `adapterScoped` (`generate.ts:235-247`) and applied
uniformly to every row; the scheduler never touches it (it calls
`model.forwardHidden` directly — zero `loraState` refs in
`batch-scheduler.ts`). Therefore **a batch is necessarily single-adapter
(or all-base).** We cannot mix chunk-adapter and base rows in one batch.

This fits the pipeline naturally because `callLocalBatch` is invoked
**per stage**, and stage→adapter is fixed (`adapterDirFor`,
`model.ts:38-41`; only `memory-chunk` exists on disk):

- **Base stages (entity / route / section / synthesis / editor):** batch
  with **zero** adapter friction — `loraState.active = []`. Submit N rows
  to the scheduler. The easy, highest-volume win (EXTRACT first: uniform
  128-tok prompt, one per chunk, no inter-call dependency).
- **Chunk stage:** set `model.loraState.active = ["memory-chunk"]`
  **once** for the whole stage batch, submit only chunk rows, reset to
  `[]` after. Because `forwardHidden` reads the global `loraState`, all
  rows get the adapter uniformly. The executor owns the model exclusively
  during the batch (the scheduler holds the lock for its active span), so
  there is no concurrent serial generation to clobber `loraState`.

**Decode-path caveat.** The batched lane samples via `generate()`'s
sampler path (greedy = argmax over `forwardHidden`/`logitsFromHidden`),
NOT the runner's raw-`forward` bit-exact greedy. The runner warns these
diverge on near-ties past ~32 tokens (`runner.ts:104-108`). For chunk's
2048-tok JSON and the binary gates this is expected to be fine (chunk eval
is well-formedness, per memory notes), but it MUST be validated against
the greedy reference before the chunk batch is trusted (see verification).

**Batching priority** (from the usage survey, batchable structure):
1. EXTRACT (`entity`, base, 128 tok, 1/chunk over thousands) — prime win,
   uniform prompt, no dependency.
2. ROUTE + SECTION binaries (`route`/`section`, base, 4–16 tok) — batch
   the per-chunk N-section grid and per-candidate gates (the trailing
   new-section call depends on all-no — keep it after the batch).
3. SEGMENT (`chunk`, adapter, 2048 tok, 1/conversation) — batchable across
   conversations, but long outputs; the only adapter-bound batch.
4. SYNTHESIZE/WIKIFY drafts (`synthesis`/`editor`, 96–512 tok) — batch
   per-phase within an article (the N independent section drafts), NOT
   whole-article (outline→draft and the leak-retry are data-dependent).
5. RECONCILE — largely serial (`next` mutated in place); leave on the
   serial fallback; only the independent binary classifiers batch.

The hot loops stay where they are; we change *how a set of independent
calls is submitted*. The cleanest refactor: where a stage today does
`for (x of xs) await call(buildPrompt(x))`, collect `xs`, build all
messages, and `await callLocalBatch(stage, messages[])` → results[].
Start with EXTRACT and SEGMENT; leave dependent loops on serial `callLocal`.

## (d) API surface

`src/memory/model.ts` grows a messages-aware seam and a batch seam; the
single-user-turn `generateText` overload is no longer used by the memory
path.

```ts
export interface LocalInput {
  /** System turn (instruction + policy). Omit for a user-only prompt. */
  system?: string;
  /** User turn (the content to operate on). */
  user: string;
}

/** One call. N==1 → bit-exact greedy (runner.ts:109-131). */
export async function callLocal(
  stage: string,
  input: LocalInput,
  opts?: { maxTokens?: number },
): Promise<string>;

/** N independent calls for one stage (homogeneous adapter). Submitted to
 *  the shared in-process BatchScheduler when batch>1; otherwise looped on
 *  the bit-exact greedy path. Order-preserving: out[i] ↔ inputs[i]. */
export async function callLocalBatch(
  stage: string,
  inputs: LocalInput[],
  opts?: { maxTokens?: number },
): Promise<string[]>;
```

Backing implementation — a module-level `MemoryExecutor` (lazy singleton):
- holds ONE `RuntimeModel` (via `loadTaskModel(MODEL_ID)`), ONE
  `AdapterManager` with `memory-chunk` mounted once, ONE `BatchScheduler`
  (constructed with an in-process `AsyncMutex`-backed lock), and the
  tokenizer + template.
- `render(input)` → messages array → `template.render(messages,
  {addGenerationPrompt:true})` → `encode(text, false)` → BOS-dedupe →
  `promptIds`.
- `callLocalBatch(stage, inputs)`:
  1. `active = adapterDirFor(stage) ? ["memory-chunk"] : []`.
  2. `model.loraState.active = active` for the batch's lifetime.
  3. render all inputs → promptIds; build a per-row token sink (decode via
     `tokenizer.decode`); `Promise.all(rows.map(r =>
     scheduler.submit({promptIds, maxTokens, eosTokenIds, sample: greedy,
     onToken: collect})))`.
  4. reset `model.loraState.active = []`; return decoded strings in order.
- `callLocal` delegates to `callLocalBatch(stage, [input])[0]` when
  batching is enabled, else the bit-exact greedy single decode.

This **consolidates** the per-stage `TaskModel` instances
(`model.ts:46-57`) into one shared model — reuse AND batching in one move.
Stage builders change from passing a `prompt` string to passing
`{system?, user}` (chunk supplies `CHUNK_SYSTEM`).

`generateText`'s single-user render (`runner.ts:139-141`) is left intact
for the eval suite (its own contract), but the memory path stops calling
it. Optionally add a system-aware overload to `generateText` later to
share the render helper; not required for this rework.

## (e) Re-segment the partial import — YES

The current import (720/2096 conversations segmented) was chunked with the
**old single-user template** (no system role) AND only 2 Meta pages — i.e.
the off-distribution shape this rework fixes. For consistency the whole
corpus should be segmented under one (correct) prompt regime.

Decision: **re-segment all 720 already-chunked conversations** after the
role fix lands. It is cheap and safe:
- SEGMENT is idempotent — `chunkConversations` deletes prior chunks per
  conv and resets `chunked_at` on success (`chunk.ts:262-273`).
- To force a re-run, clear `chunked_at` (set NULL) for the 720 so
  `selectEligible` re-admits them; then run the batched SEGMENT.
- Downstream stages key off chunk ids; re-segmentation changes chunk
  boundaries/labels, so the dependent EXTRACT/ROUTE/SYNTH state for those
  convs must be invalidated too (treat as a fresh segmentation). Sequence
  the bootstrap so re-segmentation precedes the downstream sweep.

Do NOT mix two segmentation regimes in one vault; re-segment for a clean
baseline.

## (f) Implementation steps

1. **Template seam.** Add `MemoryExecutor` in `src/memory/model.ts`: one
   shared `RuntimeModel` + tokenizer + template + `AdapterManager`
   (mount `memory-chunk`). Implement `render({system?,user})` →
   promptIds (render → encode(false) → BOS-dedupe, matching
   `server.ts:979-980`).
2. **API.** Replace `callLocal(stage, prompt, opts)` with
   `callLocal(stage, LocalInput, opts)` + `callLocalBatch`. Single-call
   path keeps bit-exact greedy.
3. **Chunk system.** Add `CHUNK_SYSTEM` (verbatim trained text) to
   `chunk.ts`; change the SEGMENT call to pass `{system: CHUNK_SYSTEM,
   user: promptHead()+formatConversation(...)}`.
4. **Per-stage splits.** Update entity/route/section/synthesis/editor
   builders to return `{system, user}` (move instruction+policy → system,
   content → user). Mechanical; one stage at a time, tsc-green each.
5. **Batch the hot stages.** Convert EXTRACT first
   (`entity.ts`/`stages.ts:333-340`), then SEGMENT
   (`chunk.ts:220-286`), to collect inputs and call `callLocalBatch`.
   Leave dependent loops (reconcile, outline→draft) on serial `callLocal`.
6. **loraState management.** In `callLocalBatch`, set/reset
   `model.loraState.active` around the chunk batch; assert base stages
   submit with `active=[]`.
7. **Re-segment.** One-off: NULL `chunked_at` for the 720 imported convs,
   invalidate downstream state, run batched SEGMENT, then the downstream
   sweep.
8. **tsc 0** across the repo incl. `scripts/experiments` (standing rule).

## Verification plan

- **Templating parity (the correctness gate).** Render the chunk
  `{system,user}` through the new seam and assert the token ids equal the
  training prompt-region ids for a real `train.jsonl` row: rebuild the row
  via `encodeSftRow`'s prompt render (`dataset.ts:98-101`,
  `render(messages,{addGenerationPrompt:true})`) and compare. Must be
  byte/id-identical (same `<|turn>system…<turn|>` block, single BOS).
  This is the foundation — verify it before any generation claim
  (standing "verify the foundation" rule).
- **System-present smoke.** Decode one conversation with the new seam and
  confirm the rendered prompt contains the system block (not user-only);
  diff against the old render to show the gap closed.
- **Batching correctness.** For a base stage (EXTRACT) and the chunk
  stage, compare `callLocalBatch([a,b,c])` against three serial
  `callLocal` greedy decodes. Base/binary outputs should match; for chunk,
  validate the batched (sampler-path) output against the bit-exact greedy
  reference and accept divergence only within the documented near-tie
  envelope (chunk eval = well-formedness: valid JSON, in-range anchors).
- **Chunk-adapter behavior.** Confirm `loraState.active=["memory-chunk"]`
  is set for the chunk batch and `[]` for base batches (assert in test).
  Re-run `scripts/chunk-eval.ts` before/after the role fix; expect
  well-formedness and boundary/label quality to improve now that decode is
  on-distribution.
- **No-leak / single-model.** Confirm the executor loads ONE model (not
  per-stage instances) and peak memory does not regress vs the current
  per-stage cache; watch for KV/loraState leaks across batches.
- **Re-segment sanity.** After re-segmenting the 720, spot-check chunk
  counts/labels vs the old segmentation and confirm downstream stages
  re-run cleanly on the new boundaries.

## Risks

- **Decode divergence on the batched lane.** generate()'s sampler path ≠
  the runner's raw-forward greedy past ~32 tokens on near-ties
  (`runner.ts:104-108`). Mitigation: greedy sampler + well-formedness
  validation; keep the bit-exact greedy path for the single-call fallback
  and for any stage that proves sensitive.
- **Global `loraState` clobber.** The chunk batch sets a global field; any
  concurrent generation would corrupt it. The bootstrap runs one executor
  with exclusive model ownership, so this is safe — but the seam must
  never be shared with a live server process.
- **User-turn content drift (chunk).** The role fix alone does not close
  the 8-vs-2 Meta-pages / examples / vault-path drift. Track as a
  follow-up: reconcile `CHUNK_PROMPT` to training or retrain the adapter.
  Until then the chunk stage is *closer* to, but not fully on,
  distribution.
- **Re-segment blast radius.** Re-segmentation invalidates downstream
  state for the 720 convs; sequencing errors could leave orphaned
  extract/route rows. Mitigation: invalidate-then-resweep, idempotent
  stages, verify counts.
- **Single trained adapter assumption.** Only `memory-chunk` exists. If
  future stages gain adapters, `callLocalBatch` already batches per stage
  (homogeneous adapter) — but mixing adapters in one batch remains
  impossible by construction; keep stages separate.
