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
options, including how to keep the browser from opening. Use `get`,
`scan`, `ls`, and `fit` to acquire and inspect cached models.

```sh
mlx-bun get mlx-community/gemma-4-e4b-it-OptiQ-4bit
mlx-bun serve e4b
curl http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages": [{"role": "user", "content": "Hello!"}], "max_tokens": 128}'
```

The app offers chat completions, text completions, Anthropic Messages, OpenAI
Responses, and embeddings when the loaded model supports them; the
[HTTP API reference](/reference/server-api/) lists every route. The
[app guide](https://github.com/joshuarossi/mlx-bun/blob/main/apps/mlx-bun/README.md)
explains the interfaces and their limits. A loaded graph does not imply
that every modality or serving combination is supported.

Continuous batching is the serving default, including for one request.
Generation can be stopped and chats reopened in the browser. For a single
generation without a server, use `mlx-bun generate e4b "Hello!"`.

For code you can run and adapt, use the [library examples](/guides/library/).
