# mlx-bun

MLX inference as a TypeScript/Bun library, with a signed executable serving
OpenAI/Anthropic-compatible APIs on Apple Silicon. Embed generation in a Bun
application or run the local server and browser chat app. The numerical tests
compare logits bit-for-bit with mlx-lm for validated configurations.

Docs: **[mlx-bun.dev](https://mlx-bun.dev)**

## Scope

The engine requires an **Apple Silicon Mac running macOS 14 or later**.
The standalone executable includes its runtime; npm and source usage require
Bun. Node.js, Linux, and Windows cannot run the native engine.

The server uses continuous batching by default. Eligible requests share the
execution engine, including when only one request is active. Supported
combinations and the explicit serial option are documented in
[server configuration](./docs/reference/server-config.md).

Use the [supported model roster](./docs/reference/models.md) to choose an
artifact. Model architecture, weight format, and cache scheme determine
compatibility. Arbitrary Hugging Face repositories and GGUF files are not
automatically supported.

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

Homebrew and direct download install the same self-contained bundle. npm
ships a launcher and TypeScript source, then fetches the native runtime pack
on first use. See [distribution](./docs/reference/distribution.md) for details.

## Quickstart

Start the server and open the chat UI. With no model selected, the first run
downloads a starter model:

```sh
mlx-bun serve --port 8080
```

Use `mlx-bun ls` to see downloaded models. For example, after downloading a
matching model, `mlx-bun serve e4b` selects it by name. Model selection and
downloads are documented in the [CLI reference](./docs/reference/cli.md).

Send a request from the terminal:

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

## Find your way around

- **Use the app or server:** start above, then consult the
  [CLI](./docs/reference/cli.md), [models](./docs/reference/models.md), or
  [troubleshooting](./docs/reference/troubleshooting.md).
- **Build an application:** the [library API](./docs/reference/library-api.md)
  documents in-process Bun integration and isolated hosts for desktop apps.
  The [HTTP API](./docs/reference/server-api.md) works with other runtimes.
- **Evaluate or contribute:** read the [benchmark evidence](./docs/reference/benchmarks.md)
  and [contribution guide](./CONTRIBUTING.md). The [docs index](./docs/README.md)
  separates reference material, active design, and history.

Each reference topic has one home:

| Topic | Doc |
|---|---|
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

The numerical contract distinguishes stock mlx-lm parity, mlx-optiq parity
for supported extensions, and experimental methods. Tests compare logits
against pinned oracles under matching conditions; batching and sampling can
change generated trajectories. See the evidence and limits in
[benchmarks.md](./docs/reference/benchmarks.md#1-parity-porting-correctness--bit-exact-vs-the-oracle).
Server policy defaults are documented separately in
[server configuration](./docs/reference/server-config.md).

## Why

mlx-bun brings MLX inference into a TypeScript application without a Python
service. Bun's FFI calls `mlx-c` directly. Model implementations, scheduling,
sampling, and reusable cache state live in the same process.

Performance depends on both native kernels and how the engine uses them.
The project develops specialized kernels, avoids repeated computation, and
measures complete requests as well as decode throughput. The
[benchmark ledger](./docs/reference/benchmarks.md) records the machines,
settings, comparisons, and remaining regressions.

## License

MIT. Third-party attributions: [THIRD_PARTY_LICENSES.md](./THIRD_PARTY_LICENSES.md).
