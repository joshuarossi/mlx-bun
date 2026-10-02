---
title: Using the libraries
description: Choose the component you need and start from an executable example.
---

The caller owns the model, inputs, and resource lifetime. The high-level
inference entry composes lower layers; public component subpaths let you use
kernels, layers, graphs, state, and generation independently.

- [MLX bindings](https://github.com/joshuarossi/mlx-bun/blob/main/packages/mlx/README.md): arrays, operations, native resource ownership.
- [Inference](https://github.com/joshuarossi/mlx-bun/blob/main/packages/inference/README.md): graphs, loading, preprocessing, generation, reusable execution, and memory fit estimates.
- [Quantization](https://github.com/joshuarossi/mlx-bun/blob/main/packages/quantize/README.md): checkpoint conversion and allocation.
- [Training](https://github.com/joshuarossi/mlx-bun/blob/main/packages/training/README.md): adapter training and production.
- [Hub](https://github.com/joshuarossi/mlx-bun/blob/main/packages/hub/README.md): model acquisition and discovery.

Start from the tested [array example](https://github.com/joshuarossi/mlx-bun/blob/main/packages/mlx/examples/arrays.ts)
or [Qwen generation example](https://github.com/joshuarossi/mlx-bun/blob/main/packages/inference/examples/qwen3-generate.ts).
The package READMEs explain their inputs and how to run them. These links point
to the executable source instead of maintaining another copy of the code here.

The libraries are published to npm under `@mlx-bun/`; install the one you need,
for example `bun add @mlx-bun/inference`. They require Bun 1.4.2 or later on an
Apple Silicon Mac; native libraries ship inside the package archives.

The [generated library API](/api/) lists every public package subpath, resolved
exports, signatures, and API comments. Start at a package root for high-level
entry points, or choose a component subpath for lower-level composition. Source
links lead to the owning implementation. Ownership and disposal obligations
belong in those API comments; the reference includes only what the code documents.
