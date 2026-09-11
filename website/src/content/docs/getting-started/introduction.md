---
title: Introduction
description: Native MLX inference, a local chat app, and a TypeScript library.
---

mlx-bun runs local models on Apple Silicon through MLX. It includes a browser
chat app, an OpenAI/Anthropic-compatible HTTP server, and a TypeScript library
for embedding inference in Bun applications. The signed executable includes
its runtime; inference does not require Python.

The server uses continuous batching for eligible requests. Model execution,
sampling, scheduling, and cache storage have separate responsibilities,
including when only one request is active. See
[server configuration](/reference/server-config/) for supported combinations.

## Choose your starting point

- Use local chat: follow [installation](/getting-started/installation/) and
  the [quickstart](/getting-started/quickstart/).
- Build an application: read the [library API](/guides/library/) or
  [HTTP API](/reference/server-api/).
- Evaluate the engine: inspect the [correctness contract](/about/correctness/)
  and [measured comparisons](/reference/benchmarks/).

## Supported environment

The native engine requires an Apple Silicon Mac running macOS 14 or later.
Source and npm usage require Bun; the standalone bundle includes it.
Use the [model roster](/reference/models/) for validated architectures and
artifact formats. Compatibility depends on the exact model and configuration.
