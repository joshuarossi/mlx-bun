# mlx-bun

Local AI on Apple Silicon. mlx-bun 1.0 is an MLX inference engine, an
OpenAI/Anthropic/Responses-compatible server, a browser app, and TypeScript
libraries you can embed in your own Bun applications. Numerics are bit-exact
with mlx-lm by contract for validated configurations; inference needs no Python.

Docs: **[mlx-bun.dev](https://mlx-bun.dev)**

Requires an Apple Silicon Mac running macOS 14 or later. The standalone installation
includes its runtime; npm and source usage require Bun 1.4.2 or later.

## Install

```sh
# Signed, notarized standalone bundle
curl -fsSL https://mlx-bun.dev/install.sh | sh

# Homebrew
brew install joshuarossi/tap/mlx-bun

# npm package, run with Bun
bun install -g mlx-bun   # or run once: bunx mlx-bun
```

Each provides the `mlx-bun` command. The installer and npm package also provide
`mlx-bun.server`, `mlx-bun.generate`, `mlx-bun.convert`, `mlx-bun.fuse`,
`mlx-bun.lora` and `mlx-bun.upload`, which accept mlx-lm's arguments. See
[installation](https://mlx-bun.dev/getting-started/installation/) for options.

## Quickstart

```sh
mlx-bun get mlx-community/gemma-4-e4b-it-OptiQ-4bit   # download a model
mlx-bun serve e4b                                     # server + web app on port 8080
```

`mlx-bun` with no command serves a cached model, downloading a starter model on
first run. Send a request from another terminal:

```sh
curl http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages": [{"role": "user", "content": "Hello!"}], "max_tokens": 128}'
```

Or generate once without a server:

```sh
mlx-bun generate e4b "Write a haiku about Apple Silicon."
```

The server also answers `/v1/completions`, `/v1/messages`, `/v1/responses` and
`/v1/embeddings` when the loaded model supports them. `mlx-bun --help` and
`mlx-bun <command> --help` list every command and option; the
[CLI](https://mlx-bun.dev/reference/cli/), [HTTP API](https://mlx-bun.dev/reference/server-api/)
and [configuration](https://mlx-bun.dev/reference/server-config/) references
are generated from the source.

## Libraries

The `@mlx-bun/` packages expose loading and generation alongside the lower-level
kernels, layers, graphs, state, sampling, quantization and training they compose.
Start with `bun add @mlx-bun/inference` and the
[library guide](https://mlx-bun.dev/guides/library/); the
[library API](https://mlx-bun.dev/api/) covers every public export.

## Repository layout

- `apps/` — applications you run.
- `packages/` — libraries you import, published under `@mlx-bun/`.

[`@mlx-bun/mlx`](packages/mlx/README.md) owns the native MLX bindings.
[`@mlx-bun/inference`](packages/inference/README.md) owns inference graphs, kernels, layers, input processing, state, and memory fit estimates.
[`@mlx-bun/quantize`](packages/quantize/README.md) owns checkpoint quantization: calibration, sensitivity, mixed-precision allocation, rotation, and Trellis packing.
[`@mlx-bun/training`](packages/training/README.md) owns LoRA and preference training, optimizers, losses, and adapter production.
[`@mlx-bun/hub`](packages/hub/README.md) owns the local model registry and Hugging Face downloads and uploads.
`@mlx-bun/app-core` holds the core-service interfaces and module manifest contract, `@mlx-bun/app-host` the host-side module loader, and [`@mlx-bun/web-shell`](packages/web-shell/README.md) the web shell that mounts module panels, for the [modular app](ARCHITECTURE.md#modular-application).
[`mlx-bun`](apps/mlx-bun/README.md) owns the terminal app, server, and web surfaces.
The [public website](apps/website/README.md) owns user guides and build-only reference pages.

## Contributing

Read [ARCHITECTURE.md](ARCHITECTURE.md) for ownership, contracts, and dependency
rules, [CONTRIBUTING.md](CONTRIBUTING.md) for verification and evidence
requirements, and [PLAN.md](PLAN.md) for open work. Agents start at
[AGENTS.md](AGENTS.md).

## Development

Use Bun 1.4.2. From the repository root:

```sh
bun install
```

Follow the [MLX package setup](packages/mlx/README.md#development) to build or
stage its native libraries. Build the inference package's native expert I/O and video helper with
`bun run --filter @mlx-bun/inference build:native` and the app microphone helper
with `bun run --filter @mlx-bun/module-transcription build:native` (swiftc). Run `bun run link-cli` to link
this checkout's `mlx-bun` command into `${BUN_INSTALL:-$HOME/.bun}/bin`;
keep that directory on PATH. The link follows changes in this checkout.
Then run `bun run typecheck`
and `bun run test`.
Run `bun run verify:packages` to pack the libraries and app, install them into a clean
temporary Bun project, and exercise the CLI, public imports, examples, and bundled natives.
Use `bun scripts/verify-packages.ts --help` for options.
Release preparation, signing, notarization and publication are documented in the
app's [release instructions](apps/mlx-bun/README.md#release-preparation).

Mac CI runs typechecking, the model-free tests, and this consumer check.
Component source, tests, examples, and build configuration live together.

## License

The libraries and app are MIT; see [LICENSE](LICENSE).
