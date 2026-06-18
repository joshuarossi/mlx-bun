# Runtime isolation — the AI may crash, the UI never may

Status: **design** (not started — deferred future work; no scheduled PLAN.md phase)
Owner: serving layer / runtime
Default today: inference runs **in-process**, on the server's event-loop
thread. This doc proposes moving it to a **subprocess**.

## Goal

One `mlx-bun` process plays three or four roles at once:

1. **Serves the web UI** (static assets, the chat page).
2. **Serves the API** (`/v1/*` for the web UI, the CLI, and external
   agents).
3. **Runs the AI** (weight load, prefill, decode — the heavy GPU work).

One executable doing all of this is the product's whole charm, and for
most people, most of the time, it is perfect. It breaks in one specific
way: when the AI is working hard — say an agentic pipeline classifying a
photo library — the **web UI lags**. Page refreshes stall, `/status`
polls hang, chat messages queue behind the GPU.

Waiting for a *chat reply* is fine and expected (local inference takes
time; hosted services take up to a minute too). A **laggy UI is neither
normal nor acceptable.** The UI must stay responsive no matter what the
AI is doing — and if the AI process dies (an uncatchable GPU OOM), the UI
must survive and report it, not go down with it.

## Root cause — blocking work on the event-loop thread

The server is a single Bun event loop. The governing principle of an
event loop is: **the loop thread may only ever do non-blocking work.**
We violate it by running the synchronous MLX FFI eval loop *on* that
thread.

Concretely:

- **The per-token GPU read is a blocking FFI call.** Each decode step
  ends with `ops.itemUint32(cur)` → `a.eval()` → `mlx_eval`
  (`src/mlx/ops.ts:471`), which parks the single JS thread until the GPU
  returns. Compute is dispatched async (`asyncEvalAll` + decode
  pipelining, `src/generate.ts:386`) — good — but reading the value back
  over `bun:ffi` is a hard, synchronous wait on the main thread. There is
  no thread handoff.
- **The loop yields only *microtasks*, not *macrotasks*.** Bun services
  I/O — accepting connections, answering `/status`, serving the page —
  only at macrotask boundaries. A bare `yield` in the async generator
  plus an `await` of an already-resolved value drains the microtask
  queue without ever reaching the I/O phase.
- **Streaming partially hides this; non-streaming does not.** The SSE
  path's `onToken` returns `new Promise(r => setImmediate(r))` ~every
  25 ms (`src/server.ts:1341`) — a real macrotask yield, so the page
  breathes. The **non-streaming** path's `onToken` returns `undefined`
  every token (`src/server.ts:1407`), so the whole completion is one
  blocking-FFI-plus-microtask chain and the loop is starved start to
  finish.
- **Prefill never yields at all.** The chunked prompt eval calls
  `ops.evalAll(...)` synchronously with no `await` between chunks
  (`src/generate.ts:294`). A long prompt freezes the page for the full
  prefill *even in streaming mode*.

### Why yielding alone is not the fix

A `setImmediate` yield can interleave I/O *between* tokens, but it
**cannot interrupt an in-flight `mlx_eval`** — that C call is atomic from
JS's view. Each token blocks for tens of ms; a prefill blocks one big
chunk (hundreds of ms to seconds) with no yield point possible inside the
kernel. So perfect yielding gives the UI thin inter-token slices, not
isolation. Adequate for "chat plus occasional"; inadequate for "agentic
pipeline running flat-out while I refresh the page." For true isolation
the blocking work must leave the thread.

## Decision — subprocess, not worker thread

Move the AI runtime off the event-loop thread. Two ways:

