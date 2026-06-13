# Server API

`mlx-bun serve` (or `bun scripts/serve.ts`) exposes an OpenAI-compatible
HTTP API on one model. The request's `model` field is ignored; the
loaded model's id is echoed back. Generation is serialized through a
single queue (one GPU, batch = 1).

Start flags: `--port 8090`, `--adapter id=dir` (repeatable),
`--no-kv-quant` | `--kv-bits N`, `--memory-budget GB`.

## POST /v1/chat/completions

Request body (OpenAI chat schema; unknown fields ignored):

```jsonc
{
  "messages": [ /* role: system | user | assistant | tool */ ],
  "stream": false,
  "max_tokens": 1024,            // or max_completion_tokens (wins)
  "temperature": 0.7,            // 0 = greedy
  "top_p": 0, "top_k": 0,        // 0 = off
  "seed": 1234,                  // omit for time-derived
  "repetition_penalty": 1.1,     // optional
  "stop": "\n\n",                // or ["###", "\n\n"] (spec: up to 4)
  "tools": [ /* OpenAI function tools */ ],
  "tool_choice": "auto",         // "none" disables tools
  "chat_template_kwargs": {      // forwarded to the chat template
    "enable_thinking": false     // MiniCPM5: <think> channel on/off
  },
  "adapter": "id"                // LoRA: "id", stacked "a+b", or "none"
}
```

Sampling defaults follow the model author's `generation_config.json`
when a field is omitted (optiq serve's gen_config behavior); explicit
request values always win. MiniCPM5 defaults to the no-think direct
answer mode unless `chat_template_kwargs.enable_thinking` is `true`.

`stop` sequences are matched on **decoded text**, not token ids, so a
sequence that spans token boundaries still fires. Generation halts at
the first match; the stop sequence itself is excluded from the content
and `finish_reason` is `"stop"`.

Message `content` is a string or an array of parts:
`{ "type": "text", "text": ... }` and
`{ "type": "image_url", "image_url": { "url": "data:image/png;base64,..." } }`
(http/https URLs also accepted; PNG, JPEG, HEIC, AVIF, WebP, TIFF, GIF,
BMP via native OS codecs; requires a model with the vision sidecar).

Non-streaming response:

```jsonc
{
  "id": "chatcmpl-…", "object": "chat.completion", "created": 1760000000,
  "model": "<loaded model id>",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "…",                      // "" when only tool calls
      "tool_calls": [{                     // present when the model called tools
        "id": "call_…", "type": "function",
        "function": { "name": "…", "arguments": "{…json…}" }
      }]
    },
    "finish_reason": "stop" | "length" | "tool_calls"
  }],
  "usage": {
    "prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0,
    "prompt_tokens_details": { "cached_tokens": 0 }   // prompt-cache reuse
  }
}
```

Streaming (`"stream": true`) is SSE: `data: <chunk>\n\n` per event,
terminated by `data: "[DONE]"`. Chunks are `chat.completion.chunk`
objects whose `choices[0].delta` carries `{role}`, then `{content}`
increments (multi-byte sequences are held back until decodable; text
that could begin a `stop` sequence is held back until disambiguated,
so no part of a stop sequence is ever streamed), then
for tool calls a final `{tool_calls: [{index, id, type, function}]}`
delta; the last chunk carries `finish_reason` and `usage`.

Tool round-trip: send the assistant message with its `tool_calls` back,
followed by `{ "role": "tool", "tool_call_id": …, "content": … }`
messages; multi-turn prompt prefixes reuse the KV prompt cache
automatically.

Tool-call parsing is per model family. Gemma 4 uses its native
`<|tool_call>`…`<tool_call|>` sentinel tokens. MiniCPM5 emits XML in
decoded text (`<function name="…"><param name="…">…`, CDATA-wrapped
values supported); content before the tool markup still streams live,
only the markup is withheld and converted to `tool_calls`. Argument
values are decoded against the tool's JSON schema (string-typed params
stay strings); markup that fails to parse falls back to plain content.

### Errors

All errors are `{ "error": { "message": …, ... } }`.

- `400` — malformed JSON, empty `messages`, unknown adapter id, vision
  request on a model without a sidecar, prompt build failures.
- `400` with `"type": "memory_admission"`, `"code":
  "context_over_budget"` — `prompt + max_tokens` exceeds the memory
  budget's max safe context (only when serving with `--memory-budget`;
  the GPU OOM this prevents would kill the process, so it is refused
  up front). Lower `max_tokens` or shorten the prompt; the ceiling is
  visible at `/stats`.

