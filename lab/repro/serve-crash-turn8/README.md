# serve crash: MLX C++ exception on one recorded agent turn

**Status:** ISOLATED to prompt-cache prefix reuse (2026-09-02): same session replay with `--prompt-cache 0` serves all four turns (turn 8: 457 tokens); with the default cache it dies on turn 8, 6/6 runs. Root cause in the engine not yet found.

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
`mlx_eval` while evaluating the continuation prefill. Native debugger attachment
was denied by macOS, so no native exception message/backtrace was recovered.
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
serves 457 tokens, server alive. ⇒ the fault is in the prompt-cache TAKE /
continuation path on the qwen3_5 hybrid graph (gated-delta SSM state + KV) when
turn 8 resumes from a prefix cached by turns 1/3/5 — a multi-tool-result tail
grafted onto a cached prefix. Next: reproduce in-process (`generate()` with a
`PromptCache` seeded by the earlier turns), then bisect prefix length; check
the SSM-state restore for a cached prefix ending inside the tool-result span.
