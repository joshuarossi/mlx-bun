---
title: Introduction
description: What mlx-bun is, why it runs locally, and where to start.
---

mlx-bun is local AI for Apple Silicon Macs: an MLX inference engine, an
OpenAI, Anthropic and Responses compatible server, a browser app, and
TypeScript libraries you can embed in your own Bun applications. Model
execution runs on the Mac's GPU through MLX and Metal, with the Neural Engine
programs a model uses compiled at install. Models download from Hugging Face;
inference needs no Python service and no hosted-model API key.

## What you get

- **The app.** `mlx-bun` downloads models, serves them, generates once,
  embeds, quantizes, fine-tunes and transcribes. The
  [CLI reference](/reference/cli/) lists every command and flag.
- **The server.** Chat and text completions, Anthropic Messages, OpenAI
  Responses, embeddings, audio transcriptions and the Decisions API on
  `localhost:8080`, over one continuous batching scheduler. The
  [HTTP API reference](/reference/server-api/) lists every route.
- **The browser app.** Chat with tools and saved sessions, model management,
  transcription, quantization, training, dataset generation, metrics and
  benchmarks, served by the same process.
- **The libraries.** The `@mlx-bun/` packages offer convenient loading and
  generation and the lower-level kernels, layers, graphs, state, sampling,
  quantization and training they compose. A library never selects a global
  model or starts a server for you.

## Why mlx-bun

- **Correctness first.** Validated configurations are bit-exact with mlx-lm,
  and with mlx-optiq for mixed-precision KV. The
  [correctness page](/about/correctness/) states the contract, its evidence,
  and what it does not cover.
- **Drop-in.** Existing OpenAI and Anthropic SDKs, agents and tools work by
  changing one URL; request and response formats are preserved.
- **Decisions, locally.** `POST /v1/decisions` replaces OpenAI's Decisions API
  and `POST /v1/systemone` accepts Jev's System One format, returning typed
  answers with probabilities and confidence from the model that serves chat.
- **Composable.** Public component subpaths let you use kernels, layers,
  graphs, state and generation independently, and `mlx-bun/server` embeds the
  whole app in your process.
- **Private by default.** Models, adapters, chats and caches stay on your Mac
  under `~/.mlx-bun`; nothing is sent anywhere unless you ask.

The repository uses Bun workspaces: applications live in `apps/`, libraries
in `packages/`. See the [architecture](https://github.com/joshuarossi/mlx-bun/blob/main/ARCHITECTURE.md)
for ownership and dependency direction.

## Where next

Start with [installation](/getting-started/installation/) and the
[quickstart](/getting-started/quickstart/), or go straight to the
[library guide](/guides/library/).
