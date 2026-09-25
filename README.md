# mlx-bun

Provide and enable the best local AI experience on Apple Silicon, through
applications people can run and libraries developers can embed in their own apps.

The current target is Apple Silicon Macs. This branch is rebuilding mlx-bun
as a Bun workspace. The migrated library includes the MLX bindings, inference kernels, model graphs,
artifact/input readers, state, sampling, generation, embeddings, transcription,
and optional in-process execution.

## Repository layout

- `apps/` — applications you run.
- `packages/` — libraries you import, published under `@mlx-bun/`.

[`@mlx-bun/mlx`](packages/mlx/README.md) owns the native MLX bindings.
[`@mlx-bun/inference`](packages/inference/README.md) owns inference graphs, kernels, layers, input processing, and state.
[`@mlx-bun/quantize`](packages/quantize/README.md) owns checkpoint quantization: calibration, sensitivity, mixed-precision allocation, rotation, and Trellis packing.
[`@mlx-bun/hub`](packages/hub/README.md) owns the local model registry, Hugging Face downloads, and memory fit.
`apps/` will be created with its first application.
See [the library architecture](ARCHITECTURE.md) for ownership, contracts, and dependency rules.
Remaining migration work is in [PLAN.md](PLAN.md).
See [CONTRIBUTING.md](CONTRIBUTING.md) for verification and review expectations;
agents start at [AGENTS.md](AGENTS.md).

## Using the app

The existing app supports installation through Bun, Homebrew, the curl install
script, or a source checkout. Each installation provides the `mlx-bun` terminal
command. `bunx mlx-bun` also runs the app without a permanent installation.

These installation paths will be preserved during the migration. This branch
does not yet contain the app or its installation tooling.

## Development

Use Bun 1.4.2. From the repository root:

```sh
bun install
```

Follow the [MLX package setup](packages/mlx/README.md#development) to build or
stage its native libraries. Build the inference package's native expert I/O and video helper with
`bun run --filter @mlx-bun/inference build:native`. Then run `bun run typecheck`
and `bun run test`.
Run `bun run verify:packages` to pack the libraries, install them into a clean
temporary Bun project, and exercise public imports, examples, and bundled natives.
Use `bun scripts/verify-packages.ts --help` for options.

Mac CI runs typechecking, the model-free tests, and this consumer check.
Component source, tests, examples, and build configuration live together.

Keep it simple. Add only what is needed.
