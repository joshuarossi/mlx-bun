# Server API

`mlx-bun serve` exposes an OpenAI-compatible
HTTP API on one model. The request's `model` field is ignored; the
loaded model's id is echoed back. By default generation is serialized
through a single queue (one GPU, batch = 1); `--batch N` switches the
server into bf16 continuous batching.

For the full set of start flags (`--port`, `--memory-budget`,
`--prompt-cache`, `--batch`, `--kv-quant`, `--thinking`, sampling
defaults, and the perf levers) and a compatibility matrix of which
combinations compose, see [server-config.md](./server-config.md). This
doc covers the request/response wire format. LoRA adapters are mounted at
runtime via `POST /v1/adapters` (below), or at startup with
`serve --adapter <dir>` (which also makes that adapter the default for
requests that don't select one).

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
  "min_p": 0.05,                 // min-p sampling (0 = off)
  "xtc_probability": 0.5,        // XTC sampling: chance per step of dropping
  "xtc_threshold": 0.1,          //   every token above threshold except the
                                 //   least likely (EOS + newline exempt,
                                 //   matching mlx_lm.server)
  "logit_bias": { "42": -5.0 },  // additive per-token-id logit bias
  "repetition_penalty": 1.1,     // optional
  "repetition_context_size": 20, // recent-token window (0 = whole history)
  "presence_penalty": 0.0,       // subtracted once if the token occurred
  "presence_context_size": 20,   //   in the window (mlx-lm extension)
  "frequency_penalty": 0.0,      // subtracted per occurrence in the window
  "frequency_context_size": 20,  //   (mlx-lm extension)
  "logprobs": false,             // BOOL (mlx_lm.server's type, even on
                                 //   /v1/completions): return each emitted
                                 //   token's logprob
  "top_logprobs": -1,            // int in [0, 11] or -1 = unset (mlx-lm's
                                 //   validation — its cap is 11, not
                                 //   OpenAI's 20); k > 0 returns the top-k
                                 //   (token, logprob) pairs per position
  "stop": "\n\n",                // or ["###", "\n\n"] (spec: up to 4)
  "tools": [ /* OpenAI function tools */ ],
  "tool_choice": "auto",         // "none" disables tools
  "chat_template_kwargs": {      // forwarded to the chat template
    "enable_thinking": false     // MiniCPM5 / Qwen3.5: <think> channel on/off
  },
  "reasoning_effort": "medium",  // "none"|"minimal"|"low"|"medium"|"high"
                                 // gates enable_thinking on Qwen3.5/MiniCPM5:
                                 // "none" → off, any other level → on. Only
                                 // consulted when chat_template_kwargs
                                 // .enable_thinking is not explicitly set —
                                 // an explicit enable_thinking always wins.
  "hlg": {                       // HLG tone-curve sampling (per request).
    "enabled": true,             // merged over --hlg-sampling server defaults.
    "width": 4,                  // logit-width of the tone plateau
    "shoulder": 4,               // top shoulder width
    "toe": 6,                    // bottom toe width
    "pivot_offset": 6            // pivot point offset from top
  },
  "response_format":             // structured output (grammar-constrained
    { "type": "json_object" },   //   decoding) — also guided_grammar,
                                 //   guided_regex, guided_choice,
                                 //   structured_outputs; see "Structured
                                 //   output" below
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

Remote (http/https) media URLs — image and audio alike — go through a
destination policy: **private/loopback/link-local hosts are refused by
default** (the request URL is attacker-controlled input — SSRF), every
redirect hop is re-validated, and the fetch has a **10 s timeout** and a
**64 MB response cap**. Violations are clean `400`s
(`prompt build failed: image url rejected: …`). Serving media from a LAN
host (a NAS, another machine) is the opt-in
[`--allow-private-media`](server-config.md#start-flags) flag. `data:`
URLs are decoded locally and never policy-checked.

### Audio input

Audio rides the same content-part array (OpenAI-canonical shape plus two
aliases):

```jsonc
{ "type": "input_audio", "input_audio": { "data": "<base64>", "format": "wav" } }
{ "type": "audio",       "data": "<base64>" }                        // alias
{ "type": "audio_url",   "audio_url": { "url": "data:…|http(s)://…" } } // alias
```

(`audio_url` http/https fetches follow the same destination policy,
timeout, and size cap as `image_url` — see above.)

```bash
curl -s http://localhost:8080/v1/chat/completions \
  -H 'content-type: application/json' \
  -d "$(jq -n --arg b64 "$(base64 -i clip.wav)" '{
    messages: [{ role: "user", content: [
      { type: "input_audio", input_audio: { data: $b64, format: "wav" } },
      { type: "text", text: "Transcribe this audio." }
    ]}],
    max_tokens: 64, temperature: 0
  }')"
```

- **Models**: any model whose `config.json` carries an `audio_config`
  AND whose `optiq_vision.safetensors` sidecar ships the audio-tower
  tensors — gemma-4 **e4b** today. Auto-detected, no flags (mirrors
  vision). A request WITH audio on any other model gets an explicit
  `400` naming the model — never a silent text-only answer.
- **Formats**: WAV is decoded natively (PCM 16/24/32-bit + float32, any
  channel count / sample rate). mp3, m4a/AAC, FLAC, ogg(-CAF), AIFF and
  anything else CoreAudio reads transcode via macOS `afconvert`;
  undecodable bytes are a `400` (`audio transcode failed …`).
- **Internal format**: 16 kHz mono — multi-channel input is mean-mixed,
  other rates resample. Clips truncate at **30 s** (the oracle
  processor's 480 000-sample cap); one clip costs
  `ceil(duration_ms / 40)` prompt tokens, at most **750**.
- Multiple clips per message and **mixed image+audio** requests work;
  media splices in document order.
- **Routing**: audio requests always run on the **serial lane** (never
  batched, even under `--batch N`) and skip the prompt cache — soft
  tokens are identical placeholder ids, so prefix matching across
  different clips would false-hit.
- The Anthropic surface (`/v1/messages`) has no audio block type in its
  protocol; audio blocks there are a `400` pointing back to this
  endpoint.

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
    "prompt_tokens_details": { "cached_tokens": 0 },  // prompt-cache reuse
    "lane": "serial",              // "serial" | "serial+spec" | "batched" —
                                    //   which execution lane served THIS
                                    //   request (GenerationGateway.willBatch
                                    //   + whether a draft actually contributed
                                    //   accepted tokens). Chat completions
                                    //   only (streaming: final usage chunk).
    "speculation": {               // only when a draft source is mounted
      "drafted": 0,                //   draft tokens proposed
      "accepted": 0,               //   drafts accepted by the verify step
      "targetCalls": 0             //   target-model forward calls
    }
  }
}
```

`usage.lane` is server-driven, never client-inferred (the web chat's perf-strip
lane badge reads it, not a heuristic): `"batched"` when `--batch N` picked up
the request, `"serial+spec"` when a mounted draft source actually
contributed accepted draft tokens to this reply, `"serial"` otherwise. It
rides the SAME usage block on both streaming (final chunk before `[DONE]`) and
non-streaming responses.

Speculative decoding is a **server-level mode** (`serve --draft-model`,
or the model-free `serve --draft-kind ngram`, which mounts no draft
model); there is no per-request draft field. The `speculation` usage
extension
appears on chat and text completions alike, non-streaming and on the
final stream chunk. Spec-eligible requests are text-only on base weights
(no adapter, no logprobs capture, bf16 KV); ineligible ones decode
normally and omit the field. The spec path bypasses the prompt cache
(`cached_tokens` 0), and while a draft is mounted every request routes
through the serial lane (mlx_lm.server parity: `is_batchable = draft is
None`) — speculation and `--batch N` are different modes.

### logprobs / top_logprobs

With `"logprobs": true` and/or `"top_logprobs": k` (1–11), the
non-streaming response's `choices[0].logprobs` carries
**`mlx_lm.server`'s block, not OpenAI's** (server.py
`generate_response`): entries are keyed by token *id*, token strings
are the raw vocab pieces (`convert_ids_to_tokens` — e.g. `"▁Hello"`),
and there is no `bytes` field. The same block appears on
`/v1/completions` (mlx-lm shares the response builder; there is no
legacy `{tokens, token_logprobs}` text-completion shape).

```jsonc
// top_logprobs: k > 0 (wins over logprobs when both are set — mlx-lm's if/elif)
"logprobs": { "content": [
  { "id": 9906, "token": "▁Hello", "logprob": -0.02,   // = top-1, merged from
    "top_logprobs": [                                   //   dict(top[0], top_logprobs=top)
      { "id": 9906, "token": "▁Hello", "logprob": -0.02 },
      { "id": 13347, "token": "▁Hi", "logprob": -4.1 }   // … k entries, sorted desc
    ] },
  // … one entry per generated token (reasoning/tool tokens included)
] }

// logprobs: true only
"logprobs": { "content": [ { "id": 9906, "logprob": -0.02 }, … ] }
```

The distribution matches mlx-lm `generate_step` exactly: full-vocab
log-softmax of the logits **after** logits processors (logit_bias,
penalties), **before** the sampler's temperature/top-p/top-k/min-p/XTC
(mlx_lm/generate.py L409–422). mlx-lm's top-k order is unspecified
(argpartition); ours is sorted descending — the same set, so the entry
is deterministically the argmax. Stream chunks never carry logprobs
(mlx-lm's streaming responses don't either). Requests with logprobs
run on the serial lane under `--batch N` (like the other mlx-lm
sampler extensions). Invalid values are rejected with mlx-lm's exact
messages (see Errors).

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
`<|tool_call>`…`<tool_call|>` sentinel tokens. Qwen3.5 emits decoded
text wrapped in `<tool_call><function=name><parameter=key>value` XML
equals-style blocks. MiniCPM5 emits XML in decoded text
(`<function name="…"><param name="…">…`, CDATA-wrapped values
supported). For both Qwen3.5 and MiniCPM5 content before the tool
markup still streams live, only the markup is withheld and converted to
`tool_calls`. Argument values are decoded against the tool's JSON schema
(string-typed params stay strings); markup that fails to parse falls
back to plain content.

### Structured output (grammar-constrained decoding)

Both `/v1/chat/completions` and `/v1/completions` accept the
OpenAI/oMLX/vLLM structured-output fields (snake_case on the wire):

```jsonc
{
  "response_format":              // OpenAI: {type:"json_object"} = any valid
    { "type": "json_schema",      //   JSON; {type:"json_schema"} constrains
      "json_schema": {            //   to the schema; {type:"text"} = no-op
        "name": "…", "schema": { /* JSON schema */ }, "strict": true,
        "any_whitespace": true } },  // false = compact separators (no
                                  //   whitespace freedom in the grammar —
                                  //   escape hatch for base models that
                                  //   greedily emit whitespace to max_tokens)
  "guided_grammar": "root ::= …", // raw EBNF grammar string (vLLM/oMLX)
  "guided_regex": "[A-Z][a-z]*",  // regex — the regex∩EBNF subset ONLY
                                  //   (classes, |, *, +, ?, parens);
                                  //   regex-only syntax (\d, ., anchors)
                                  //   hits the degrade path — a known gap
  "guided_choice": ["yes", "no"], // output is exactly one of these strings
  "structured_outputs": { /* … */ } // bare JSON schema (oMLX/vLLM alias)
}
```

Precedence when several are set mirrors oMLX: `guided_grammar` >
`response_format` json_schema > json_object > `structured_outputs` >
`guided_regex` > `guided_choice`.

Enforcement is a per-step token bitmask at the sampler (xgrammar):
invalid next tokens are masked to −inf **after** the logits processors,
so valid-token numerics are untouched. Generation halts as soon as the
grammar is satisfied (e.g. the closing `}` of a complete JSON object)
with `finish_reason: "stop"`. Works on both lanes — serial and
`--batch N` (per-row matchers).

Degrade path — a grammar that fails to compile is never rejected (no
400/500): chat prepends a string-valued system instruction for the
requested JSON schema, raw grammar, regex, or choice constraint, and the
response carries a `Warning` header (`grammar not enforced: …`);
`/v1/completions` has no chat template to inject into, so it emits the
`Warning` header only.
`MLX_BUN_GRAMMAR=0` disables mask compilation but does not silently
ignore a requested constraint: it uses this same degrade path (chat
prompt injection plus `Warning`; raw completions `Warning` only).
Design and fidelity notes:
[structured-output.md](../design/structured-output.md).

### Errors

All errors are `{ "error": { "message": …, ... } }`.

- `400` — malformed JSON, empty `messages`, unknown adapter id, vision
  request on a model without a sidecar, audio request on a model
  without an audio tower (message names the model), audio transcode
  failures, prompt build failures,
  non-numeric `logit_bias` keys/values (`logit_bias must be a dict of
  int to float`, mlx-lm's coercion error), invalid logprobs params
  (mlx-lm's exact validation: `logprobs must be of type bool`,
  `top_logprobs must be of type int` / `at least 0` / `at most 11`;
  `top_logprobs: -1` is the accepted "unset" sentinel).
- `400` with `"type": "memory_admission"`, `"code":
  "context_over_budget"` — `prompt + max_tokens` exceeds the memory
  budget's max safe context (only when serving with `--memory-budget`;
  the GPU OOM this prevents would kill the process, so it is refused
  up front). Lower `max_tokens` or shorten the prompt; the ceiling is
  visible at `/stats`.

## POST /v1/completions (raw text completion)

`mlx_lm.server`'s text-completion endpoint: **no chat template** — the
`prompt` string is tokenized directly (the tokenizer's own BOS handling,
exactly mlx-lm's `tokenizer.encode(request.prompt)`) and the model
continues it. Same generation gateway, admission control, prompt cache,
and adapter selection as chat.

```jsonc
{
  "prompt": "Once upon a time",  // REQUIRED, string only (token arrays
                                 // rejected, matching mlx_lm.server)
  "max_tokens": 512,             // default 512 (mlx_lm.server's default) —
                                 // NOT the chat lane's generous default
  "stream": false,
  "stop": "\n\n",                // string or array, decoded-text matching
  // plus every sampling/penalty field from /v1/chat/completions:
  // temperature, top_p, top_k, seed, min_p, xtc_probability,
  // xtc_threshold, logit_bias, repetition_penalty,
  // repetition_context_size, presence_penalty, presence_context_size,
  // frequency_penalty, frequency_context_size, adapter,
  // logprobs (BOOL, mlx-lm's type — not OpenAI's legacy int),
  // top_logprobs (0-11 or -1) — same response block as chat, see
  // "logprobs / top_logprobs" above (mlx-lm shares the builder),
  // response_format / guided_grammar / guided_regex / guided_choice /
  // structured_outputs — structured output, same semantics and
  // precedence as chat (see "Structured output" above); the degrade
  // path here emits the Warning header only (no template to inject a
  // system prompt into)
}
```

Response is the OpenAI text-completion object:

```jsonc
{
  "id": "cmpl-…", "object": "text_completion", "created": 1760000000,
  "model": "<loaded model id>",
  "choices": [{ "index": 0, "text": "…", "finish_reason": "stop" | "length" }],
  "usage": { "prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0,
             "prompt_tokens_details": { "cached_tokens": 0 } }
             // + "speculation" under --draft-model, as on chat
}
```

Streaming (`"stream": true`) is SSE: `text_completion` chunks whose
`choices[0].text` carries the delta; the final chunk carries
`finish_reason` and `usage` (always attached — mlx-lm gates usage behind
`stream_options.include_usage`; ours is an additive superset), then
`data: [DONE]`. There is no `echo` parameter (mlx_lm.server has none).

## POST /v1/messages (Anthropic Messages API)

Anthropic-protocol surface over the same engine — on by default, like
`optiq serve`. Point any Anthropic-SDK tool at the server
(`ANTHROPIC_BASE_URL=http://localhost:8080`, any `x-api-key`) — Claude
Code works as a client this way.