- **Worker thread** (Bun `Worker`): shares the process, cheapest IPC
  (a `SharedArrayBuffer` token ring). But a GPU OOM / SIGTRAP — which our
  own notes flag as **uncatchable** (CLAUDE.md "async GPU exec OOM is
  uncatchable") — takes down the whole process, **including the UI
  server**.
- **Subprocess** (`Bun.spawn`): crash isolation. An MLX OOM kills the
  inference process; the UI/API server survives, reports it, and
  respawns. Heavier IPC, but on a single-user local box a pipe/socket is
  trivially fast next to token cadence.

**Decision: subprocess.** The product rule is "the AI may crash, the UI
never may," and only address-space isolation delivers that against an
uncatchable fault. It also reuses machinery the repo has already proven.

## We already built the blueprint — for jobs

`src/jobs/runner.ts` already does exactly this for the *other* heavy GPU
consumers (quantize / finetune):

- `submitSubprocess()` creates a job row and `Bun.spawn`s the binary as a
  child (`src/jobs/runner.ts:210`, entry `src/jobs/job-entry.ts`).
- A single global **GPU lease** (`gpuLeaseHolder`) serializes GPU access;
  `isGpuBusy()` / `currentGpuJob()` (`src/jobs/runner.ts:159`) expose it,
  **and the server already gates token generation on it** so
  quantize/finetune don't fight live inference.
- IPC is a file-backed SQLite job store + stdout/stderr line pumping into
  a log + an SSE tail (`src/jobs/sse.ts`).

So the pattern — heavy GPU work → its own process → server thread stays
free, serialized by one lease — is established and tested. **Inference is
the one heavy consumer still running inline on the event-loop thread.**
It is the exception, and it is the one people hit on every message.

## The seam already exists

Request handlers do not call `generate()` directly — they call
`gateway.run(promptIds, options, onToken, vision, shape)`
(`src/serve/generation-gateway.ts:108`, call sites `src/server.ts:1331`
and `:1407`). The `GenerationGateway` is the abstraction boundary between
the HTTP layer and execution. **We replace what is behind it** (inline
`generate()` → an IPC client that talks to the inference subprocess); the
HTTP/SSE layer, the `onToken` contract, and the `false`-halts-generation
semantics are unchanged.

## Target architecture

- **Main process = pure reactor.** `Bun.serve` does static UI + the API
  surface + routing + tokenization/templating/SSE encoding (all cheap,
  non-blocking JS). **Zero MLX calls.** Once generation is off-thread,
  nothing else on the main thread blocks — static serves and `/status`
  are already async; they lag today only because the loop is
  monopolized. So this alone makes the UI instant.
- **Inference runtime = a persistent subprocess** owning the model +
  Metal context, doing prefill/decode, streaming tokens back. Persistent
  (not spawn-per-request): weight load is the cost, can't pay it per
  request. One process, one model, one GPU.
- **One GPU lease governs all consumers** — live inference, agentic API
  calls, quantize, finetune. The GPU is the single serialized resource
  (matching the single-user reality: chat waiting behind the photo
  pipeline is the *acceptable* kind of waiting), while UI/API I/O is
  fully parallel and never waits.

```
┌──────────────────────────────────────────────┐
│  main process (event loop — never blocks)     │
│  Bun.serve: static UI · /v1/* API · routing   │
│  tokenize · template · SSE encode             │
│        │  gateway.run() = IPC client          │
└────────┼──────────────────────────────────────┘
         │  request ↓        ↑ token stream
┌────────┼──────────────────────────────────────┐
│  inference subprocess (may block freely)       │
│  owns model + Metal · prefill · decode         │
│  holds the GPU lease while generating          │
└────────────────────────────────────────────────┘
   (crash here ⇒ parent respawns; UI untouched)
```

## IPC sketch

- **Transport:** Bun supports a structured `ipc` channel on `Bun.spawn`
  (parent ⇄ child message passing); a unix domain socket is the
  fallback. Tokens are slow relative to message passing, so per-token
  messages are fine; batch a few if needed. (Jobs use stdout-line + the
  SQLite store, which is right for fire-and-forget long jobs but too
  coarse for low-latency per-token streaming — inference wants the
  message channel.)
- **Request → child:** `{ promptIds, options, shape }`. Tokenization and
  template rendering stay in the parent (cheap); the child receives
  token ids.
- **Child → parent:** a stream of `{ token }` messages, then a final
  `{ stats }`. The parent's gateway client invokes the handler's existing
  `onToken` per message — per-row SSE fan-out keeps working unchanged.
- **Cancellation / backpressure:** `onToken` returning `false` (stop
  sequence) or a client disconnect must abort the in-flight generation —
  send a cancel message; the child checks it at the decode-loop boundary
  (the natural place `generate()` already yields).
- **Crash handling:** child `exited` non-zero ⇒ fail any in-flight
  request with a clean 5xx, respawn the child, reload the model. The UI
  server never noticed.

## Lease reconciliation (the one genuinely new problem)

Jobs are *transient* (spawn → run → exit, lease released on exit). The
inference worker is *persistent* (resident, holds the model in RAM). They
must share one GPU coherently:

- A quantize/finetune job needs the GPU while the inference worker is
  resident. Options: (a) the inference worker **drains and yields** the
  lease for the job's duration (finish current gen, pause admission,
  release), then resumes; (b) the persistent worker **also runs the
  jobs** (one GPU owner, no cross-process lease at all). (b) is cleaner
  long-term but couples job lifecycle into the inference process; (a)
  keeps jobs as-is. **Open — pick during phase 3.**
