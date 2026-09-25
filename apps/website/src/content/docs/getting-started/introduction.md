---
title: Introduction
description: An app for local AI and composable libraries for developers.
---

The current target is Apple Silicon Macs. Model execution runs locally through
MLX and Metal. Downloading models and publishing artifacts use Hugging Face;
local inference does not require a hosted-model API key or a Python service.

For app users, `mlx-bun` starts the terminal application, server, and browser
chat. For developers, the `@mlx-bun/` libraries offer both convenient loading
and generation and lower-level components you can compose yourself. An
inference library does not select a global model or run a server for you.

The new repository uses Bun workspaces: applications live in `apps/`, libraries
in `packages/`. See the [architecture](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/ARCHITECTURE.md)
for ownership and dependency direction.

Start with [installation](/getting-started/installation/) or the
[library guide](/guides/library/).