- `system` (string or text blocks), `messages` with string or
  content-block arrays; `tool_use` / `tool_result` blocks map to the
  native gemma tool-calling path (better than the optiq shim, which
  inlines them as text); `image` blocks (base64 or url source) hit the
  vision path on sidecar models. The protocol has no audio input block;
  audio-shaped blocks (`input_audio` / `audio` / `audio_url`) are
  rejected with a `400` pointing to `/v1/chat/completions`.
- `tools` (`{name, description, input_schema}`) map to function tools;
  server-tool types (web_search, …) are dropped silently.
- `max_tokens`, `temperature`, `top_p`, `top_k`, `stop_sequences`,
  `stream` as in the Anthropic spec. The mlx-lm sampler/penalty
  extensions (`min_p`, `xtc_probability`, `xtc_threshold`,
  `repetition_penalty`, `presence_penalty`, `frequency_penalty` + their
  `*_context_size` windows) pass through as extras; `logit_bias` does
  not exist in this protocol and is not accepted here.
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
  `tools`/`tool_choice` (built-in tool types dropped), `stream`. The
  mlx-lm sampler/penalty extensions (`min_p`, `xtc_probability`,
  `xtc_threshold`, `logit_bias`, `repetition_penalty`,
  `presence_penalty`, `frequency_penalty` + `*_context_size`) pass
  through as extras.
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