## POST /v1/messages (Anthropic Messages API)

Anthropic-protocol surface over the same engine — on by default, like
`optiq serve`. Point any Anthropic-SDK tool at the server
(`ANTHROPIC_BASE_URL=http://localhost:8090`, any `x-api-key`) — Claude
Code works as a client this way.

- `system` (string or text blocks), `messages` with string or
  content-block arrays; `tool_use` / `tool_result` blocks map to the
  native gemma tool-calling path (better than the optiq shim, which
  inlines them as text); `image` blocks (base64 or url source) hit the
  vision path on sidecar models.
- `tools` (`{name, description, input_schema}`) map to function tools;
  server-tool types (web_search, …) are dropped silently.
- `max_tokens`, `temperature`, `top_p`, `top_k`, `stop_sequences`,
  `stream` as in the Anthropic spec.
- Response: `{id: "msg_…", type: "message", content: [{type: "text"} |
  {type: "tool_use"}…], stop_reason, usage: {input_tokens,
  output_tokens, cache_read_input_tokens}}` —
  `cache_read_input_tokens` comes from the prompt cache.
- Streaming follows the Anthropic event grammar exactly:
  `message_start → content_block_start/delta/stop (text_delta,
  input_json_delta) → message_delta (stop_reason + usage) →
  message_stop`. Errors are `event: error` frames.
- Errors: `{type: "error", error: {type: "invalid_request_error" |
  "api_error", message}}`.

## POST /v1/responses (OpenAI Responses API)

Responses-protocol surface (Codex, Cursor, Continue, Cline, and the
OpenAI SDK speak this now). Oracle: optiq responses shim.

- `input` (string or item array: `message`, `function_call`,
  `function_call_output`), `instructions` (merged with any
  system/developer items into one leading system message),
  `max_output_tokens`, `temperature`, `top_p`, `top_k`, flat
  `tools`/`tool_choice` (built-in tool types dropped), `stream`.
- **`previous_response_id` resumption**: pass a prior response id
  instead of resending the conversation; the server splices the stored
  input + output back in (instructions carry forward when omitted).
  Store is per-process, 1 h TTL, 32 MiB byte-capped LRU — observable
  at `GET /stats` (`response_store`). Unknown/expired id → 404.
- Response: `{id: "resp_…", object: "response", status: "completed" |
  "incomplete", output: [{type: "message"|"function_call"…}], usage}`.
- Streaming event chain: `response.created → response.in_progress →
  response.output_item.added → response.content_part.added →
  response.output_text.delta… → response.output_text.done →
  response.content_part.done → response.output_item.done →
  response.completed` (+ `response.function_call_arguments.delta/.done`
  for tool calls).

## GET /v1/models

`{ "object": "list", "data": [{ "id": "<model id>", "object": "model", … }] }`

## GET /stats

```jsonc
{
  "prompt_cache": { "entries": 0, "bytes": 0, "max_bytes": 0, "hits": 0, "misses": 0 },
  "response_store": { "entries": 0, "bytes": 0, "max_bytes": 33554432, "ttl_ms": 3600000 },
  "kv_quant": { "mode": "mixed (kv_config.json)" | "uniform-kv8" | "bf16",
                 "layers": { "kv4": 8, "bf16": 40 } },
  "admission": {
    "max_safe_context": 0,            // tokens; requests above this 400
    "memory_budget_bytes": null,      // explicit budget, or null (machine default)
    "usable_bytes": 0,
    "weights_bytes": 0
  }
}
```

## Adapters (LoRA hot-swap)

- `GET /v1/adapters` — `{ adapters: [{ id, path, rank, scale, size_bytes, mounted_layers }] }`
- `POST /v1/adapters` — `{ "id": "...", "path": "/dir" }`; mounts
  through the generation queue (never races a forward pass). 400 on
  shape/compat mismatch — validation is all-or-nothing.
- `DELETE /v1/adapters/<id>` — unmount; 404 if not mounted.

Select per request with the `adapter` body field. Prompt-cache entries
are namespaced per adapter spec, so switching adapters never reuses
another adapter's KV.

## Client setup: pi

`~/.pi/agent/models.json`:

```jsonc
{
  "providers": {
    "mlx-bun": {
      "baseUrl": "http://localhost:8090/v1",
      "api": "openai-completions",
      "apiKey": "sk-anything-nonempty",
      "models": [{ "id": "<model id from /v1/models>" }]
    }
  }
}
```

Any OpenAI SDK works the same way: `baseURL: "http://localhost:8090/v1"`,
any non-empty `apiKey`.