- On 24 GB, the resident model already dominates memory; a concurrent
  finetune that also needs multi-GB is an OOM footgun regardless of
  process layout. The lease must remain *exclusive*, never truly
  concurrent on the GPU.

## What this unlocks / simplifies

- **Delete the yield hacks.** Once the loop blocks only in the child, the
  `setImmediate` throttle (`src/server.ts:1341`) and any prefill
  chunk-yielding (`src/generate.ts:294`) are no longer needed for UI
  responsiveness — the hot path gets cleaner and marginally faster.
- **Folds into model hot-swap** (see PRODUCT_ROADMAP "Model hot-swap from
  the UI"): the model lives in the worker, so `loadContext` and swap
  happen there while the main thread serves a live "swapping…" state.
  These two items converge on "the model is not on the main thread."
- **Flags the next blocker:** vision preprocessing (`Bun.Image` decode,
  `src/vision/preprocess.ts`) is also main-thread CPU work and should
  ride into the worker, or it becomes the next source of lag.

## Staging (incremental, not big-bang)

- **Phase 1 — stop the bleeding (in-process).** Macrotask-yield the
  non-streaming `onToken` (`src/server.ts:1407`) and the prefill chunk
  loop (`src/generate.ts:294`), mirroring what streaming already does.
  Trivial change; kills the acute hang for the common case. Does **not**
  isolate the UI under sustained load — that's Phase 2.
- **Phase 2 — inference subprocess behind the gateway.** Stand up the
  persistent inference child + IPC; make `GenerationGateway` an IPC
  client. Main process makes zero MLX calls. The HTTP layer is untouched.
  This is the real fix.
- **Phase 3 — unify the GPU lease.** Bring inference under the same lease
  as quantize/finetune so all GPU consumers schedule coherently; resolve
  the persistent-vs-transient reconciliation above.

## Exit criteria

- Under a sustained generation load (e.g. a tight `/v1` loop), a parallel
  web-UI page load and `/status` poll return in **< 50 ms** (today: stalls
  for the full completion in non-streaming, inter-token in streaming).
- Killing the inference process mid-generation leaves the UI server up; a
  fresh page load and `/status` still succeed, and the in-flight request
  returns a clean error rather than a hang.
- No throughput regression vs the in-process path on the single-stream
  decode benchmark (token IPC overhead is below noise).

## Open questions

- Bun `ipc` channel vs unix socket vs `SharedArrayBuffer` ring for the
  token stream — measure latency/overhead before committing.
- One inference worker only (single GPU, single model) — confirmed by the
  single-user model. Multiple models = future, and pairs with hot-swap.
- Lease reconciliation strategy (a) drain-and-yield vs (b) worker runs
  jobs — decide in Phase 3.
- Where does prompt-cache live — in the worker (it holds KV bytes, must be
  byte-capped per CLAUDE.md). Almost certainly the worker.
- Startup UX: parent up and serving the UI immediately; worker model load
  happens behind a "loading…" state the parent reports.