## POST /v1/embeddings (OpenAI Embeddings API)

Text embeddings, available when the **served model is an embedding model**
(plain Qwen3 / Qwen3-Embedding) — consistent with the single-model server:
`mlx-bun serve mlx-community/Qwen3-Embedding-4B-4bit-DWQ`, then POST here. On
any other served model the route returns `400 invalid_request_error`.

- `input` (string or array of strings), `model` (ignored — the served model
  is used), and a **non-standard** `instruction` (optional): applies
  Qwen3-Embedding's query format `Instruct: {instruction}\nQuery:{text}`,
  which steers *which* similarity axis the geometry reflects. Omit it for
  plain document embeddings.
- Pooling is last-token + L2-normalization (the vectors are unit-length);
  similarity is the dot product. Bit-exact vs the mlx-lm `qwen3` reference
  (`tests/qwen3-embed-parity.test.ts`).
- Response: `{ "object": "list", "data": [{ "object": "embedding", "index":
  0, "embedding": [float…] }, …], "model": "<served id>", "usage": {
  "prompt_tokens": N, "total_tokens": N } }`. Embedding is a single forward
  (no decode loop), so it runs inline — not through the generation gateway.

```sh
curl localhost:8080/v1/embeddings -H 'content-type: application/json' \
  -d '{"input": ["the cat sat on the mat", "a kitten by the window"]}'
```

