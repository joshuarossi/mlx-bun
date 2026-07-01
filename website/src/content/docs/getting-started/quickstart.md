---
title: Quickstart
description: From install to your first local chat and API call in a couple of minutes.
---

This assumes you've [installed mlx-bun](/getting-started/installation/). Commands
below use `mlx-bun`; from a clone, the identical command is `bun src/cli.ts <verb>`.

## 1. Just run it

```sh
mlx-bun
```

Bare `mlx-bun` is an alias for `mlx-bun serve`. On a fresh machine it pulls the
MLX runtime (if not bundled), downloads the sub-GB `MiniCPM5-1B` starter, serves
it, and opens the chat UI at `http://localhost:8080/#/chat`. You're chatting in
under a minute.

Pass `--no-open` to skip launching the browser.

## 2. Pick a specific model

Name a model and mlx-bun substring-matches it against your downloaded models:

```sh
mlx-bun serve e4b --port 8080
```

Don't have it yet? Grab it first (resumable, checksum-verified):

```sh
mlx-bun get mlx-community/gemma-4-e4b-it-OptiQ-4bit
mlx-bun scan          # index your HF cache into the registry
mlx-bun ls            # list models with size, params, quant, capabilities
```

Not sure what fits your Mac? `fit` gives a deterministic answer:

```sh
mlx-bun fit gemma --ctx 8192
```

See [Choosing a model](/getting-started/models/) for the full list.

## 3. Call the API

The server is OpenAI-compatible — any OpenAI client works. The request's
`model` field is ignored; the loaded model is served and echoed back.

```sh
curl http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 128, "temperature": 0.7
  }'
```

Or with the OpenAI SDK — point `baseURL` at the server and use any non-empty
`apiKey`:

```ts
import OpenAI from "openai";
const client = new OpenAI({ baseURL: "http://localhost:8080/v1", apiKey: "local" });

const res = await client.chat.completions.create({
  model: "local",
  messages: [{ role: "user", content: "Hello!" }],
});
console.log(res.choices[0].message.content);
```

## Where to next

- [The HTTP API](/guides/http-api/) — tools, vision, prompt caching, LoRA,
  Anthropic and Responses protocols.
- [Using the library](/guides/library/) — drive generation directly in a Bun
  process, no server.
- [CLI reference](/reference/cli/) — every verb.
