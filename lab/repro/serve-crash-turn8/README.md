# serve crash: MLX C++ exception on one recorded agent turn

**Status:** Native OOM confirmed; recorded regressions pass with the memory fix
on 2026-09-04. The resumed Pi run reached a final response at
2026-09-05 02:50:23 UTC, with `stopReason: stop` and an unparsed edit tool call
in its text. It did not establish completion of the Kanban task. The transcript
and `runs/qwen38-pi-resumed.log` agree on this outcome.
The same earlier session replay with
`--prompt-cache 0` served all four turns, while the default cache died on
turn 8 in 6/6 runs. Avoiding repeated RAM-cache cloning mitigated that
reproduction, but did not establish the underlying native cause. An exact Qwen
hybrid hit now transfers that entry to the request; the request puts its
extended state back after generation. Ordinary trimmable KV entries still use
non-consuming zero-copy clones.

**Later failure.** The Pi Kanban run still crashed after two successful file
writes at 2026-09-05 00:06:18 UTC, about 50 minutes after server startup.
Interposing `__cxa_throw` during a replay of the recorded Pi messages exposed
`[METAL] Command buffer execution failed: Insufficient Memory
(00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)`. The throw originates
in `mlx::core::gpu::check_error` from a Metal completion callback, outside
the mlx-c call site's exception handler. Two instrumented processes failed;
the fresh-process replay failed after 125 seconds. Bun's 12.37 GB peak RSS
underreported the OS-sampled 17.8 GiB peak physical footprint on the M4 Pro
24 GiB. The old response-boundary logs lack this native detail, so attributing
every historical crash to the same cause remains an inference.

**Memory fix and verification.** Packed prefill now evaluates each projection
and Qwen layer cache outputs instead of retaining their lazy temporary
buffers across the full chunk. Before serial generation, outstanding SSD
snapshots finish and release their clones. A live-memory guard reserves
prefill workspace plus prompt KV growth/overlap, rechecks between Qwen
prefill layers and every 256 decode tokens, and synchronously demotes older
LRU cache entries to SSD when required. The RAM cap remains 8 GiB; SSD
storage remains unlimited. The request keeps its chosen reusable cache.

On the M4 Pro 24 GiB with the packed k300 artifact, all seven recorded Pi
tool-result boundaries passed. The final request used 12,953 cached tokens
of 14,465 input tokens; five old entries demoted without failed writes.
A second sequence with a new diagnostic system prefix forced cold prefills
and then reused growing prefixes; all seven boundaries passed, with 512
output tokens on the final request and 12,970 of 14,482 input tokens reused.
Thus 14 boundary requests passed, including the previously failing cases.
These diagnostics did not execute the returned tools or edit the app.

Targeted tests: 107 pass across packed kernels, cache ownership/pressure,
gateway ordering, SSE heartbeat, and SSD persistence; all four docs-surface
checks pass. Separate existing failures remain: the model-free Qwen delta
golden differs by 1.9073486328125e-6, typecheck fails in the unrelated
`scripts/experiments/gpqa-bun.ts`, and hygiene flags existing root benchmark
artifacts. The docs map was regenerated. No golden tolerance was relaxed.

**Integration with merged main (`673b43f`).** The serial memory guard now
lives in `src/backends/mlx/serial-executor.ts`, entered after acquiring the
request's cache. Its scope restores the previous Qwen hook on completion or
failure. The new model-owned serving binding receives the admission budget;
the HTTP layer no longer dispatches on the concrete Qwen class. Projection
and cache-output evaluation bounds remain, as do SSD flush-before-serial and
per-tensor gateway leases. Focused integration tests pass (112); the complete
model-free run has 1,754 passes, 10 skips and the same delta-golden failure.
The exact assertion remains. Typechecking is now clean after fixing the GPQA
answer-index type; legacy benchmark outputs were moved under ignored reports.
The recorded 14 replay passes predate this merge and must be repeated before
claiming native validation of the integrated path.

**Current merged replay.** The seven saved tool-result boundaries through
`54f04b81` now pass on `673b43f` plus the local performance and durability diff,
using the packed k300 artifact and variant 12 on M4 Pro 24 GiB. Separate
`--batch 1` and `--batch 8` processes each complete all seven requests. Their
responses agree, including 512 generated tokens after a 14,465-token prompt
with 12,953 tokens reused. Each arm demotes seven older entries and finishes
with 14 durable SSD entries, no pending/missing snapshots and no failed writes.
Source hashes remain fixed; both bounded servers exit cleanly. The requests
reuse the saved messages and tool schemas. Their system prompt was rebuilt
once from the installed Pi package and frozen, so historical byte identity
is not claimed. No tools execute. Evidence: `agent-boundary-fixture.json`,
`agent-boundary-current.json` and `agent-boundary-current-review.json` under
`reports/qwen38-rd/`. This closes the recorded merged-path replay check;
other workloads and future graph changes retain their own memory gates.

The later model-free checkpoint passes after a pinned-oracle replay resolved
the stale DeltaNet fixture on unchanged inputs; the exact assertion remains.
A separate performance control now reproduces the same Metal OOM with the
affine flagship, 4,096 prompt IDs and a second fresh-cache native request.
The pinned Python worker also fails once its normal wired scope is enabled.
These controls do not use the server prompt cache. Allocator/residency
experiments and their source pins are under `reports/qwen38-rd/`; this new
finding does not invalidate the earlier cache ownership fix or establish
that every historical failure has one cause.

