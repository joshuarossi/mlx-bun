---
title: How it compares
description: mlx-bun's integration choices and reference implementations.
---

mlx-bun uses [MLX](https://github.com/ml-explore/mlx) through
[mlx-c](https://github.com/ml-explore/mlx-c). It brings model execution and
serving into Bun so TypeScript applications can integrate inference directly
or distribute a local executable.

[mlx-lm](https://github.com/ml-explore/mlx-lm) and
[mlx-optiq](https://mlx-optiq.com/) supply reference implementations for the
project's numerical comparisons. Their documentation describes their current
capabilities. mlx-bun's supported subset and extensions are documented in
its [model roster](/reference/models/).

## Choosing an integration

Use the [library API](/guides/library/) for direct Bun integration, an isolated
host for a desktop application's local worker, or the
[HTTP API](/reference/server-api/) for clients in another runtime. Protocol
compatibility covers the documented routes and fields; it does not promise
every feature of a hosted provider.

Continuous batching, speculative methods, quantized cache layouts, and
RAM/SSD reuse compose where the model implementation supports them. The
[configuration reference](/reference/server-config/) records those combinations
and the explicit serial option. Training and model conversion have separate
[training](/reference/training/) and [CLI](/reference/cli/) documentation.

## Compare evidence for your workload

The [benchmark ledger](/reference/benchmarks/) records complete requests,
startup, prefill, decode, cache reuse, and concurrent throughput. Read each
result with its machine, artifact, settings, and limits. A win on one workload
does not imply a win on every model or context length.

The [correctness contract](/about/correctness/) distinguishes stock mlx-lm
parity, mlx-optiq extensions, and experimental methods. Quantizing a cache
changes the computation; the appropriate oracle is the matching scheme.
