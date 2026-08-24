# Server API

`mlx-bun serve` exposes an OpenAI-compatible HTTP API on one model. The
request's `model` field is ignored; the loaded model's id is echoed back.
By default generation is serialized through a single queue (one GPU,
batch = 1); `--batch N` switches the server into bf16 continuous batching.

This is the canonical wire reference: every route the server registers is
listed below, and every field documented here exists in the code that
serves it (`src/server.ts`, `src/serve/*-routes.ts`, `src/serve/isolate.ts`,
`src/pi-web.ts`). Start flags (`--port`, `--memory-budget`,
`--prompt-cache`, `--batch`, `--kv-quant`, `--thinking`, sampling
defaults) and which combinations compose live in
[server-config.md](./server-config.md); the CLI in [cli.md](./cli.md).

## Route index

Dispatch order matters only for `/ws/chat` (upgrade) and the static shell;
every other path is unique. Unmatched paths return
`404 {"error":{"message":"not found"}}`.

| Method | Path | Section |
| --- | --- | --- |
| POST | `/v1/chat/completions` | [Chat completions](#post-v1chatcompletions) |
| POST | `/v1/completions` | [Text completions](#post-v1completions-raw-text-completion) |
| POST | `/v1/messages` | [Anthropic Messages](#post-v1messages-anthropic-messages-api) |
| POST | `/v1/responses` | [OpenAI Responses](#post-v1responses-openai-responses-api) |
| POST | `/v1/embeddings` | [Embeddings](#post-v1embeddings-openai-embeddings-api) |
| GET | `/v1` | [API index](#get-v1) |
| GET | `/v1/models`, `/v1/models/<id>` | [Models](#get-v1models) |
| GET / POST | `/v1/adapters` | [Adapters](#adapters-lora-hot-swap) |
| GET | `/v1/adapters/available` | [Adapters](#adapters-lora-hot-swap) |
| DELETE | `/v1/adapters/<id>` | [Adapters](#adapters-lora-hot-swap) |
| GET | `/health` | [Health](#get-health) |
| GET | `/stats` | [Stats](#get-stats) |
| GET | `/fit` | [Fit](#get-fit) |
| GET | `/library` | [Library](#get-library) |
| GET | `/downloads` | [Downloads](#get-downloads) |
| POST | `/admin/cache/flush` | [SSD cache flush](#post-admincacheflush) |
| GET | `/api/jobs`, `/api/jobs/<id>`, `/api/jobs/<id>/stream` | [Jobs](#jobs-apijobs) |
| POST | `/api/finetune/submit`, `/inspect-dataset`, `/merge`, `/export` | [Fine-tune](#fine-tune-apifinetune) |
| POST | `/api/quantize/inspect`, `/submit`, `/resolve-folder` | [Quantize](#quantize-apiquantize) |
| GET / POST | `/api/dataset/templates`, `/api/dataset/submit` | [Dataset](#dataset-apidataset) |
| POST | `/api/model/resolve-folder` | [Quantize](#quantize-apiquantize) |
| POST | `/api/{quantize,finetune,dataset}/push` | [Push to Hub](#post-apiquantizefinetunedatasetpush) |
| GET / POST | `/api/gc/plan`, `/api/gc/execute` | [GC](#get-apigcplan--post-apigcexecute) |
| GET / POST | `/api/memory/*` | [Memory](#get-apimemory--post-apimemoryinit) |
| GET | `/v1/memory/synthesize` | [Memory synthesis](#get-v1memorysynthesize) |
| GET / POST / DELETE | `/api/settings/hf-token`, `/api/settings/tool-approvals` | [Settings](#settings-apisettings) |
| GET / POST | `/api/hub/local`, `/search`, `/download`, `/serve` | [Model Hub](#model-hub-apihub) |
| GET | `/api/sessions/search`, `/api/sessions/export` | [Sessions](#get-apisessionssearch--get-apisessionsexport) |
| GET | `/`, `/assets/*`, `/manifest.webmanifest`, `/sw.js`, `/curves`, `/curve-terrain`, `/dag` | [Static](#web-app-static-routes--pwa-installability) |
| GET | `/status`, `/chat`, `/quantize`, `/finetune`, `/dataset` | 302 to `/#<path>` ([Static](#web-app-static-routes--pwa-installability)) |
| POST | `/signal`, `/generate` | [Curve Designer](#curve-designer-post-signal--post-generate) |
| WS | `/ws/chat` | [Web chat WebSocket](#web-chat-websocket-wschat) |

Internal routes (not part of the client contract):

| Method | Path | Where | Notes |
| --- | --- | --- | --- |
| POST | `/admin/drain` | `src/server.ts` | Only registered when the server is bound to a unix socket (`--unix`, i.e. an `--isolate` engine child). Quiesces the gateway and demotes the whole prompt cache to the SSD tier; returns `{ "drained": true, "demotions": N }`. Never exposed on TCP. |
| GET | `/engine` | `src/serve/isolate.ts` | Only on the `--isolate` parent proxy: `{ isolated: true, pid, restarts, socket, pool?: { resident, default } }`. |

Under `--isolate`, the parent proxies everything to the engine child;
`/ws/chat` is answered `501` there (web chat needs a non-isolated server),
`/v1/chat/completions`, `/v1/completions`, `/v1/messages`, `/v1/responses`,
and `/v1/embeddings` are routed by the body's `model` field when a
`--model-pool` is configured, an unreachable child is
`502 {"error":{"type":"engine_unavailable"}}`, and a client disconnect
mid-proxy is `499`.

## Diagnostics: `x-mlx-bun-trace-id` and `MLX_BUN_P2R_TRACE`

`/v1/chat/completions` and `/v1/completions` read an optional
`x-mlx-bun-trace-id` request header. With `MLX_BUN_P2R_TRACE=1` set on the
server, each of those requests emits one JSON record to stderr, prefixed
`[p2r] `, when it finishes (`src/serve/prompt-response-trace.ts`). Without
the env var nothing is allocated and the header is ignored.

```jsonc
{
  "version": 1,
  "traceId": "<x-mlx-bun-trace-id, or the request id when absent>",
  "requestId": "chatcmpl-…" | "cmpl-…",
  "route": "/v1/chat/completions" | "/v1/completions",
  "clock": "monotonic-ms",
  "outcome": "success" | "error" | "abort",
  "totalMs": 0.0,
  "events": [                      // sorted by startMs
    { "phase": "request.body_parse", "startMs": 0.0, "durationMs": 0.0,
      "attributes": { /* optional string|number|boolean|null map */ } }
  ],
  "attributes": { "stage": "body_parse" | "prepare_completion" }  // on some errors
}
```

Phases: `request.body_parse`, `request.prompt_prepare`, `completion.total`,
`completion.placement`, `engine.admission_wait`, `cache.lookup_restore`,
`prefill.total`, `prefill.batch_setup`, `prefill.chunk`,
`prefill.kv_maintenance`, `token_zero.total`, `token_zero.forward`,
`token_zero.head`, `token_zero.sample`, `response.first_write`,
`response.final_write`. Marks (`response.first_write`,
`response.final_write`) have `durationMs: 0`.

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
  "tool_choice": "auto",         // "none" disables tools; "auto" and the
                                 //   {type:"function", function:{name}}
                                 //   object are accepted and treated as auto
  "chat_template_kwargs": {      // forwarded to the chat template
    "enable_thinking": false,    // MiniCPM5 / Qwen3.5/3.8 / GLM-5.2: <think>
                                 // channel on/off (Qwen3.8 default: ON)
    "preserve_thinking": true    // Qwen3.8: keep think blocks from earlier
                                 // assistant turns in the rendered prompt
                                 // (template default true — better prompt-
                                 // cache reuse in agent loops). Ignored by
                                 // templates that don't read it.
  },
  "reasoning_effort": "medium",  // "none"|"minimal"|"low"|"medium"|"high"|"xhigh"
                                 // gates enable_thinking on Qwen3.5/3.8/
                                 // MiniCPM5: "none" → off, any other level →
                                 // on. Only consulted when chat_template_
                                 // kwargs.enable_thinking is not explicitly
                                 // set — an explicit enable_thinking always
                                 // wins. On templates with a reasoning-depth
                                 // variable (Qwen3.8) the level also maps
                                 // into the template: minimal/low → low,
                                 // medium → medium, high/xhigh → xhigh.
                                 // Any OTHER string is a 400.
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
GLM-5.2 also defaults to no-think: its generation primer is
`<think></think>`. Enabling thinking renders `Reasoning Effort: Max` in the
system turn and leaves an open `<think>` primer for generation. The same
precedence applies through Chat Completions, Anthropic Messages, and Responses
because all three normalize into this one chat request path.

`stop` sequences are matched on **decoded text**, not token ids, so a
sequence that spans token boundaries still fires. Generation halts at
the first match; the stop sequence itself is excluded from the content
and `finish_reason` is `"stop"`.

Message `content` is a string or an array of parts:
`{ "type": "text", "text": ... }` and
`{ "type": "image_url", "image_url": { "url": "data:image/png;base64,..." } }`
(`{ "type": "image", ... }` is accepted as an alias; http/https URLs also
accepted; PNG, JPEG, HEIC, AVIF, WebP, TIFF, GIF, BMP via native OS codecs;
requires a model with the vision sidecar).

Remote (http/https) media URLs — image, audio, and video alike — go
through a destination policy (`src/media-fetch.ts`): **private/loopback/
link-local hosts are refused by default** (the request URL is
attacker-controlled input — SSRF), every redirect hop is re-validated, and
the fetch has a **10 s timeout** and a **64 MB response cap** (video:
**256 MB** — clips are legitimately larger; frame sampling truncates long
clips server-side). Violations are clean `400`s
(`prompt build failed: image url rejected: …`). Serving media from a LAN
host (a NAS, another machine) is the opt-in
[`--allow-private-media`](server-config.md#start-flags) flag (or
`MLX_BUN_ALLOW_PRIVATE_MEDIA=1`). `data:` URLs are decoded locally and
never policy-checked.

### Video input (Qwen3.5-family models)

Video rides the same content-part array:

```jsonc
{ "type": "video_url", "video_url": { "url": "data:video/mp4;base64,…|http(s)://…" } }
{ "type": "video",     "data": "<base64>" }                          // alias
```

The container decodes through macOS's own AVFoundation codecs (mp4/mov,
H.264/HEVC/ProRes/… — whatever this macOS plays) via the
`mlx-bun-frame-extract` helper that ships beside the binary and in the
native pack; from a source tree it compiles on first use with the Xcode
CLT. Frames are sampled at **2 fps, capped at 768 frames**
(`src/vision/video-frames.ts`), then run the gated Qwen3-VL video pipeline
(temporal frame pairs, per-frame-group attention, 3D mRoPE positions).
Qwen3.5-family models only; video never combines with audio parts
(`400 "video and audio content parts cannot be combined"`), and a non-Qwen
model answers video parts with a `400` naming the model.

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
  anything else CoreAudio reads transcode via macOS `afconvert`
  (`src/audio/transcode.ts`); undecodable bytes are a `400`.
- **Internal format**: 16 kHz mono — multi-channel input is mean-mixed,
  other rates resample. Clips truncate at **30 s** (the oracle
  processor's 480 000-sample cap); one clip costs
  `ceil(duration_ms / 40)` prompt tokens, at most **750**
  (`src/audio/decode.ts`).
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
      "content": "…",                      // null when the reply is ONLY tool calls
      "reasoning": "…",                    // present only when the model emitted a
                                           //   <think> channel (thinking-capable
                                           //   templates with thinking on)
      "tool_calls": [{                     // present when the model called tools
        "id": "call_…", "type": "function",
        "function": { "name": "…", "arguments": "{…json…}" }
      }]
    },
    "logprobs": { /* see below; only when requested */ },
    "finish_reason": "stop" | "length" | "tool_calls"
  }],
  "usage": {
    "prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0,
    "prompt_tokens_details": { "cached_tokens": 0 },  // prompt-cache reuse
    "lane": "serial",              // "serial" | "serial+spec" | "batched" —
                                    //   which execution lane served THIS
                                    //   request. Chat completions and text
                                    //   completions (streaming: final usage
                                    //   chunk).
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
extension appears on chat and text completions alike, non-streaming and on
the final stream chunk. Spec-eligible requests are text-only on base weights
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
penalties), **before** the sampler's temperature/top-p/top-k/min-p/XTC.
mlx-lm's top-k order is unspecified (argpartition); ours is sorted
descending — the same set, so the entry is deterministically the argmax.
Stream chunks never carry logprobs (mlx-lm's streaming responses don't
either). Requests with logprobs run on the serial lane under `--batch N`
(like the other mlx-lm sampler extensions). Invalid values are rejected
with mlx-lm's exact messages (see Errors).

### Streaming

`"stream": true` is SSE: `data: <chunk>\n\n` per event, terminated by
`data: [DONE]`. Chunks are `chat.completion.chunk` objects whose
`choices[0].delta` carries `{role: "assistant", content: ""}` first, then
`{reasoning}` increments while the model is inside its `<think>` channel,
then `{content}` increments (multi-byte sequences are held back until
decodable; text that could begin a `stop` sequence is held back until
disambiguated, so no part of a stop sequence is ever streamed), then for
tool calls a `{tool_calls: [{index, id, type, function}]}` delta; the last
chunk carries `finish_reason` and `usage`. A generation error mid-stream is
sent as `data: {"error":{"message":…}}` and the stream closes.

### Tool calls

Tool round-trip: send the assistant message with its `tool_calls` back,
followed by `{ "role": "tool", "tool_call_id": …, "content": … }`
messages; multi-turn prompt prefixes reuse the KV prompt cache
automatically.

Tool-call parsing is per model family (`selectToolStreamMode` in
`src/server.ts`, parsers in `src/tool-call.ts`). Gemma 4 uses its native
`<|tool_call>`…`<tool_call|>` sentinel tokens. Every other family parses
**decoded text** once tools are active: OpenAI-JSON
`<tool_call>{…}</tool_call>`, Qwen-style
`<tool_call><function=name><parameter=key>value</parameter></function></tool_call>`,
GLM-5.2's `name<arg_key>…<arg_value>…`, and MiniCPM5's
`<function name="…"><param name="…">…</param></function>` (CDATA-wrapped
values supported). Content before the tool markup still streams live; only
the markup is withheld and converted to `tool_calls`. Argument values are
decoded against the tool's JSON schema (string-typed params stay strings).

When strict parsing fails, a repair pass runs before giving up: a
```` ```json ```` fence or prose prefix is stripped, single quotes and
trailing commas are fixed, truncated braces are closed, a function name
that landed inside `arguments` is lifted into the envelope, and Python
literals `True`/`False`/`None` **outside string values** are coerced to
`true`/`false`/`null` (`pythonLiteralsToJson`, `src/tool-call.ts` — Qwen3.5
in particular emits Python booleans). The repair is not reported on the
wire; markup that still fails to parse falls back to plain content.

### Structured output (grammar-constrained decoding)

Both `/v1/chat/completions` and `/v1/completions` accept the
OpenAI/oMLX/vLLM structured-output fields (snake_case on the wire; the
field names are `GrammarRequest` in `src/grammar.ts`):

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

| Field | Compiles to (xgrammar) | Output |
| --- | --- | --- |
| `response_format: {type:"json_object"}` | builtin JSON grammar | any valid JSON |
| `response_format: {type:"json_schema", json_schema:{name, schema, strict?, any_whitespace?}}` | `compileJSONSchema(schema)` | schema-conformant JSON |
| `guided_grammar` | `Grammar.fromEBNF` | text matching the grammar |
| `guided_regex` | EBNF-wrapped regex | text matching the regex subset |
| `guided_choice` | `root ::= ("a" \| "b" \| …)` | exactly one of the strings |
| `structured_outputs` | bare schema (alias for `json_schema.schema`) | schema-conformant JSON |

Precedence when several are set (`resolveGrammarRequest`): `guided_grammar`
> `response_format` json_schema > json_object > `structured_outputs` >
`guided_regex` > `guided_choice`. `response_format: {type:"text"}` or no
field at all means no constraint.

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
`Warning` header only. `MLX_BUN_GRAMMAR=0` disables mask compilation but
does not silently ignore a requested constraint: it uses this same degrade
path with the hint `grammar compilation disabled by MLX_BUN_GRAMMAR=0`.
Design and fidelity notes: [docs/reference/server-api.md](./server-api.md).

### Errors

All errors are `{ "error": { "message": …, ... } }`.

- `400` — malformed JSON (`invalid JSON body`), empty `messages`
  (`messages required`), unknown adapter id, vision request on a model
  without a sidecar (`model has no vision sidecar`), audio request on a
  model without an audio tower (message names the model), video on a
  non-Qwen3.5 model or combined with audio, prompt build failures
  (`prompt build failed: …`, which includes media fetch/transcode
  errors), non-numeric `logit_bias` keys/values (`logit_bias must be a
  dict of int to float`, mlx-lm's coercion error), invalid logprobs params
  (mlx-lm's exact validation: `logprobs must be of type bool`,
  `top_logprobs must be of type int` / `at least 0` / `at most 11`;
  `top_logprobs: -1` is the accepted "unset" sentinel), invalid
  `reasoning_effort` (`reasoning_effort must be one of 'none', 'minimal',
  'low', 'medium', 'high', 'xhigh'`).
- `400` with `"type": "memory_admission"`, `"code":
  "context_over_budget"` — the PROMPT itself leaves no generation slot
  within the max safe context (`src/serve/request-plan.ts`). A prompt that
  fits is never rejected for a broad `max_tokens`: the upper bound is
  capped to the remaining room (`max_tokens` is a ceiling, not a promise)
  and generation proceeds. The ceiling is visible at `/stats`.
- `500` — a generation failure after admission; the stack is logged
  server-side, the body keeps only the message.

## POST /v1/completions (raw text completion)

`mlx_lm.server`'s text-completion endpoint: **no chat template** — the
`prompt` string is tokenized directly (the tokenizer's own BOS handling,
exactly mlx-lm's `tokenizer.encode(request.prompt)`) and the model
continues it. Same generation gateway, admission control, prompt cache,
and adapter selection as chat.

```jsonc
{
  "prompt": "Once upon a time",  // REQUIRED, non-empty string only (token
                                 // arrays rejected, matching mlx_lm.server)
  "max_tokens": 512,             // default 512 (mlx_lm.server's default) —
                                 // NOT the chat lane's generous default;
                                 // max_completion_tokens wins when set
  "stream": false,
  "stop": "\n\n",                // string or array, decoded-text matching
  // plus every sampling/penalty field from /v1/chat/completions:
  // temperature, top_p, top_k, seed, min_p, xtc_probability,
  // xtc_threshold, logit_bias, repetition_penalty,
  // repetition_context_size, presence_penalty, presence_context_size,
  // frequency_penalty, frequency_context_size, hlg, adapter,
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
  "choices": [{ "index": 0, "text": "…", "finish_reason": "stop" | "length",
                "logprobs": { /* only when requested */ } }],
  "usage": { "prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0,
             "prompt_tokens_details": { "cached_tokens": 0 },
             "lane": "serial" }
             // + "speculation" under --draft-model, as on chat
}
```

Streaming (`"stream": true`) is SSE: `text_completion` chunks whose
`choices[0].text` carries the delta; the final chunk carries
`finish_reason` and `usage` (always attached — mlx-lm gates usage behind
`stream_options.include_usage`; ours is an additive superset), then
`data: [DONE]`. There is no `echo` parameter (mlx_lm.server has none).
`400` on a missing/empty/non-string `prompt`, plus the same logit_bias,
logprobs, and admission errors as chat.

## POST /v1/messages (Anthropic Messages API)

Anthropic-protocol surface over the same engine — on by default, like
`optiq serve`. Point any Anthropic-SDK tool at the server
(`ANTHROPIC_BASE_URL=http://localhost:8080`, any `x-api-key`) — Claude
Code works as a client this way. Translation lives in `src/anthropic.ts`;
the request funnels into the chat handler above.

- `system` (string or text blocks), `messages` with string or
  content-block arrays; `tool_use` / `tool_result` blocks map to the
  native tool-calling path; `image` blocks (base64 or url source) hit the
  vision path on sidecar models, including image blocks nested inside a
  `tool_result` (the computer-use shape). Other image source types are a
  `400`. The protocol has no audio input block; audio-shaped blocks
  (`input_audio` / `audio` / `audio_url`) are rejected with a `400` pointing
  to `/v1/chat/completions`. Prior-turn `thinking` blocks are dropped on
  re-ingest.
- `tools` (`{name, description, input_schema}`) map to function tools;
  entries without `name` + `input_schema` (server-tool types such as
  web_search) are dropped silently.
- `max_tokens`, `temperature`, `top_p`, `top_k`, `stop_sequences`,
  `stream` as in the Anthropic spec. The mlx-lm sampler/penalty
  extensions (`min_p`, `xtc_probability`, `xtc_threshold`,
  `repetition_penalty`, `presence_penalty`, `frequency_penalty` + their
  `*_context_size` windows) pass through as extras; `logit_bias` does
  not exist in this protocol and is not accepted here.
- Response: `{id: "msg_…", type: "message", role: "assistant", content:
  [{type: "text"} | {type: "tool_use"}…], stop_reason, stop_sequence,
  usage: {input_tokens, output_tokens, cache_read_input_tokens?}}` —
  `cache_read_input_tokens` is present when the prompt cache contributed.
- Streaming follows the Anthropic event grammar exactly:
  `message_start → content_block_start/delta/stop (text_delta,
  input_json_delta) → message_delta (stop_reason + usage) →
  message_stop`. Errors are `event: error` frames.
- Errors: `{type: "error", error: {type: "invalid_request_error" |
  "api_error", message}}` — the chat handler's `4xx`/`5xx` are re-wrapped
  into this shape.

## POST /v1/responses (OpenAI Responses API)

Responses-protocol surface (Codex, Cursor, Continue, Cline, and the
OpenAI SDK speak this now). Oracle: optiq responses shim; port in
`src/responses.ts`.

- `input` (string or item array: `message`, `function_call`,
  `function_call_output`), `instructions` (merged with any
  system/developer items into one leading system message),
  `max_output_tokens` (or `max_tokens`), `temperature`, `top_p`, `top_k`,
  flat `tools`/`tool_choice` (built-in tool types — web_search, file_search,
  mcp, computer_use — dropped silently; `{type:"function", name}` maps to
  the chat object form, `"auto"`/`"none"`/`"required"` pass through),
  `stream`. The mlx-lm sampler/penalty extensions (`min_p`,
  `xtc_probability`, `xtc_threshold`, `logit_bias`, `repetition_penalty`,
  `presence_penalty`, `frequency_penalty` + `*_context_size`) pass through
  as extras.
- **`previous_response_id` resumption**: pass a prior response id
  instead of resending the conversation; the server splices the stored
  input + output back in (instructions carry forward when omitted;
  reasoning items are not replayed). Store is per-process, 1 h TTL,
  32 MiB byte-capped LRU — observable at `GET /stats` (`response_store`).
  Unknown/expired id → `404`.
- Response: `{id: "resp_…", object: "response", status: "completed" |
  "incomplete", output: [{type: "reasoning", summary: [{type:
  "summary_text", text}]}?, {type: "message"}, {type: "function_call"}…],
  usage: {input_tokens, output_tokens, total_tokens,
  output_tokens_details: {reasoning_tokens}}, previous_response_id}`. A
  `reasoning` item is present only when the model emitted a think channel.
- Streaming event chain: `response.created → response.in_progress →
  response.output_item.added → response.content_part.added →
  response.output_text.delta… → response.output_text.done →
  response.content_part.done → response.output_item.done →
  response.completed` (+ `response.function_call_arguments.delta/.done`
  for tool calls; a reasoning output item precedes the message when the
  model thinks).
- Errors: `{error: {message, type: "invalid_request_error" |
  "server_error", param: null, code: null}}`.

## POST /v1/embeddings (OpenAI Embeddings API)

Text embeddings, available when the **served model is an embedding model**
(plain Qwen3 / Qwen3-Embedding) — consistent with the single-model server:
`mlx-bun serve mlx-community/Qwen3-Embedding-4B-4bit-DWQ`, then POST here. On
any other served model the route returns `400 invalid_request_error`
(`src/serve/model-admin-routes.ts`).

- `input` (string or array of strings; anything else is a `400`), `model`
  (ignored — the served model is used), and a **non-standard**
  `instruction` (optional): applies Qwen3-Embedding's query format
  `Instruct: {instruction}\nQuery:{text}`, which steers *which* similarity
  axis the geometry reflects. Omit it for plain document embeddings.
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

## GET /v1

API index for discovery tooling:

```jsonc
{ "name": "mlx-bun", "version": "<package version>", "model": "<served model id>",
  "endpoints": ["POST /v1/chat/completions", "POST /v1/completions", "POST /v1/messages",
                "POST /v1/responses", "POST /v1/embeddings", "GET /v1/models",
                "GET/POST/DELETE /v1/adapters", "GET /health", "GET /stats", "GET /fit",
                "GET /library", "GET /downloads"] }
```

(The list is a curated subset; this document is the full inventory.)

## GET /v1/models

`{ "object": "list", "data": [{ "id": "<model id>", "object": "model",
"created": <unix s>, … }] }` — `created` is the server start time for every
row.

The served model is FIRST, with extra capability fields:

```jsonc
{
  "id": "<served model id>", "object": "model", "created": 1760000000,
  "owned_by": "mlx-bun",
  "context_window": 32768,
  "reasoning": false,           // switchable thinking channel (gates the
                                 //   web chat's thinking toggle)
  "vision": false,               // image input accepted (tower loaded or
                                 //   lazily loadable)
  "audio": false,                // input_audio content parts accepted
                                 //   (tower loaded or lazily loadable)
  "batch_mode": "batch",       // loaded cache capability; per-request
                                 //   usage.lane is authoritative
  "tools": true,
  "structured_output": true,
  "embeddings": false,
  "adapters": false,
  "training": false,
  "dsa": true,                  // GLM-5.2 only; false elsewhere
  "mtp": true,                  // checkpoint-native GLM MTP is mounted
  "capabilities": {             // explicit discoverable surface
    "chat_completions": true, "text_completions": true,
    "anthropic_messages": true, "responses": true,
    "streaming": true, "tools": true, "structured_output": true,
    "logprobs": true, "embeddings": false,
    "vision": false, "audio": false,
    "adapters": false, "training": false
  },
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
{ "id": "<repo id>", "object": "model", "created": 1760000000,
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
The served-model row also includes `batch_mode: "off" | "serial" | "batch"`:
the configured cap and the loaded model's cache capability together. Per-turn
`usage.lane` remains authoritative for a particular request; for example,
native-MTP requests route serial even when the served GLM model reports
`batch_mode: "batch"` for ordinary requests.
For GLM-5.2, the non-generative fields are deliberately false: embeddings,
vision/audio, adapters, and training are not emulated by the serving port.

## GET /health

`{"status": "ok"}` — byte-for-byte what `mlx_lm.server` returns.

## GET /stats

```jsonc
{
  "server": { "owner": "serve" | "pi-session" | "embedded", "model": "...", "started_at": 0 },
  "prompt_cache": { "entries": 0, "bytes": 0, "max_bytes": 0, "hits": 0, "misses": 0 },
  "response_store": { "entries": 0, "bytes": 0, "max_bytes": 33554432, "ttl_ms": 3600000 },
  "kv_quant": { "mode": "bf16" | "uniform-kv8" | "turbo k8v3" | "mixed (kv_config.json)",
                 "layers": { "kv4": 8, "bf16": 40 },     // turbo: { "turbo-k8v3": 8, "bf16": 40 }
                 "attention": { "global": 10, "sliding_window": 38 } },
  // present only when --ssd-cache is on:
  "ssd_cache": { "dir": "...", "entries": 0, "bytes": 0, "max_bytes": 0,
                 "restores": 0, "spills": 0, "restore_ms_last": 0, "demotions": 0,
                 // bounded write-behind queue (MLX_BUN_SSD_SPILL_QUEUE_GB):
                 "pending_snapshots": 0, "pending_spills": 0,
                 "pending_spill_bytes": 0, "dropped_spills": 0,
                 "failed_spills": 0, "longest_durable_prefix_tokens": 0 },
  "admission": {
    "max_safe_context": 0,            // tokens; requests above this 400
    "memory_budget_bytes": null,      // explicit budget, or null (machine default)
    "usable_bytes": 0,
    "weights_bytes": 0
  },
  // present only for the direct Colibri GLM-5.2 runtime:
  "glm52": {
    "preset": "g5-32gb-quality",
    "planned_process_bytes": 0,
    "process_limit_bytes": 0,
    "context_tokens": 4096,
    "max_generation_tokens": 128,
    "batch_size": 1,
    "dsa": true,
    "mtp": true,
    "mtp_draft_tokens": 3,
    "resident_weight_bytes": 0,
    "main_expert_slab_bytes": 0,
    "mtp_expert_slab_bytes": 0,
    "expert_runtime": {               // null when the expert runtime is off
      "main_residency": { "resident": 0, "pinned": 0, "working": 0,
                            "hits": 0, "misses": 0, "evictions": 0 },
      "mtp_residency": { /* same shape */ } | null,
      "last_turn": { "main": { "demand": { "hits": 0, "misses": 0, "readBytes": 0 } },
                     "mtp": { "demand": { "hits": 0, "misses": 0, "readBytes": 0 } },
                     "pilot": null },
      "last_repin": []
    }
  },
  "batch": {
    "configured": 1,                  // the --batch N value
    "mode": "off",                   // "off" | "serial" | "batch": configured
                                           // and model-cache capability together
    "batched": false,                 // true only when mode == "batch"
    "active_rows": 0,                 // rows currently decoding in the batch
    "pending_rows": 0,                // queued + mid-prefill rows waiting
    "submitted_rows": 0,              // cumulative rows routed to the batch lane since start
    "kv_bytes": 0,                    // projected aggregate KV bytes of admitted rows
    "kv_budget_bytes": null           // --kv-budget cap, or null (uncapped)
  }
}
```

`kv_quant.mode` reflects the `--kv-quant` flag the server was started
with; the default is `bf16` (no KV quantization). `mixed (kv_config.json)`
appears only when `--kv-quant config` was passed explicitly and the
checkpoint ships a per-layer `kv_config.json` — per-layer KV quantization
is never selected automatically.

`pending_snapshots` counts prompt-cache entries scheduled for persistence but
not yet confirmed by the atomic SSD store. `longest_durable_prefix_tokens` is
the longest prefix already present in the SSD index, not merely queued.

## GET /fit

Fit assessment for the loaded model on this machine, plus a capability
matrix across Apple SKUs. Used by the status page. Experts bytes come
from the registry so MoE active-parameter predictions match the serve
banner and `mlx-bun fit`. When the eval DB has a real measured decode
rate for this model snapshot, it is included and takes precedence over
the prediction.

For the direct Colibri GLM-5.2 runtime this endpoint switches to the exact
serve-time memory plan. The response separates the full streamed artifact on
disk from resident weights, main/MTP expert slabs, KV, and other reserves.
`measured_decode_tps` is the G5 warm quality-preserving measurement;
`glm52.direct_oracle_warm_decode_tps` is the same-machine direct Colibri
control, while `glm52.aspirational_decode_tps` is a target, not a release
gate. The single-row SKU result describes the current machine because the
generic all-resident SKU estimator is inapplicable
(`report.predicted_decode_tps` is `null` there).

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
  // GLM-5.2 only:
  "glm52": {
    "artifact_disk_bytes": 0,       // exact registry size; null if unavailable
    "main_expert_slab_bytes": 0,
    "mtp_expert_slab_bytes": 0,
    "max_generation_tokens": 128,
    "direct_oracle_warm_decode_tps": 0.27,
    "aspirational_decode_tps": 2.0
  },
  "sku_matrix_ctx": 32768,
  "sku_matrix": [{
    "sku": "M4 Pro 24 GB", "ram_gb": 24,
    "fits": true, "max_context": 32768, "decode_tps": 0.0
  }]
}
```

## Adapters (LoRA hot-swap)

Routes in `src/serve/model-admin-routes.ts`; the manager is
`AdapterManager` in `src/lora.ts`.

- `GET /v1/adapters` — `{ adapters: [{ id, path, rank, scale, size_bytes,
  mounted_layers, ram_bytes }] }` — currently-mounted adapters only.
  `ram_bytes` is the actual resident size of the adapter's mounted
  `lora_a`/`lora_b` arrays (summed `MlxArray.nbytes` — real RAM cost while
  mounted, not a guess from the on-disk file size).
- `GET /v1/adapters/available` — `{ adapters: [{ id, path, rank, scale,
  base_model, mounted, compatible }] }` — every adapter found on disk
  (`~/.cache/mlx-bun-finetunes`, `~/.cache/mlx-bun/adapters`), unfiltered.
  `compatible` is true when the adapter's recorded base model matches the
  currently-served model (compared by bare repo name) or the adapter
  recorded no base at all; `mounted` is true when it's already loaded.
  The web chat's adapter chip uses `compatible` to gray out entries it
  won't let you select rather than hiding them.
- `POST /v1/adapters` — `{ "id": "...", "path": "/dir" }` (both required,
  else `400 "id and path required"`); mounts through the generation queue
  (never races a forward pass). Response:
  `{ id, mounted_layers, rank, scale, ram_bytes }`. `400` on shape/compat
  mismatch — validation is all-or-nothing.
- `DELETE /v1/adapters/<id>` — unmount; `{ id, removed_layers }` on
  success, `404 {"error":{"message":"adapter <id> not mounted"}}` otherwise.

Select per request with the `adapter` body field (chat, text completions;
the Anthropic and Responses surfaces pass it through as an extra), which
also accepts a composed spec — `"a+b"` (or `"a,b"`) stacks two mounted
adapters, their LoRA residuals summed in order
(`AdapterManager.resolveSpec` / `parseAdapterSpec` in `src/lora.ts`);
every named id must already be mounted or the request 400s with the
unknown id named. Prompt-cache entries are namespaced per adapter spec
(including composed ones), so switching adapters — or switching which
ones are stacked — never reuses another combination's KV.

`serve --adapter <dir>` (alias `--adapter-path`, mlx_lm.server's
spelling) mounts an adapter at startup through this same machinery and
makes it the default for requests that send no `adapter` field; an
explicit `adapter` (including `"none"`) always wins, and hot-swap via
these endpoints is unchanged.

## POST /admin/cache/flush

Forces every pending SSD prompt-cache snapshot through the serial write queue
and waits for the atomic temp-file/fsync/rename boundary. The response is `200`
only when no snapshot or spill remains pending and no write failed during this
flush; otherwise it is `503` with the counters that explain why.

```jsonc
{
  "durable": true,
  "flushedSnapshots": 1,
  "missingSnapshots": 0,
  "pendingSnapshots": 0,
  "pendingSpills": 0,
  "pendingSpillBytes": 0,
  "droppedSpills": 0,
  "failedSpills": 0,
  "elapsedMs": 842,
  "entries": 2,
  "longest_durable_prefix_tokens": 16384
}
```

The standard benchmark calls this endpoint before its restart leg and records
the result. Normal `mlx-bun serve` shutdown on `SIGINT` or `SIGTERM` performs
the same flush after active requests drain, with a 120-second default timeout.
Without `--ssd-cache` the route still answers (`entries: 0`).

## GET /library

Returns all models found in the local HuggingFace hub cache (via the
registry scan), each annotated with a fit assessment for this machine.
Response is cached for 30 seconds (registry scan + config reads; no
tensor bytes are read). Handler: `src/serve/discovery-routes.ts`.

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

## GET /downloads

Snapshot of the last 5 model downloads (active, completed, or errored)
initiated via `mlx-bun download`, the web library panel, or
`POST /api/hub/download`.

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

## Jobs (`/api/jobs`)

The web wizards (quantize, fine-tune, dataset) run as jobs: a SQLite row
plus an NDJSON event log (`src/jobs/`). Submit routes return a `job_id`;
these routes read progress. Loopback-served admin routes, no separate auth
(same posture as every other `/api/*` route). Handler:
`src/serve/admin-routes.ts`.

`GET /api/jobs?limit=50&kind=quantize|finetune|dataset` — most recent
jobs, newest first: `{ "ok": true, "jobs": [JobRow, …] }`.

`GET /api/jobs/<id>` — one row, or `404 { "ok": false, "error": "job not
found" }`:

```jsonc
{ "ok": true, "job": {
  "id": "…", "kind": "quantize" | "finetune" | "dataset",
  "status": "queued" | "running" | "done" | "failed" | "zombie",
  "config_json": "{…}",          // the submit body as stored
  "progress": 0.0,               // 0..1, from the latest stage/metric event
  "message": "…" | null,
  "log_path": "…", "output_path": "…" | null, "error": "…" | null,
  "started_at": "<ISO>", "ended_at": "<ISO>" | null
} }
```

`GET /api/jobs/<id>/stream` — EventSource-compatible SSE tail of the job's
log: a `retry: 1500` line first, then one `data: <JobEvent>` frame per
event, polling while the job is non-terminal, then `event: end` +
`data: {}` and close. An unknown id streams a single `failed` event then
`end`. Events:

```jsonc
{ "type": "started", "ts": 0 }
{ "type": "log", "line": "…" }
{ "type": "stage", "stage": "…", "progress": 0.5, "message": "…" }
{ "type": "metric", "kind": "train" | "val", "step": 0, "loss": 0.0 }   // + grad_norm, learning_rate, tokens_per_sec, …
{ "type": "done", "ts": 0, "output_dir": "…", "summary": { } }
{ "type": "failed", "error": "…", "ts": 0 }
```

## Fine-tune (`/api/finetune/*`)

The HTTP entry point to LoRA training (`src/serve/lab-routes.ts` →
`src/train/job.ts`). It runs the same runner the CLI's `mlx-bun train`
drives, as a subprocess job (crash isolation + one GPU lease across
concurrent server requests). Data formats, every config knob, and the
methodology are in [training.md](./training.md); this section is the wire
shape.

`POST /api/finetune/submit` — body is `FinetuneSubmit` (`src/train/job.ts`).
`model_dir` and `data_dir` are required at the route (`400 "model_dir and
data_dir required"`); `adapter_path` defaults to
`~/.cache/mlx-bun/adapters/adapter-<timestamp>` when omitted. Everything
else is optional and falls back to `DEFAULT_TRAIN_CONFIG`:

```jsonc
{
  "model_dir": "/path/to/snapshot",       // required
  "data_dir": "/path/to/dataset",         // required: train.jsonl (+ optional valid.jsonl)
  "adapter_path": "/path/to/output",      // optional (default above)
  "method": "sft" | "dpo" | "orpo",
  "rank": 16, "scale": 20, "rank_scaling": "…", "target_modules": ["…"], "num_layers": 0,
  "iters": 300, "learning_rate": 2e-4, "max_seq_length": 2048, "batch_size": 1,
  "grad_accumulation_steps": 1, "seed": 0, "steps_per_report": 1, "steps_per_eval": 0,
  "weight_decay": 0.0, "lora_dropout": 0.0, "rs_lora": false, "lora_plus_ratio": 1,
  "grad_checkpoint": false, "mlp_split": false, "segment_size": 0,
  "save_checkpoints": true, "grad_clip_norm": 0, "val_max_examples": 0,
  "dpo_beta": 0.1, "dpo_warmup_iters": 0, "dpo_lr_schedule": "constant" | "cosine",
  "orpo_lambda": 0.1, "orpo_warmup_iters": 0, "orpo_lr_schedule": "constant" | "cosine",
  "orpo_chunk_size": 0, "orpo_fused_ce": true, "orpo_flash_ce": true, "orpo_prefix_shared": true,
  "sft_scope": "full" | "response",
  "warm_start_adapter": "/path/to/adapter"
}
```

Response: `{ "ok": true, "job_id": "…", "adapter_path": "…" }`. Then
follow `GET /api/jobs/<job_id>/stream` for `metric` events (`kind:
"train"|"val"`, `step`, `loss`, …) and the terminal `done`/`failed`.
Config validation errors (an invalid `sft_scope`, a missing `adapter_path`
at the runner) surface as the job's `failed` event, not as a `4xx`.

```bash
curl -s localhost:8080/api/finetune/submit -X POST -H 'content-type: application/json' -d '{
  "model_dir": "/path/to/snapshot", "data_dir": "/path/to/dataset",
  "adapter_path": "/path/to/output-adapter",
  "method": "sft", "rank": 16, "iters": 300, "learning_rate": 2e-4, "max_seq_length": 2048
}'
# → {"ok":true,"job_id":"…","adapter_path":"/path/to/output-adapter"}
curl -N localhost:8080/api/jobs/<job_id>/stream
```

`POST /api/finetune/inspect-dataset` with `{"path": "<data_dir>"}` — probe
a dataset directory before submitting: `{ "ok": true, "n_train": N,
"n_valid": N, "format": "messages" | "prompt-completion" | "text" | "dpo" |
"unknown" }`, or `{ "ok": false, …, "error": "<train.jsonl> not found" }`
(HTTP 200 either way).

`POST /api/finetune/merge` with `{"adapter_a": "/dir", "adapter_b":
"/dir", "scales"?: [a, b]}` — fold two adapters into one (`mergeAdapters`
in `src/train/merge.ts`; per-source scales default to each adapter's own
config). Output goes to `~/.cache/mlx-bun/adapters/merged-<timestamp>`:
`{ "ok": true, "merged_path": "…", "stats": { "layersMerged", "layersOnlyInOne",
"totalKeysOut", "sources", "scales" } }`; `400 { "ok": false, "error" }` on
a missing field or merge failure.

`POST /api/finetune/export` with `{"base_model": "…", "adapter_path":
"/dir", "method"?: "…"}` — writes a `manifest.json` describing the adapter
into `~/.cache/mlx-bun/exports/export-<timestamp>`:
`{ "ok": true, "export_path": "…", "manifest": { "version": 1, "base_model",
"adapter_path", "method"?, "created_at" } }`; `400` on a missing field.

## Quantize (`/api/quantize/*`)

`POST /api/quantize/inspect` with `{"model_id": "<repo id | path>"}` —
resolve a model through the registry and report whether the quantizer can
walk it (`inspectModel`, `src/quantize/job.ts`): `{ "ok": true, "model_id",
"arch": "<model_type>" | null, "support": true, "size_gb": 0.0 }`, or
`{ "ok": false, …, "error" }` (HTTP 200 either way).

`POST /api/quantize/submit` — starts a quantize job whose output lands in
the HF hub cache as a synthetic repo `<org>/<name>-OptiQ-<suffix>`
(`refs/main` written so the registry picks it up; `<suffix>` is
`<bits>bit` or `mixed-<target_bpw>bpw`, plus `-rot<seed>` when rotating):

```jsonc
{
  "model_id": "org/name | /path",   // required (400 "model_id required")
  "bits": 4, "group_size": 64,
  "target_bpw": 3.5,                // mixed-precision target; wins over bits in the name
  "candidate_bits": [2, 3, 4, 8],
  "reference": "…", "calibration_mix": "…", "n_calibration": 0,
  "rotate_weights": false, "rotation_seed": 42
}
```

Response: `{ "ok": true, "job_id": "…", "output_dir": "…" }`. The library
cache is invalidated when the job completes.

`POST /api/quantize/resolve-folder` and `POST /api/model/resolve-folder`
(same handler) with `{"folder_name"?: "…", "rel_path"?: "…"}` — turn a
folder the browser picked (a `models--org--name` hub dir, a snapshot hash
dir, or a bare model dir under the hub cache / `~/.cache/mlx-bun`) into a
servable path: `{ "ok": true, "path": "…", "repo_id"?: "…", "model_type"?:
"…" }`, or `{ "ok": false, "error": "Couldn't locate this folder on disk —
paste the path instead." }` (HTTP 200).

## Dataset (`/api/dataset/*`)

`GET /api/dataset/templates` — the dataset-builder template registry
(`src/dataset/registry.ts`): `{ "templates": [{ "id", "label",
"description", "output_format": "messages" | "prompt_completion" | "dpo" |
"text", "needs_llm": bool, "fields": [{ "name", "type": "text" | "textarea" |
"number", "label", "hint"?, "required"?, "default"? }] }] }`.

`POST /api/dataset/submit` with `{"template_id": "…", "inputs": {…},
"model_name"?: "…"}` — runs the template in-process as a job; LLM-backed
templates call back into this server's own `/v1` (`api_url` =
`http://127.0.0.1:<port>`). Output dir is
`~/.cache/mlx-bun/datasets/dataset-<template>-<timestamp>`. Response:
`{ "ok": true, "job_id": "…", "output_dir": "…" }`; `400 { "ok": false,
"error": "unknown template …" }` for an unknown id.

## POST /api/{quantize,finetune,dataset}/push

Upload a job's output (or any folder) to the Hugging Face Hub with the
saved write token (`src/hf-push.ts`). Body: `{"repo_id": "org/name",
"job_id"?: "…", "source_path"?: "/dir", "private"?: false}` — `repo_id` is
required; the source is `source_path`, else the job's `output_path`. The
`dataset` variant pushes as a dataset repo, the others as model repos.
Response `{ "ok": true, "url": "…" }`; `400 { "ok": false, "error" }` when
no token is saved, no source directory resolves, or the upload fails.

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
Memory panel — same loopback-only admin-route posture as `/api/gc/*`, no
separate auth. Handlers live in `src/memory/rest.ts`; they never touch the
agent-tool surface (`src/memory/tools.ts`), which stays read-only. Every
route below degrades gracefully — a missing vault, an unknown article, or
a bad param returns `{ "ok": false, ... }` (with an appropriate HTTP
status), never a 500.

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
wraps `searchArticles` (`limit` capped at 200; `400` without `q`); same
summaries/hits shape the `memory_search` tool formats from:

```jsonc
{ "ok": true, "summaries": [{ "article": "…", "occurrences": 3, "matched_terms": ["…"] }], "hits": [{ "article": "…", "anchor": "…", "line": 10, "excerpt": "…" }] }
```

`GET /api/memory/article?name=<article>` — rendered source plus the
deterministic metadata the panel needs (infobox, lead, series banner,
section skeleton); `404 { "ok": false }` for an unknown name:

```jsonc
{ "ok": true, "name": "…", "path": "…", "content": "# …", "infobox": { "type": "…", "entityKind": "thing", "fields": [] }, "lead": "…", "series": null, "structure": [] }
```

`GET /api/memory/links?name=<article>` — inbound/outbound wikilinks (same
data `memory_links` resolves); articles only, not `Reference/*`:

```jsonc
{ "ok": true, "name": "…", "outbound": ["…"], "inbound": ["…"] }
```

`GET /api/memory/history?name=<article>&limit=50` — the article's git log
(read-only `git log` plumbing on the vault's own repo, via `Bun.spawn` —
never a shell string; `limit` capped at 200):

```jsonc
{ "ok": true, "name": "…", "isGitRepo": true, "entries": [{ "hash": "…", "date": "YYYY-MM-DD", "subject": "…" }] }
```

`GET /api/memory/diff?name=<article>&rev=<hash>` — that commit's diff for
the article (`git show <rev> -- <path>`). `rev` must match
`/^[0-9a-f]{4,40}$/` (a bare commit hash — never a ref expression like
`HEAD~1`) or the request 400s before touching git; an unknown `name` or a
revision with no diff for it 404s:

```jsonc
{ "ok": true, "name": "…", "rev": "…", "diff": "diff --git a/articles/…" }
```

`POST /api/memory/init` with optional body `{"path"?: string}` — the
first-run consent-card backend. Delegates to the same `setupVault()` the
CLI's `mlx-bun memory init` calls (idempotent: create dirs, write README +
Meta pages only if missing, git init + initial commit); omits the CLI's
interactive extras. `path`, if given, must resolve under the default vault
root or the OS temp directory, else `400`:

```jsonc
{ "ok": true, "result": { "root": "…", "created": ["…"], "gitInitialized": true, "alreadySetUp": false }, "status": { "root": "…", "exists": true, "articleCount": 0, "referenceCount": 9, "isGitRepo": true, "recentArticles": [] } }
```

## GET /v1/memory/synthesize

Runs the memory synthesis pipeline (`runSynthesis`, `src/memory/pipeline.ts`
— the same job `mlx-bun memory synthesize` runs) and streams its progress
as SSE. `?dry=1` plans the stages without model calls or writes. This is a
long GPU job over the whole store on a real run; it is registered under
`/v1/` for historical reasons and is not part of the OpenAI surface.

```
data: {"type":"stage","stage":"ingest","message":"…"}
data: {"type":"log","message":"…"}
data: {"type":"done","message":"synthesis done — …"}
data: {"type":"summary","implemented":true,"stages":["ingest","segment","extract","route","create","section-route","patch","link","wikify"],"note":"…"}
data: [DONE]
```

A failure emits `data: {"type":"error","message":"…"}` and closes without
`[DONE]`.

## Settings (`/api/settings/*`)

`GET /api/settings/hf-token` → `{ "ok": true, "hasToken": bool }`;
`POST /api/settings/hf-token` with `{"token": "hf_…"}` saves the Hugging
Face write token to `~/.mlx-bun/hf.json` (mode 0600) →
`{ "ok": true }`; `400 "token required"` when empty. The token drives the
push routes above and the `upload` CLI command ([cli.md](./cli.md)).

`GET /api/settings/tool-approvals` / `DELETE /api/settings/tool-approvals`
— the web chat's durable "always allow this tool" list for gated tools
(`bash`/`edit`/`write`), backed by `~/.mlx-bun/tool-approvals.json`
(`src/tool-approvals.ts`), keyed by stable tool NAME, not per-call
arguments. These two routes are read/forget only: granting an always-allow
happens through the approval card itself (the `approval` WS frame on
`/ws/chat` with `alwaysAllow: true`), never a bare settings POST.

```jsonc
// GET
{ "ok": true, "alwaysAllow": ["bash", "edit"] }
// DELETE with body {"tool": "bash"} — idempotent; returns the updated set
{ "ok": true, "alwaysAllow": ["edit"] }
```

`DELETE` without `tool` is `400 "tool required"`.

## Model Hub (`/api/hub/*`)

The web chat's Model Hub panel: browse downloaded models, search Hugging
Face, and kick off downloads — all loopback-served, no separate auth.
Handlers live in `src/hub-rest.ts` (pure functions, no loaded-model
dependency).

`GET /api/hub/local` — every model in the local registry (same source
`/library` reads), each with a `/fit`-computed hardware verdict at a fixed
8k context:

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
filtered to the `mlx` library tag so results are MLX-compatible by
construction. Never downloads anything. `400` without `q`. Degrades on any
network failure (DNS, timeout, non-2xx) to an explicit offline state
rather than a 500:

```jsonc
{ "ok": true, "offline": false, "results": [{ "id": "mlx-community/…", "downloads": 0, "likes": 0, "size_estimate": null }] }
```

```jsonc
{ "ok": true, "offline": true, "error": "…", "results": [] }
```

`size_estimate` is always `null` — the search endpoint doesn't return
per-repo file sizes; the fit badge lands once a model is actually
downloaded (`/api/hub/local`).

`POST /api/hub/download` with body `{"repo": "org/name"}` — starts a
background download via `downloadModel()` and returns immediately;
progress is visible via [`GET /downloads`](#get-downloads). Refuses a
duplicate kick-off for a repo that's already downloading:

```jsonc
{ "ok": true, "repo": "org/name", "started": true }
```

```jsonc
{ "ok": false, "error": "a download for org/name is already in progress" }   // 409
```

`POST /api/hub/serve` with body `{"model": "org/name"}` — **always answers
`restart_required`, never performs a live in-process swap.** The process a
web chat session is attached to has exactly one model loaded and no
drop-weights-and-reload seam reachable from `/ws/chat` (the `--isolate`
proxy's `ModelPool` is a real spawn-overlap swap, but it lives on the
isolated `/v1/*` surface only — `src/serve/isolate.ts`). The honest answer
is the restart command (HTTP 200, `ok: false`):

```jsonc
{ "ok": false, "restart_required": true, "command": "mlx-bun serve org/name" }
```

## GET /api/sessions/search · GET /api/sessions/export

Full-text search across web-chat session message **bodies** and chat
export. Same loopback-only, no-separate-auth posture as `/api/memory/*`.
Handlers live in `src/serve/session-search.ts` (pure, read-only, no
loaded-model dependency). Both routes read the same session directory the
web chat's `PiWebSession` writes to (`~/.mlx-bun/sessions`, pi's own
JSONL-per-session format) and are JSONL-tolerant — a corrupt or mid-write
line is skipped, never thrown.

`GET /api/sessions/search?q=<query>` — case-insensitive substring scan (no
index — personal-chat-corpus scale) over every session file's
user/assistant message text, capped at 50 matches total (10 per session).
Each match reports a plain-text ±60-char snippet plus the match's own
`[start,end)` offsets **into that snippet** — offsets, not pre-rendered
HTML, so the frontend escapes the snippet then inserts its own `<mark>`:

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
parsed into an array of entries (one per line, in file order). `path` must
resolve under the session directory:

```jsonc
{ "ok": true, "path": "…", "entries": [{ "type": "session", "id": "…", "cwd": "…" }, { "type": "message", "message": { "role": "user", "content": "…" } }] }
```

400s without `path`; 403s a `path` outside the session directory; 404s a
path inside the directory that doesn't exist on disk.

## Web app static routes + PWA installability

The web chat (`GET /`) and everything it loads same-origin, no CDN, ever
(`src/serve/static-routes.ts`; GET only):

| Route | Content | Notes |
| --- | --- | --- |
| `GET /` | `src/web/app.html` | The unified SPA shell. |
| `GET /assets/app.js` | `src/web/app.js` | GENERATED from `src/web/src/*.ts` by `bun scripts/build-web.ts` — see `tests/web-build.test.ts`'s freshness gate. |
| `GET /assets/hljs.js`, `GET /assets/hljs.css` | `src/web/vendor/hljs*` | Vendored syntax highlighting, no CDN. |
| `GET /manifest.webmanifest` | `src/web/manifest.webmanifest` | PWA manifest. |
| `GET /assets/icon.svg` | `src/web/icon.svg` | A single inline SVG app icon; no binary PNGs are shipped. |
| `GET /sw.js` | `src/web/sw.js` | Service worker, served `cache-control: no-store` at the root scope. |
| `GET /curves` | `src/assets/curve-designer.html` | The HLG Curve Designer page (drives `/signal` + `/generate` below); read from disk when available, embedded copy in compiled binaries. `no-store`. |
| `GET /curve-terrain` | `src/serve/assets/curve-terrain.html` | Curve terrain visualization; `404` when the artifact isn't on disk. |
| `GET /dag` | `src/serve/assets/training-inference-map.html` | Training/inference DAG map; `404` when the artifact isn't on disk. |
| `GET /status`, `/chat`, `/quantize`, `/finetune`, `/dataset` | — | Legacy page paths: `302` to `/#<path>` (the SPA's hash routes). |

`/assets/*` and the manifest are served with `cache-control: public,
max-age=3600`; `/sw.js`, `/curves`, `/curve-terrain`, `/dag` are `no-store`.

**PWA scope:** the manifest + service worker exist for *installability and
an instant static-shell paint* — "Add to Home Screen" / a browser "Install
app" prompt, and the next visit's HTML/JS/CSS loading from cache while the
WebSocket connects. This is explicitly **not** offline chat:
`src/web/sw.js`'s fetch handler only intercepts the exact shell files
(`/`, `/assets/app.js`, `/assets/hljs.js`, `/assets/hljs.css`) and lets
every dynamic route (`/api/*`, `/v1/*`, `/ws/chat`, `/downloads`, …) fall
straight through to the network unconditionally. Registration is guarded
to secure contexts (`https:` or `localhost`/`127.0.0.1`).

## Curve Designer: POST /signal · POST /generate

Backends for the `/curves` page (HLG tone-curve sampling research tool,
`src/curve-sampler.ts`). Both answer `OPTIONS` and send permissive CORS
headers (`access-control-allow-origin: *`) so the page can be opened from
a file or another origin. Both take the GPU lock (`gateway.runExclusive`)
— they never interleave with a serving request.

`POST /signal` with `{"prompt": "…"}` — one prefill forward of the prompt
rendered as a single user turn; bins the next-token log-prob distribution
into 80 buckets over the curve's x-axis so the editor can draw the signal
under the curve: `{ "bins": [80 ints], "vocab": V }`. `400 {"error":
"invalid JSON"}`; `500 {"error": "signal failed: …"}`.

`POST /generate` with `{"prompt", "curve"?: {points: [...]}, "n"?: 3,
"max_tokens"?: 80, "seed"?: 0, "default"?: false}` — samples `n` (1–8)
completions of up to `max_tokens` (1–256) tokens. When `curve` has ≥2
points and `default` is not `true`, the drawn log-prob transfer curve
replaces temperature+softmax entirely; otherwise the model's default chat
recipe (temperature/top-p/top-k) is used. A non-monotone curve is a `400`.

```jsonc
{ "mode": "curve" | "default",
  "recipe": { "temperature": 0.7, "topP": 0, "topK": 0 },   // only in default mode
  "n": 3, "seed": 0,
  "samples": [{ "text": "…", "junk": false }] }             // junk = coherence heuristic tripped
```

## Web chat WebSocket (`/ws/chat`)

`GET /ws/chat` upgrades to a WebSocket (`426` when the upgrade header is
missing; `501` under `--isolate`). It carries the web chat's pi
`AgentSession` — the model is driven through pi, which calls back into
this server's own loopback `/v1`. Frames are JSON objects with a `type`
field; the exact TypeScript unions are `ClientMessage` and `ServerMessage`
in `src/pi-web.ts` (the web frontend imports them type-only, so both ends
are compile-checked).

Client → server: `prompt {text, images?: [{data, mimeType}]}`, `abort`,
`approval {callId, decision, editedArgs?, alwaysAllow?}`, `set_thinking
{enabled}`, `set_coding_tools {enabled}`, `set_adapter {id | null}`,
`set_sampling {scope?: "session" | "next_turn", temperature?, top_p?,
top_k?, min_p?, xtc_probability?, xtc_threshold?, repetition_penalty?,
repetition_context_size?, presence_penalty?, frequency_penalty?, seed?}`
(null = server default), `set_system_prompt {text | null}`, `new_session`,
`list_sessions`, `open_session {path}`, `fork_session {path}`,
`delete_session {path}`, `regenerate`, `edit_resend {text}`,
`switch_sibling {entryId}`, `context {context}` (app-aware assistant, below).

Server → client: `ready {model, vision, audio, thinking, genDefaults}`,
`turn_start`, `text_delta {delta}`, `thinking_delta {delta}`, `tool_start
{callId, tool, args}`, `tool_approval_request {callId, tool, args}`,
`tool_update {callId, chunk}`, `tool_end {callId, ok, result}`, `turn_end
{lane?}` (the serving lane the turn ran on, from `usage.lane` via the lane
registry — never guessed client-side), `queue_update {steering, followUp}`,
`history {items}`, `sessions {items, activePath?}`, `siblings {entryId?,
index, count, siblingIds}`, `context {tokens, contextWindow, percent}`
(context-window usage — a different frame from the client→server
`context`), `coding_tools {active, pending}`, `tool_approvals
{alwaysAllow}`, `ui_navigate {route}`, `ui_spotlight {ref?, label?,
selector?, target?, message?, route?}`, `error {message}`.

### App-aware assistant

The web chat agent can see and act on the app it lives in. No screenshots
and no vision model are involved: the browser sends a structured DOM
snapshot as a WS frame, and the model gets three tools that
read/navigate/highlight that snapshot. The three tools are always in the
web chat's tool allowlist (read-only-on-the-machine, never gated by the
approval card; `APP_AWARE_TOOL_NAMES` in `src/pi-web.ts`):

- **`get_current_app_context`** — returns the last context the browser
  pushed: `{ route, view?, step?, snapshot }`. `snapshot` is a capped
  (~120) list of visible interactive elements as `{ref, label, kind,
  role?, selector, spotlightId?}`, agent chrome excluded.
- **`navigate_app({ route | page })`** — validates against the route
  catalog (`APP_ROUTE_IDS`: `chat`, `quantize`, `finetune`, `dataset`,
  `status`; unknown routes are a tool error, never sent to the browser)
  and emits a `ui_navigate` frame.
- **`spotlight_ui({ ref | label | selector | target, route?, message? })`**
  — emits a `ui_spotlight` frame; the browser resolves the target (ref
  from its last snapshot, then live selector, then fuzzy label match, then
  a curated catalog id) and shows a brief non-blocking highlight.

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
never a full snapshot dump. Approval-gated form-fill / job-start actions
are not wired; only navigate/spotlight are.

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
