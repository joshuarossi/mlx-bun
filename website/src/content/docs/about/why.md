---
title: Why mlx-bun
description: Local MLX inference inside a TypeScript application.
---

mlx-bun lets a TypeScript application run MLX inference in a Bun process.
It uses MLX's C API through `bun:ffi`, so the application can load a model,
generate tokens, and serve requests without a separate Python service.

[MLX](https://github.com/ml-explore/mlx),
[mlx-c](https://github.com/ml-explore/mlx-c), and
[mlx-lm](https://github.com/ml-explore/mlx-lm) make this possible. mlx-lm
and mlx-optiq also provide the reference implementations used in the
project's numerical tests.

## Why Bun

Bun supplies the runtime, FFI, package manager, and test runner. Its native
image codecs support the vision input path, and built-in SQLite supports
the registry and evaluation database. The CLI can ship with Bun and the MLX
runtime in a signed, notarized bundle.

For application developers, the useful choice is how to integrate: call the
[TypeScript library](/guides/library/) in-process, embed the executable as a
local worker, or use the [HTTP API](/reference/server-api/) from another runtime.

## Where performance comes from

Native kernels do the tensor computation. Model execution, scheduling,
sampling, and cache reuse determine how much work reaches those kernels
and when. Those decisions affect latency, memory use, and throughput.

mlx-bun develops specialized kernels and shared execution interfaces so each
part can improve independently. The [benchmark ledger](/reference/benchmarks/)
records the measured results and regressions. The
[correctness contract](/about/correctness/) defines the comparisons those
optimizations must preserve.
