# serve crash: MLX C++ exception on one recorded agent turn

**Status:** reproduced 5/5 during the K3 live A/B (2026-09-02), not yet isolated.

**Signature.** `bun src/cli.ts serve --model mjriii/Qwen3.8-27B --batch 1`
(also on the default batch lane) dies with `panic: A C++ exception occurred`
(Bun 1.4.0, mlx 0.31.2) on the request in `request.json`; no MLX error line
precedes it (`runs/k3/serve-*.log`). Every other turn of the six-session
corpus serves fine before it, so it is the request, not accumulated state:
the crash reproduced as the FIRST request after a fresh start too (see below).

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
