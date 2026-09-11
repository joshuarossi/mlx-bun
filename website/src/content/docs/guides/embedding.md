---
title: Embedding in a Mac app
description: Integrate mlx-bun in-process or as a local worker.
---

Bun applications can use the [library API](/guides/library/) directly.
Desktop applications can embed the executable and communicate through an
isolated host or the [HTTP API](/reference/server-api/).

The [distribution guide](/guides/distribution/) owns the bundle contents,
native runtime resolution, signing, and notarization instructions. Keep the
complete bundle together when including it in an application.

For text-vector embeddings, see the
[embeddings API](/reference/server-api/#post-v1embeddings-openai-embeddings-api)
and [library methods](/guides/library/#text-embeddings).