**Earlier live evaluation.** The original Pi session was continued through
`session.agent.continue()` after removing only trailing failed assistant
attempts from its in-memory context. No new user prompt is appended and
the saved transcript is not truncated. Operational files are under `runs/`:
`resume-pi-kanban.ts`, `qwen38-pi-resumed.log`, `qwen38-server-fixed.log`, and
`qwen38-memory.jsonl`. Server, Pi, and five-second memory monitoring run in
separate detached tmux sessions. The monitor records OS physical footprint,
RSS, periodic VM/pressure counters, and both cache tiers. An early diagnostic
sampler had an undersized native buffer; it was corrected before the live
evaluation. Its crash did not affect the inference server.

**In-process reduction (2026-09-04).** Reproduced without HTTP on the M1 Max
32 GB, Bun 1.4.0, using the locally staged published `mjriii/Qwen3.8-27B`.
This artifact is **not Josh's current target quant**; applicability to his
current artifacts remains unverified. Load the existing request fixture, render
message prefixes of lengths 1, 3, 5, 8 through `createRequestPrep`, and use the
server's stable-boundary snapshot / `PromptCache.take` / `generate` / `put`
sequence. Prompt lengths are 404, 4,158, 6,139, 11,958; reused prefixes are
0, 403, 4,157, 6,138. The fourth request aborts with the same bare C++ exception.
Reducing **every request to one generated token still reproduces it**; long
decode runs and HTTP streaming are unnecessary. FFI call tracing reaches
`mlx_eval` while evaluating the continuation prefill. A temporary native terminate handler recovered the exception from the Metal
completion thread: `[METAL] Command buffer execution failed: Insufficient Memory
(00000008:kIOGPUCommandBufferCallbackErrorOutOfMemory)`. The backtrace reaches
`mlx::core::gpu::check_error(MTL::CommandBuffer*)` from its completion handler.
This establishes device allocation failure; it does not establish cache-state
corruption. Josh reports a possible fix on the other machine; it was not present
on fetched `origin/main` at `6d45ca1`. Reconcile that fix before further changes.
The short aligned-prefix borrow test passes on this artifact; that does not
cover this long continuation. Temporary investigation scripts were removed.

**Signature.** `bun src/cli.ts serve --model mjriii/Qwen3.8-27B --batch 1`
(also on the default batch lane) dies with `panic: A C++ exception occurred`
(Bun 1.4.0, mlx 0.31.2) on the request in `request.json`; no MLX error line
precedes it (`runs/k3/serve-*.log`). Every other turn of the six-session
corpus serves fine before it. **Not a pure function of the request**: sent
alone to a fresh server (non-streaming, and each of the variants below) it
returns 200 and the server survives — so the trigger is streaming and/or the
server state left by the preceding turns (prompt cache, KV) — see Bisection.

**Request shape.** 8 messages, 34,670 chars, roles
`user, assistant, tool, assistant, tool, assistant, tool, tool` — the last
assistant turn made TWO tool calls (parallel), followed by two `tool`
results; two tools (`bash`, `read`) in `tools`; `max_tokens` 512.

**Repro.**
```
bun src/cli.ts serve --model mjriii/Qwen3.8-27B --port 8080 --batch 1 &
curl -s http://127.0.0.1:8080/v1/chat/completions -H 'content-type: application/json' \
  -d @lab/repro/serve-crash-turn8/request.json
```

**Bisection (fresh server each, `--batch 1`, non-streaming curl).**
`request.json` 200 · drop last tool msg 200 · first 4 msgs 200 · tool results
truncated 200 · no tools 200. Variants kept next to this file.

**Stateful.** Streaming the same request alone: 200, server alive. Replaying
ONLY this session in order (`bun scripts/fill.ts replay --sessions <dir with
this one session> --max-turns 12`, turns 1, 5, 7 then 8) on a fresh server:
turn 8 kills it (`Abort trap: 6`, the same bare C++ exception) — 100%
reproducible with three prior turns of the same session. The prior turns share
a prompt prefix with turn 8, which is what the prompt cache reuses; the
`--prompt-cache 0` run below decides whether that is the path.

**Decisive run.** `--prompt-cache 0`, same session, same order: 0 errors, turn 8
serves 457 tokens, server alive. The fault was in the prompt-cache take and
continuation path on the qwen3_5 hybrid graph (gated-delta SSM state + KV) when
turn 8 resumed from a prefix cached by turns 1/3/5.

**Minimized weighted replay.** The recorded request prefixes at 1, 3, 5, and
8 messages produce prompt lengths 404, 4,158, 6,139, and 11,958 tokens. Their
cache hits cover 0, 403, 4,157, and 6,138 tokens. With one output token per
request, the old code crashes on the fourth request after 66.7 seconds. This
also rules out a two-hour supervisor timeout. A fresh `--prompt-cache 0`
control serves the final request.

**Fix verification.** Three fresh server processes served the minimized
four-request sequence and remained alive. A fourth fresh process replayed the
same prefixes and then ran the original final request with `max_tokens: 512`;
it returned 391 tokens with `finish_reason: tool_calls`, and the server stayed
alive. The implementation test covers ownership transfer and confirms that
the donor is neither cloned nor disposed.