## GET /v1/models

`{ "object": "list", "data": [{ "id": "<model id>", "object": "model",
"created": <unix s>, … }] }`

The served model is FIRST, with extra capability fields:

```jsonc
{
  "id": "<served model id>", "object": "model", "created": 0,
  "owned_by": "mlx-bun",
  "context_window": 32768,
  "reasoning": false,           // switchable thinking channel (gates the
                                 //   web chat's thinking toggle)
  "vision": false,               // image input accepted (tower loaded or
                                 //   lazily loadable)
  "audio": false,                // input_audio content parts accepted
                                 //   (tower loaded or lazily loadable)
  "gen_defaults": {              // model-author sampling defaults
    "temperature": 0.7,          //   (generation_config.json, with any
    "top_p": 0.95,               //   --temperature/--top-p/--top-k server
    "top_k": 0                   //   override applied); null when neither
                                 //   the model nor the server set one
  }
}
```

Followed by every other servable model the local registry knows (mlx-lm
scans the HF cache here; the registry is that scan, filtered to supported
architectures, one row per repo via `listCanonical()` — duplicate snapshots
from upstream re-pushes are not separate entries):

```jsonc
{ "id": "<repo id>", "object": "model", "created": 0,
  "vision": false,               // visionCapable(): sidecar OR encoder-free
                                 //   unified vision config
  "tier": "targeted" | "generic" // supportTier(): dedicated/generated forward
                                 //   ("targeted") vs the Tier-0 universal
                                 //   module ("generic"); entries with no tier
                                 //   (unsupported) are filtered out entirely
}
```

`GET /v1/models/<id>` filters the list to that id — same list shape,
matching `mlx_lm.server`.

`vision` / `audio` say whether the served model accepts `image_url` /
`input_audio` content parts (tower loaded or lazily loadable — see
*Audio input* above for what audio requires), so clients can discover
capabilities instead of probing for a `400`.

## GET /health

`{"status": "ok"}` — byte-for-byte what `mlx_lm.server` returns.

## GET /stats

```jsonc
{
  "server": { "owner": "serve" | "pi-session" | "embedded", "model": "...", "started_at": 0 },
  "prompt_cache": { "entries": 0, "bytes": 0, "max_bytes": 0, "hits": 0, "misses": 0 },
  "response_store": { "entries": 0, "bytes": 0, "max_bytes": 33554432, "ttl_ms": 3600000 },
  "kv_quant": { "mode": "mixed (kv_config.json)" | "uniform-kv8" | "turbo k8v3" | "bf16",
                 "layers": { "kv4": 8, "bf16": 40 },     // turbo: { "turbo-k8v3": 8, "bf16": 40 }
                 "attention": { "global": 10, "sliding_window": 38 } },
  // present only when --ssd-cache is on:
  "ssd_cache": { "dir": "...", "entries": 0, "bytes": 0, "max_bytes": 0,
                 "restores": 0, "spills": 0, "restore_ms_last": 0, "demotions": 0,
                 // bounded write-behind queue (MLX_BUN_SSD_SPILL_QUEUE_GB):
                 "pending_spills": 0, "pending_spill_bytes": 0, "dropped_spills": 0 },
  "admission": {
    "max_safe_context": 0,            // tokens; requests above this 400
    "memory_budget_bytes": null,      // explicit budget, or null (machine default)
    "usable_bytes": 0,
    "weights_bytes": 0
  },
  "batch": {
    "configured": 1,                  // the --batch N value
    "batched": false,                 // batching enabled (N>1)
    "active_rows": 0,                 // rows currently decoding in the batch
    "pending_rows": 0,                // queued + mid-prefill rows waiting
    "submitted_rows": 0,              // cumulative rows routed to the batch lane since start
    "kv_bytes": 0,                    // projected aggregate KV bytes of admitted rows
    "kv_budget_bytes": null           // --kv-budget cap, or null (uncapped)
  }
}
```

## GET /library

Returns all models found in the local HuggingFace hub cache (via the
registry scan), each annotated with a fit assessment for this machine.
Response is cached for 30 seconds (registry scan + config reads; no
tensor bytes are read).

```jsonc
{
  "models": [{
    "repo_id": "…",
    "model_type": "gemma3" | "minicpm5" | "qwen3" | …,
    "size_bytes": 0,
    "quant_bits": 4,
    "vision": false,             // visionCapable(): sidecar OR encoder-free
                                 //   unified vision config (not sidecar-only)
    "audio": false,              // audio-capable (audio_config + sidecar audio-tower tensors)
    "supported": true,           // supportTier() !== null (recognized family)
    "support_tier": "targeted" | "generic" | null,  // dedicated/generated
                                 //   forward vs the Tier-0 universal module;
                                 //   null only when supported is false
    "serving": false,            // currently loaded in this server
    "assessment": {              // null if config unreadable
      "fits": true,
      "max_safe_context": 8192,
      "predicted_decode_tps": 0.0
    }
  }]
}
```

