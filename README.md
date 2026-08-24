# mlx-bun

A Bun/TypeScript native inference engine and OpenAI-compatible HTTP server
for MLX on Apple Silicon — no Python, no sidecar process. `mlx-bun serve` is
a drop-in for `mlx_lm.server` (same port, endpoints, request fields, and
flags); the correctness contract is logit parity with mlx-lm as the oracle,
verified bit-exact by the test suite. Ships as one signed, notarized binary,
plus a library-first TypeScript API for embedding generation directly in
Bun, Tauri, or Electron apps.

Docs: **[mlx-bun.dev](https://mlx-bun.dev)**

## Scope

Apple Silicon only — MLX is a Metal framework, so this runs on macOS on M-series
chips by design, nothing else. Serving is single-user: one process serves one
loaded model to one caller at a time (`--isolate --model-pool N` pools
multiple single-model children behind a router; it isn't a multi-tenant
scheduler). Model support is a curated, oracle-backed list, not a generic
"any HF repo" loader — see the roster for what's validated.

## Install

Four ways in; all need an Apple Silicon Mac running macOS.

```sh
# Direct download — signed, notarized, no toolchain
curl -fsSL https://mlx-bun.dev/install.sh | sh

# Homebrew
brew install joshuarossi/tap/mlx-bun

# bunx — no install, needs Bun >= 1.4.0
bunx mlx-bun

# From source
git clone https://github.com/joshuarossi/mlx-bun.git && cd mlx-bun
bun install && bun run link-cli
```

Every channel builds from the same bundle. Details, signing, and the native
runtime resolution order: [docs/reference/distribution.md](./docs/reference/distribution.md).

## Quickstart

Bare `mlx-bun` aliases to `mlx-bun serve`; with no model named it downloads a
sub-GB starter and opens a chat UI. To pick a model explicitly:

```sh
mlx-bun serve e4b --port 8080
```

```sh
curl http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages": [{"role": "user", "content": "Hello!"}], "max_tokens": 128}'
```

```ts
import OpenAI from "openai";
const client = new OpenAI({ baseURL: "http://localhost:8080/v1", apiKey: "local" });
const res = await client.chat.completions.create({
  model: "local",
  messages: [{ role: "user", content: "Hello!" }],
});
```

Longer walkthroughs on the site:
[Installation](https://mlx-bun.dev/getting-started/installation/) and
[Quickstart](https://mlx-bun.dev/getting-started/quickstart/).

## Reference docs

Each fact about the project has exactly one home:

| Topic | Doc |
|---|---|
| Current state, what's next | [STATUS.md](./STATUS.md) |
| Benchmark numbers (parity / performance / quality) | [docs/reference/benchmarks.md](./docs/reference/benchmarks.md) |
| Supported models roster | [docs/reference/models.md](./docs/reference/models.md) |
| Server start flags, `MLX_BUN_*` env, defaults | [docs/reference/server-config.md](./docs/reference/server-config.md) |
| HTTP API routes and request/response schemas | [docs/reference/server-api.md](./docs/reference/server-api.md) |
| CLI verbs | [docs/reference/cli.md](./docs/reference/cli.md) |
| TypeScript library API | [docs/reference/library-api.md](./docs/reference/library-api.md) |
| LoRA fine-tuning (SFT / DPO / ORPO) | [docs/reference/training.md](./docs/reference/training.md) |
| Build, sign, notarize, publish | [docs/reference/distribution.md](./docs/reference/distribution.md) |
| Troubleshooting | [docs/reference/troubleshooting.md](./docs/reference/troubleshooting.md) |
| Personal memory (local wiki) | [docs/reference/memory.md](./docs/reference/memory.md) |
| Reference environment / oracle setup | [docs/reference/environment.md](./docs/reference/environment.md) |
| Active engineering design docs | [docs/design/](./docs/README.md) |
| Contributing / repo rules | [CONTRIBUTING.md](./CONTRIBUTING.md) |

Correctness is verified bit-exact against the Python mlx-lm reference as the
project's oracle: [benchmarks.md § Parity](./docs/reference/benchmarks.md#1-parity-porting-correctness--bit-exact-vs-the-oracle).

## Why

MLX is Apple's ML framework — hand-tuned Metal kernels with official
bindings for Python, C++, Swift, and C, but no JavaScript story. The
performance-critical work (every matmul, every attention pass) lives in
MLX's C++/Metal core, exposed through `mlx-c`; the layer on top — model
loading, tokenization, sampling, serving — is pure orchestration and
performance-neutral, so it can move to a better runtime without losing
speed. Bun fits: `bun:ffi` binds `mlx-c` directly with no node-gyp step,
`Bun.Image` gives native OS image codecs for vision input, and the result
ships as one binary with no Python venv.

## License

MIT. Third-party attributions: [THIRD_PARTY_LICENSES.md](./THIRD_PARTY_LICENSES.md).
