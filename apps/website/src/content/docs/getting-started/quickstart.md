---
title: Quickstart
description: Start the app, choose a model, and find its interfaces.
---

After [installation](/getting-started/installation/), run `mlx-bun`. It selects
an appropriate cached model and starts the local server and browser chat. When
no supported model is cached, startup downloads a starter and may download a
recommended model in the background. These downloads require internet access.

To choose explicitly, use `mlx-bun serve` with a cached model query or a local
model directory. The [generated CLI reference](/reference/cli/#serve) lists the
current options, including how to keep the browser from opening. Use `get`,
`scan`, `ls`, and `fit` to acquire and inspect cached models.

The app offers chat completions, text completions, Anthropic Messages, OpenAI
Responses, and embeddings when the loaded model supports them. Its current
[app guide](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/apps/mlx-bun/README.md)
explains the migrated interfaces and limitations. A loaded graph does not imply
that every modality or serving combination is already supported.

Continuous batching is the serving default, including for one request.
Generation can be stopped and chats reopened in the browser. Audio, memory
synthesis, and other remaining app work are tracked in the
[refactor plan](https://github.com/joshuarossi/mlx-bun/blob/refactor/monorepo/PLAN.md).

For code you can run and adapt, use the [library examples](/guides/library/).