One row per repo (`listCanonical()`; duplicate snapshots from upstream
re-pushes surface only via the CLI's `mlx-bun ls --all-revisions`).

## GET /api/gc/plan · POST /api/gc/execute

Reclaim disk from superseded snapshots + orphaned blobs in the local HF
cache — the web-UI equivalent of `mlx-bun gc` (thin wrappers over
`src/registry.ts`'s `planGc`/`executeGc`; same planner the CLI uses). Every
downloaded revision the HF cache keeps a `snapshots/<commit>` dir for; a
snapshot no `refs/*` points at is superseded and, once no surviving snapshot
symlinks to a blob, that blob is dead too. Loopback-served admin routes, no
separate auth (same bind as every other `/api/*` route).

`GET /api/gc/plan` — read-only (config.json + safetensors index reads only,
no tensor bytes, no deletion):

```jsonc
{
  "ok": true,
  "superseded": [{
    "repo_id": "…",
    "prune_snapshots": 1,        // unreferenced, safe to delete
    "skipped_snapshots": 0,      // unreferenced but hold files the kept
                                 //   revision lacks — needs --force via the
                                 //   CLI to actually prune; not deletable here
    "dead_blobs": 3,
    "reclaim_bytes": 0
  }],
  "reclaim_bytes": 0             // sum across every repo
}
```

`POST /api/gc/execute` with body `{"yes": true}` — deletes exactly what a
fresh plan would show (recomputed at execute time, not the caller's stale
plan); `{"yes": true}` is required or the request 400s, mirroring the CLI's
`--yes` gate so a stray call can't delete anything by accident:

```jsonc
{ "ok": true, "snapshots": 1, "blobs": 3, "reclaimed_bytes": 0 }
```

Errors follow the same `{ "ok": false, "error": "…" }` shape as the other
`/api/*` job routes.

## GET /api/memory/\* · POST /api/memory/init

Thin loopback JSON wrappers over `src/memory/vault.ts` for the web chat's
Memory panel (docs/design/web-chat-redesign.md §5.5) — same loopback-only
admin-route posture as `/api/gc/*`, no separate auth. Handlers live in
`src/memory/rest.ts`; they never touch the agent-tool surface
(`src/memory/tools.ts`), which stays read-only and unchanged. Every route
below degrades gracefully — a missing vault, an unknown article, or a bad
param returns `{ "ok": false, ... }` (with an appropriate HTTP status), never
a 500 or an unhandled throw.

When no vault exists yet, every `GET` route (except `/init`) returns:

```jsonc
{ "ok": false, "enabled": false, "error": "no memory vault yet", "root": "…" }
```

`GET /api/memory/status` — `vaultStatus()` as JSON:

```jsonc
{ "ok": true, "enabled": true, "status": { "root": "…", "exists": true, "articleCount": 12, "referenceCount": 9, "isGitRepo": true, "recentArticles": [{ "article": "…", "mtimeMs": 0 }] } }
```

`GET /api/memory/list` — article stems plus `Reference/*` doc ids, kept
separate (mirrors `memory_list`):

```jsonc
{ "ok": true, "articles": ["Alpha", "Beta"], "reference": ["Reference/mlx-bun_README"] }
```

`GET /api/memory/search?q=<query>&scope=all|articles|reference&limit=50` —
wraps `searchArticles`; same summaries/hits shape the `memory_search` tool
formats from:

```jsonc
{ "ok": true, "summaries": [{ "article": "…", "occurrences": 3, "matched_terms": ["…"] }], "hits": [{ "article": "…", "anchor": "…", "line": 10, "excerpt": "…" }] }
```

`GET /api/memory/article?name=<article>` — rendered source plus the
deterministic metadata the panel needs to render it (infobox, lead, series
banner, section skeleton) without re-parsing client-side; 404s
`{ "ok": false }` for an unknown name:

```jsonc
{ "ok": true, "name": "…", "path": "…", "content": "# …", "infobox": { "type": "…", "entityKind": "thing", "fields": [] }, "lead": "…", "series": null, "structure": [] }
```

`GET /api/memory/links?name=<article>` — inbound/outbound wikilinks (same
data `memory_links` resolves); articles only, not `Reference/*` (matching
the tool's own scope):

```jsonc
{ "ok": true, "name": "…", "outbound": ["…"], "inbound": ["…"] }
```

`GET /api/memory/history?name=<article>&limit=50` — the article's git log
(read-only `git log` plumbing on the vault's own repo, via `Bun.spawn` —
never a shell string):

```jsonc
{ "ok": true, "name": "…", "isGitRepo": true, "entries": [{ "hash": "…", "date": "YYYY-MM-DD", "subject": "…" }] }
```

`GET /api/memory/diff?name=<article>&rev=<hash>` — that commit's diff for
the article (`git show <rev> -- <path>`). `rev` must match
`/^[0-9a-f]{4,40}$/` (a bare commit hash — never a ref expression like
`HEAD~1` or `main^`) or the request 400s before touching git; `name` is
resolved through the same existence-checked normalization `readArticle`
uses, so a path-traversal or otherwise-invalid name 404s rather than
reaching the `git` argv:

```jsonc
{ "ok": true, "name": "…", "rev": "…", "diff": "diff --git a/articles/…" }
```

`POST /api/memory/init` with optional body `{"path"?: string}` — the
first-run consent-card backend. Delegates to the exact same `setupVault()`
the CLI's `mlx-bun memory init` calls (idempotent: create dirs, write
README + Meta pages only if missing, git init + initial commit); omits only
the CLI's interactive extras (seed-from-existing-vault prompt, nightly
schedule prompt), which stay TTY-only. `path`, if given, must resolve under
the default vault root or the OS temp directory — `setupVault()` mkdir's
into it and `git init`s it if it isn't already a repo, so anything outside
those trees 400s before touching the filesystem rather than letting a
caller redirect vault setup at an arbitrary directory:

```jsonc
{ "ok": true, "result": { "root": "…", "created": ["…"], "gitInitialized": true, "alreadySetUp": false }, "status": { "root": "…", "exists": true, "articleCount": 0, "referenceCount": 9, "isGitRepo": true, "recentArticles": [] } }
```

## GET /api/settings/tool-approvals · DELETE /api/settings/tool-approvals

The web chat's durable "always allow this tool" list for gated tools
(`bash`/`edit`/`write`) — docs/design/web-chat-redesign.md §5.4/§6.5/§9
Phase 2, risk #6. Backed by `~/.mlx-bun/tool-approvals.json`
(`src/tool-approvals.ts`), a versioned `{version, allows}` file (same
plain-JSON-at-0600 convention as `~/.mlx-bun/hf.json`) keyed by stable tool
NAME, not per-call arguments — "always allow bash" means every future
`bash` call skips the browser's approval card, on every chat and every
browser tab, until forgotten. These two routes are read/forget only:
granting an always-allow happens through the approval card itself (the
`approval` WS frame on `/ws/chat`, `alwaysAllow: true`), never a bare
settings-form POST.

`GET /api/settings/tool-approvals`:

```jsonc
{ "ok": true, "alwaysAllow": ["bash", "edit"] }
```

`DELETE /api/settings/tool-approvals` with body `{"tool": "bash"}` —
revokes one tool's always-allow (idempotent; forgetting an entry that
isn't present is not an error). Returns the updated set:

```jsonc
{ "ok": true, "alwaysAllow": ["edit"] }
```

Separately, `GET /api/settings/hf-token` / `POST /api/settings/hf-token`
manage the Hugging Face write token the same settings modal's other
section uses (see the `upload` CLI command in [cli.md](./cli.md) for the
push-to-hub flow this token drives).

## GET /downloads

Snapshot of the last 5 model downloads (active, completed, or errored)
initiated via `mlx-bun download` or the web library panel.

```jsonc
{
  "downloads": [{
    "repo_id": "…",
    "state": "active" | "done" | "error",
    "current_file": "model.safetensors" | null,
    "received_bytes": 0,
    "total_bytes": 0,
    "files_done": 0,
    "files_total": 0,
    "bytes_per_sec": 0,          // rolling ~5 s window
    "started_at": 1760000000,
    "finished_at": null,
    "error": "…"                 // present on state "error"
  }]
}
```

## Model Hub (`/api/hub/*`)

The web chat's Model Hub panel (docs/design/web-chat-redesign.md §9 Phase 3,
beat-matrix Axis 3): browse downloaded models, search Hugging Face, and kick
off downloads — all loopback-served, no separate auth, same posture as
`/api/gc/*` and `/api/memory/*`. Handlers live in `src/hub-rest.ts` (pure
functions, no loaded-model dependency); route dispatch in `src/server.ts`
just matches path + method.

