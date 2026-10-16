# mlx-bun

mlx-bun runs AI models locally on Apple Silicon Macs using Apple's MLX.
Chat in your browser, serve models through a local API, or build with TypeScript
libraries for Bun. No Python is required for inference. Speech transcription supports Whisper and
[Phonon-2 on the GPU](packages/inference/README.md#phonon-2).

**mlx-bun 1.0.0 is beta and actively developed.** APIs and behavior may change;
breaking changes will be called out in release notes.

Docs: **[mlx-bun.dev](https://mlx-bun.dev)**

## Why mlx-bun?

- **Local inference:** run supported models on your Mac without a hosted-model API key.
- **Familiar interfaces:** browser chat, terminal commands, and OpenAI/Anthropic-compatible APIs.
- **Local decisions:** use Jev or OpenAI Decisions-compatible endpoints with any
  supported local language model, sharing the same loaded weights as generation.
- **TypeScript libraries:** embed inference in a Bun app, with access to the
  components for generation, quantization, and training.

## Install

Requires an **Apple Silicon Mac with macOS 14 or later**. The standalone installer
includes its runtime and native libraries; you don't need to install Bun or Python.

```sh
curl -fsSL https://mlx-bun.dev/install.sh | sh
```

Keep `~/.local/bin` on your `PATH`. Homebrew and Bun installations are covered
in the [installation options](https://mlx-bun.dev/getting-started/installation/).

## Quickstart

```sh
mlx-bun
```

This serves a cached model and opens browser chat at
**http://localhost:8080**. If no supported model is cached, it downloads a starter
from Hugging Face and may download a recommended model in the background.
Downloads require internet access.

Send a request from another terminal:

```sh
curl http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages": [{"role": "user", "content": "Hello!"}], "max_tokens": 128}'
```

For local classification and scoring, use `/v1/decisions` (OpenAI) or
`/v1/systemone` (Jev). See the [runnable examples](apps/mlx-bun/scripts/decision-example.ts),
[SDK examples](apps/mlx-bun/scripts/decision-website-examples.mjs) (Node 22+), and
[supported question types and limits](apps/mlx-bun/README.md#local-decisions).

The [quickstart](https://mlx-bun.dev/getting-started/quickstart/) covers choosing a
model and generating from the terminal. `mlx-bun --help` lists commands;
the [HTTP API reference](https://mlx-bun.dev/reference/server-api/) describes the endpoints.

## Our quant on Hugging Face

We publish [Qwen3.8-27B-Trellis-3.2bpw](https://huggingface.co/mlx-bun/Qwen3.8-27B-Trellis-3.2bpw),
a 27B Qwen model in mlx-bun's packed Trellis format. The full download is about **12.25 GB**;
running it needs additional memory for inference. See the model card for
requirements, evaluations, and usage. It is an optional larger model, separate
from the first-run starter.

## Libraries

Use **Bun 1.4.2 or later** on an Apple Silicon Mac. Start with
`bun add @mlx-bun/inference` and the
[library guide](https://mlx-bun.dev/guides/library/); the
[library API](https://mlx-bun.dev/api/) covers the public exports.
Numerical guarantees apply to validated models and configurations; see
[correctness and evidence](https://mlx-bun.dev/about/correctness/).

## Repository layout

- [App](apps/mlx-bun/README.md): terminal commands, server, browser app, and feature modules.
- Libraries: [MLX bindings](packages/mlx/README.md), [inference](packages/inference/README.md),
  [quantization](packages/quantize/README.md), [training](packages/training/README.md),
  and [model hub](packages/hub/README.md).
- [Website](apps/website/README.md): user guides and generated references.

The [architecture](ARCHITECTURE.md) explains package ownership and module boundaries.

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
stage its native libraries. Build the inference package's native expert I/O, Neural Engine bridge and video helper with
`bun run --filter @mlx-bun/inference build:native` and the app microphone helper
with `bun run --filter @mlx-bun/module-transcription build:native` (swiftc). Run `bun run link-cli` to link
this checkout's `mlx-bun` command into `${BUN_INSTALL:-$HOME/.bun}/bin`;
keep that directory on PATH. The link follows changes in this checkout.
Then run `bun run typecheck`
and `bun run test`.
For faster local type feedback, `bun run typecheck:fast` uses the pinned experimental
ts-rust compiler through the same workspace scripts and configurations, including
Astro type generation, browser code, portable contracts, and repository scripts.
The required `bun run typecheck` check and CI continue to use TypeScript 6.0.3;
run it before submitting a change. TypeScript also remains the compiler API used
by the architecture gates and documentation tools.
Run `bun run verify:packages` to pack the libraries and app, install them into a clean
temporary Bun project, and exercise the CLI, public imports, examples, and bundled natives.
Use `bun scripts/verify-packages.ts --help` for options.
Release preparation, signing, notarization and publication are documented in the
app's [release instructions](apps/mlx-bun/README.md#release-preparation).

Mac CI runs typechecking, the website build, the model-free tests, the training
natives, this consumer check and `bun run verify:binary` (the relocated standalone
bundle). Pull requests to `main` that touch numerical code also run the paired
performance check on a self-hosted Mac ([evidence](CONTRIBUTING.md#numerical-and-performance-evidence)).
Component source, tests, examples, and build configuration live together.

## License

The libraries and app are MIT; see [LICENSE](LICENSE).
