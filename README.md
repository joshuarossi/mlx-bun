# mlx-bun

Provide and enable the best local AI experience on Apple Silicon, through
applications people can run and libraries developers can embed in their own apps.

The current target is Apple Silicon Macs. This branch is rebuilding mlx-bun
as a Bun workspace. The first migrated pieces are the low-level MLX binding
and the existing Trellis inference kernels.

## Repository layout

- `apps/` — applications you run.
- `packages/` — libraries you import, published under `@mlx-bun/`.

[`@mlx-bun/mlx`](packages/mlx/README.md) owns the native MLX bindings.
[`@mlx-bun/inference`](packages/inference/README.md) owns inference kernels
and will grow as graphs and other inference components are migrated.
`apps/` will be created with its first application.

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
stage its native libraries. Then run `bun run typecheck` and `bun run test`.
Component source, tests, and build configuration live together.

Keep it simple. Add only what is needed.