`GET /api/hub/local` — every model in the local registry (same source
`/library` reads), each with a `/fit`-computed hardware verdict at a fixed
8k context — the beat matrix's "real hardware verdict per row" that optiq's
Hub lacks:

```jsonc
{
  "ok": true,
  "models": [{
    "repo_id": "…",
    "model_type": "gemma3" | "minicpm5" | "qwen3" | …,
    "size_bytes": 0,
    "quant_bits": 4,
    "quant_group_size": 64,
    "vision": false,
    "supported": true,
    "support_tier": "targeted" | "generic" | null,
    "assessment": { "fits": true, "max_safe_context": 8192, "predicted_decode_tps": 0.0 } | null
  }]
}
```

`GET /api/hub/search?q=<query>` — server-side Hugging Face model search,
filtered to the `mlx` library tag (the tag every mlx-community / MLX-format
repo carries) so results are MLX-compatible by construction, normalized to
the fields the Hub panel needs. Never downloads anything — search only.
Degrades gracefully on any network failure (DNS, timeout, non-2xx) to an
explicit offline state rather than a 500:

```jsonc
{ "ok": true, "offline": false, "results": [{ "id": "mlx-community/…", "downloads": 0, "likes": 0, "size_estimate": null }] }
```

```jsonc
{ "ok": true, "offline": true, "error": "…", "results": [] }
```

`size_estimate` is always `null` in v1 — the search endpoint doesn't return
per-repo file sizes and a second per-repo call would slow the search down;
the fit badge lands once a model is actually downloaded (`/api/hub/local`).

