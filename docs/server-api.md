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
  "tools": [ /* OpenAI function tools */ ],
  "tool_choice": "auto",         // "none" disables tools
  "adapter": "id"                // LoRA: "id", stacked "a+b", or "none"
}
```

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
increments (multi-byte sequences are held back until decodable), then
for tool calls a final `{tool_calls: [{index, id, type, function}]}`
delta; the last chunk carries `finish_reason` and `usage`.

Tool round-trip: send the assistant message with its `tool_calls` back,
followed by `{ "role": "tool", "tool_call_id": …, "content": … }`
messages; multi-turn prompt prefixes reuse the KV prompt cache
automatically.

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

## GET /v1/models

`{ "object": "list", "data": [{ "id": "<model id>", "object": "model", … }] }`

## GET /stats

```jsonc
{
  "prompt_cache": { "entries": 0, "bytes": 0, "max_bytes": 0, "hits": 0, "misses": 0 },
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