`POST /api/hub/download` with body `{"repo": "org/name"}` — starts a
background download via the existing `downloadModel()` +
`src/download.ts` process tracker and returns immediately; progress is
already visible via [`GET /downloads`](#get-downloads). Refuses a duplicate
kick-off for a repo that's already downloading:

```jsonc
{ "ok": true, "repo": "org/name", "started": true }
```

```jsonc
{ "ok": false, "error": "a download for org/name is already in progress" }
```
(409)

`POST /api/hub/serve` with body `{"model": "org/name"}` — **always answers
`restart_required`, never performs a live in-process swap.** Investigated
against `docs/design/runtime-isolation.md`: the web chat's `/ws/chat` path
is explicitly not proxied even under `--isolate` (`src/serve/isolate.ts`
answers it 501), and `--isolate` itself is opt-in, not the default — so the
process a web chat session is actually attached to always has exactly one
model loaded with no drop-weights-and-reload seam reachable from that path.
(The `--isolate` proxy's `ModelPool`, P2 of that doc, *is* a real
spawn-overlap live-swap mechanism — it just lives entirely on the isolated
`/v1/*` HTTP surface, not on `/ws/chat`.) Faking a swap here would leave the
server in a half-state; the honest answer is the restart command:

```jsonc
{ "ok": false, "restart_required": true, "command": "mlx-bun serve org/name" }
```

Wiring `/ws/chat` through the isolate proxy (or otherwise reaching
`ModelPool`'s spawn-overlap swap from the web chat) is the Hub's live-swap
follow-up, not yet scheduled.

## GET /api/sessions/search · GET /api/sessions/export

Full-text search across web-chat session message **bodies** and chat
export (docs/design/web-chat-redesign.md §9 Phase 3, beat-matrix Axis
10/11's full-text-search BEAT: Claude's own session search is title-only —
a widely-cited annoyance — and local storage removes any server-cost
excuse to skip real body search). Same loopback-only, no-separate-auth
posture as `/api/memory/*`/`/api/hub/*`. Handlers live in
`src/serve/session-search.ts` (pure, read-only, no loaded-model
dependency); route dispatch in `src/server.ts` just matches path + method.
Both routes read the same session directory the web chat's `PiWebSession`
writes to (`~/.mlx-bun/sessions`, pi's own JSONL-per-session format) and
are JSONL-tolerant — a corrupt or mid-write line is skipped, never thrown.

`GET /api/sessions/search?q=<query>` — case-insensitive substring scan (v1;
no index — personal-chat-corpus scale, see the module header comment for
the upgrade path if the corpus ever grows enough to matter) over every
session file's user/assistant message text, capped at 50 matches total (10
per session). Each match reports a plain-text ±60-char snippet plus the
match's own `[start,end)` offsets **into that snippet** — offsets, not
pre-rendered HTML highlighting, so the frontend escapes the snippet then
inserts its own `<mark>` (the same escape-then-restore discipline the
markdown renderer uses for code spans, applied here to search
highlighting instead):

```jsonc
{
  "ok": true,
  "results": [{
    "sessionPath": "/Users/…/.mlx-bun/sessions/20260706_…jsonl",
    "sessionTitle": "Chicken recipes",
    "matches": [{ "snippet": "…tell me about rosemary and thyme…", "ranges": [[14, 22]], "role": "user" }]
  }]
}
```

400s `{"ok": false, "error": "q is required"}` without a query.

`GET /api/sessions/export?path=<session file>` — the raw session JSONL,
parsed into an array of entries (one per line, in file order) — the
frontend's Markdown/JSON export renders from this for a session that isn't
the currently-open one (the open session's own history is already loaded
client-side, but this endpoint is used uniformly for both cases so there's
one code path, not two). `path` must resolve under the session directory —
exactly the same guard shape as `PiWebSession`'s private
`isUnderSessionDir` (the root itself, or a path prefixed by `root + "/"`)
— reimplemented as a small standalone check in `session-search.ts` rather
than exported from that class:

```jsonc
{ "ok": true, "path": "…", "entries": [{ "type": "session", "id": "…", "cwd": "…" }, { "type": "message", "message": { "role": "user", "content": "…" } }] }
```

400s without `path`; 403s a `path` outside the session directory; 404s a
path inside the directory that doesn't exist on disk.

## Web app static routes + PWA installability

The web chat (`GET /`) and everything it loads same-origin, no CDN, ever:

| Route | Content | Notes |
| --- | --- | --- |
| `GET /` | `src/web/app.html` | The unified SPA shell. |
| `GET /assets/app.js` | `src/web/app.js` | GENERATED from `src/web/src/*.ts` by `bun scripts/build-web.ts` — see `tests/web-build.test.ts`'s freshness gate. |
| `GET /assets/hljs.js`, `GET /assets/hljs.css` | `src/web/vendor/hljs*` | Vendored syntax highlighting, no CDN (see that dir's README). |
| `GET /manifest.webmanifest` | `src/web/manifest.webmanifest` | PWA manifest — name/short_name/theme colors match the app's design tokens. |
| `GET /assets/icon.svg` | `src/web/icon.svg` | A single inline SVG app icon. No binary PNGs are shipped (the hygiene gate forbids tracked binaries beyond its allowlist); some browsers don't render an SVG as an install icon — accepted, noted in [features-matrix.md](features-matrix.md). |
| `GET /sw.js` | `src/web/sw.js` | Service worker, served `cache-control: no-store` at the root scope (required for a worker to control `/`). |

**PWA scope (beat-matrix Axis 10 "PWA installability"):** the manifest +
service worker exist for *installability and an instant static-shell
paint* — "Add to Home Screen" / a browser "Install app" prompt, and the
next visit's HTML/JS/CSS loading from cache while the WebSocket connects.
This is explicitly **not** offline chat: `src/web/sw.js`'s fetch handler
only intercepts the exact shell files listed above (`/`, `/assets/app.js`,
`/assets/hljs.js`, `/assets/hljs.css`) and lets every dynamic route
(`/api/*`, `/v1/*`, `/ws/chat`, `/downloads`, …) fall straight through to
the network unconditionally — caching a chat API response would be
actively misleading given the app is a thin client over a local model
process that has to actually be running. Registration
(`src/web/src/shell.ts`'s `initServiceWorker()`) is guarded to secure
contexts: `https:` or `localhost`/`127.0.0.1`, matching the browser's own
service-worker eligibility rule.

## GET /fit

Fit assessment for the loaded model on this machine, plus a capability
matrix across Apple SKUs. Used by the status page. Experts bytes come
from the registry so MoE active-parameter predictions match the serve
banner and `mlx-bun fit`. When the eval DB has a real measured decode
rate for this model snapshot, it is included and takes precedence over
the prediction.

```jsonc
{
  "machine": { "chip": "M4 Pro", "ram_bytes": 0, "bandwidth_gbs": 0.0 },
  "context_tokens": 8192,          // current admission ceiling
  "typical_context_tokens": 8192,  // min(8192, context_tokens)
  "typical_decode_tps": 0.0,       // predicted at typical_context_tokens
  "measured_decode_tps": null,     // real number from eval DB, or null
  "measured_at": null,             // unix ms of measurement, or null
  "report": {
    "fits": true,
    "weights_bytes": 0,
    "kv_bytes": 0,
    "transient_bytes": 0,
    "total_bytes": 0,
    "usable_bytes": 0,
    "max_safe_context": 8192,
    "predicted_decode_tps": 0.0
  },
  "sku_matrix_ctx": 32768,
  "sku_matrix": [{
    "sku": "M4 Pro 24 GB", "ram_gb": 24,
    "fits": true, "max_context": 32768, "decode_tps": 0.0
  }]
}
```

## Adapters (LoRA hot-swap)

- `GET /v1/adapters` — `{ adapters: [{ id, path, rank, scale, size_bytes,
  mounted_layers, ram_bytes }] }` — currently-mounted adapters only.
  `ram_bytes` is the actual resident size of the adapter's mounted
  `lora_a`/`lora_b` arrays (summed `MlxArray.nbytes` — real RAM cost while
  mounted, not a guess from the on-disk file size); the web chat's adapter
  routing table (§5.6 of `docs/design/web-chat-redesign.md`) shows this per
  loaded adapter.
- `GET /v1/adapters/available` — `{ adapters: [{ id, path, rank, scale,
  base_model, mounted, compatible }] }` — every adapter found on disk
  (`~/.cache/mlx-bun-finetunes`, `~/.cache/mlx-bun/adapters`), unfiltered.
  `compatible` is true when the adapter's recorded base model matches the
  currently-served model (compared by bare repo name) or the adapter
  recorded no base at all; `mounted` is true when it's already loaded.
  The web chat's adapter chip uses `compatible` to gray out entries it
  won't let you select rather than hiding them.
- `POST /v1/adapters` — `{ "id": "...", "path": "/dir" }`; mounts
  through the generation queue (never races a forward pass). Response:
  `{ id, mounted_layers, rank, scale, ram_bytes }`. 400 on shape/compat
  mismatch — validation is all-or-nothing.
- `DELETE /v1/adapters/<id>` — unmount; 404 if not mounted.

Select per request with the `adapter` body field, which also accepts a
composed spec — `"a+b"` (or `"a,b"`) stacks two mounted adapters, their
LoRA residuals summed in order (`AdapterManager.resolveSpec` /
`parseAdapterSpec` in `src/lora.ts`); every named id must already be
mounted or the request 400s with the unknown id named. The web chat's
adapter routing table exposes this as a "stack" action on top of the
composer's single-select quick-switcher. Prompt-cache entries are
namespaced per adapter spec (including composed ones), so switching
adapters — or switching which ones are stacked — never reuses another
combination's KV.

`serve --adapter <dir>` (alias `--adapter-path`, mlx_lm.server's
spelling) mounts an adapter at startup through this same machinery and
makes it the default for requests that send no `adapter` field; an
explicit `adapter` (including `"none"`) always wins, and hot-swap via
these endpoints is unchanged.

## App-aware assistant (`/ws/chat`)

The web chat agent can see and act on the app it lives in —
`docs/design/web-chat-redesign.md` §6.6, beat matrix Axis 12. No
screenshots and no vision model are involved: the browser sends a
structured DOM snapshot as a WS frame, and the model gets three tools that
read/navigate/highlight that snapshot.

Three tools join the web chat's tool allowlist unconditionally (same
class as `web_search`/`read` — read-only-on-the-machine, never gated by
the approval card, regardless of memory or `codingTools` state; see
`APP_AWARE_TOOL_NAMES` in `src/pi-web.ts`):

- **`get_current_app_context`** — returns the last context the browser
  pushed: `{ route, view?, step?, snapshot }`. `snapshot` is a capped
  (~120) list of visible interactive elements as `{ref, label, kind,
  role?, selector, spotlightId?}`, agent chrome excluded.
- **`navigate_app({ route | page })`** — validates against the route
  catalog (`chat`, `quantize`, `finetune`, `dataset`, `status`; unknown
  routes 400 as a tool error, never silently sent to the browser) and
  emits a `ui_navigate` frame. Reversible; no approval needed.
- **`spotlight_ui({ ref | label | selector | target, route?, message?
  })`** — emits a `ui_spotlight` frame; the browser resolves the target
  (ref from its last snapshot, then live selector, then fuzzy label
  match, then a curated catalog id) and shows a brief highlight. Never
  blocks: the overlay traps no focus and passes clicks straight through
  to the highlighted control, auto-dismisses in ~3s, and any keystroke,
  click, or scroll dismisses it instantly.

Client → server WS frame (pushed by the browser on every route change and
every wizard-step change, never on a timer):

```jsonc
{ "type": "context", "context": { "route": "quantize", "step": { "index": 1, "count": 4, "label": "Configure" }, "snapshot": { "route": "quantize", "capturedAt": "…", "elements": [/* … */] } } }
```

Server → client frames the two action tools produce:

```jsonc
{ "type": "ui_navigate", "route": "quantize" }
{ "type": "ui_spotlight", "target": "quantize-source", "message": "Paste a Hugging Face repo id or local path here" }
```

The server also auto-prepends a compact one-line ambient context (e.g.
`[user is on: Quantize · step 2/4]`) to the system prompt on every turn —
never a full snapshot dump — so the model is never answering completely
blind even when it doesn't call a tool. `ui_act` (approval-gated form-fill
and job-start actions) is explicitly out of scope for this v1; only
navigate/spotlight are wired.

## Client setup: pi

The supported one-command path:

```bash
mlx-bun harness pi            # install; then: pi --provider mlx-bun
mlx-bun harness pi --remove   # undo
```

It writes a self-contained extension to
`~/.pi/agent/extensions/mlx-bun-provider.ts` that registers the `mlx-bun`
provider with live discovery: at pi startup it fetches `/v1/models` from the
running server, so the stable `mlx-bun/local` model handle always resolves to
whatever the server is actually serving (context window, reasoning, and
vision capability included), and never goes stale across model swaps. The
model list baked at install time is only the fallback for when the server is
down.

Manual fallback — `~/.pi/agent/models.json`:

```jsonc
{
  "providers": {
    "mlx-bun": {
      "baseUrl": "http://127.0.0.1:8080/v1",
      "api": "openai-completions",
      "apiKey": "sk-anything-nonempty",
      "models": [{ "id": "<model id from /v1/models>" }]
    }
  }
}
```

Note the manual route bakes a concrete model id, which goes stale when you
serve a different model — the staleness `harness pi`'s `local` id exists to
solve.

Any OpenAI SDK works the same way: `baseURL: "http://127.0.0.1:8080/v1"`,
any non-empty `apiKey`.
