# Library API

The HTTP server is one consumer of a library-first API. Everything it
does — generation, sampling, KV schemes, LoRA, vision, caching, memory
admission — is importable directly into a Bun process. Published as
`mlx-bun` on npm (0.0.4); `bunx mlx-bun` works out of the box, or
`import … from "mlx-bun"` for programmatic use.

One rule everywhere: **one generation at a time per process** (one GPU,
batch=1). The server serializes through a queue; do the same.

## Quick start

```ts
import {
  loadModelConfig,
  Weights,
  createModel,       // dispatches to Gemma4Model / MiniCPM5Model / Qwen35Model
  loadTokenizer,
  ChatTemplate,
  generate,
} from "mlx-bun";   // or "./src/index" in-repo

const dir = "/path/to/hf-snapshot";          // mlx-bun ls prints these
const config = await loadModelConfig(dir);
const model = createModel(await Weights.open(dir), config);   // returns RuntimeModel
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);
// Gemma4Model and MiniCPM5Model can still be imported directly from "mlx-bun"
// if you need the concrete type. Qwen35Model is NOT exported from the public
// package — use createModel/RuntimeModel (preferred dispatch), or import from
// "./src/model/qwen35" in-repo.

const ids = tok.encode(template.render([{ role: "user", content: "hi" }]));
const promptIds = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;

const gen = generate(model, promptIds, { maxTokens: 256, temperature: 0 });
const out: number[] = [];
for await (const t of gen) out.push(t.token);   // t: { token, index }
console.log(tok.decode(out, true));
console.log(gen.stats);                          // set once iteration ends
```

Weight loading is lazy (mmap + mlx native loader): construction is
milliseconds; weights materialize on first forward.

## generate(model, promptTokens, options) → Generation

`Generation` is an `AsyncIterable<GeneratedToken>` with a `stats`
property (`GenerateStats`, available after iteration completes — also
after an early `break`, which cleanly cancels the in-flight step).

`GenerateOptions` (all optional):

| option | default | notes |
|---|---|---|
| `maxTokens` | 512 | |
| `temperature` / `topP` / `topK` / `seed` | greedy when temperature 0 | on-device sampling; seeded per (seed, step) |
| `repetitionPenalty` / `repetitionContextSize` | off / 20 | |
| `eosTokenIds` | from config | includes the tool-handoff token |
| `prefillChunkSize` | 2048 | matches mlx-lm |
| `cache` | fresh | pre-warmed `Cache[]`; `cache[0].offset` tokens are treated as already prefilled. Caller keeps ownership |
| `kvBits` / `kvGroupSize` / `quantizedKvStart` | off / 64 / 5000 | uniform KV quantization (4 or 8), incl. rotating caches (Phase 9) |
| `kvConfig` | off | per-layer mixed precision from `kv_config.json` (`config.kvQuant`); overrides `kvBits`, start 0 — optiq serve semantics |
| `adapters` | none | mounted LoRA adapter ids, applied for exactly this generation |
| `promptEmbeddings` / `imageMask` | — | vision path (see `src/vision/`) |

`GenerateStats`: `promptTokens`, `cachedTokens`, `generatedTokens`,
`prefillTps` / `prefillMs`, `decodeTps` / `decodeMs`, `cacheTokens`
(the exact token sequence whose KV is in the cache — feed it to
`PromptCache.put`). Timing semantics match mlx-lm: the prompt clock
runs until the first token arrives (the prefill→decode boundary is
prompt time), the decode clock from there.

## Serving pieces

```ts
import { loadContext, createServer } from "mlx-bun";

const ctx = await loadContext(dir, "my-model", { memoryBudgetBytes: 12e9 });
const server = createServer(ctx, 8090, {
  promptCacheBytes: 2e9,        // byte-capped LRU (never count-capped)
  kvQuant: undefined,           // default: kv_config.json; "off" | bits
  memoryBudgetBytes: 12e9,      // admission control — the only OOM defense
});
```

`loadContext` refuses models that cannot serve any context within the
budget (pre-GPU, mmap-only check). The server exposes OpenAI chat
completions, Anthropic `/v1/messages`, OpenAI Responses, embeddings,
adapters, and `/stats` — [server-api.md](./server-api.md).

## Text embeddings

```ts
import { createModel, loadTokenizer, isEmbeddingModel, embedMany } from "mlx-bun";

const model = createModel(await Weights.open(dir), config); // Qwen3-Embedding
if (!isEmbeddingModel(model)) throw new Error("not an embedding model");
const tok = await loadTokenizer(dir);

const [a, b] = embedMany(model, tok, ["the cat sat", "a kitten rested"]);
// a.vector / b.vector are Float32Array, L2-normalized → dot product = cosine.
```

`isEmbeddingModel` narrows a `RuntimeModel` to the plain-Qwen3 backbone (the
only one exposing `embedPooled`: last-token hidden → L2-norm). `embedOne`/
`embedMany` append the `<|endoftext|>` pooling token and, given an optional
`instruction`, apply Qwen3-Embedding's query format. Same vectors the CLI
(`mlx-bun embed`) and `/v1/embeddings` produce — bit-exact vs mlx-lm.

## Prompt cache (in-process prefix reuse)

> **Note:** `PromptCache`, `AdapterManager`, `saveKvCache`, and
> `loadKvCache` are **not** re-exported from the public `"mlx-bun"`
> entry point (`src/index.ts`). Import them from their internal paths
> as shown below; this is intentional — they are implementation-level
> pieces rather than stable public API surface.

```ts
import { PromptCache } from "./src/prompt-cache";
const cache = new PromptCache(2e9);                  // BYTE-capped LRU
const hit = cache.take(promptIds, /*namespace*/ "");  // longest common prefix, trimmed
const caches = hit?.caches ?? model.makeCache();
const gen = generate(model, promptIds, { cache: caches });
for await (const t of gen) { /* … */ }
cache.put(gen.stats!.cacheTokens, caches, "");       // hand ownership back
```

Namespace entries by adapter spec when LoRA is in play (KV computed
under one adapter must not seed another's prefill).

## KV-cache persistence (cross-process)

```ts
import { saveKvCache, loadKvCache } from "./src/kv-store";
saveKvCache("/tmp/prefix.kv", tokens, caches);       // page-aligned file
const { tokens, caches, mmap } = loadKvCache("/tmp/prefix.kv", model as Gemma4Model);
// reload is a zero-copy MAP_PRIVATE mmap straight to the GPU (~1 ms);
// keep `mmap` referenced as long as the caches live
// Note: loadKvCache is typed to accept Gemma4Model, but only uses model.layers.length
// at runtime — a cast from RuntimeModel is safe for any model that has a layers array.
```

Quantized caches are not persistable yet (documented gap).

## Registry + fit (model discovery and memory math)

```ts
import { Registry, fit, skuMatrix } from "mlx-bun";

const reg = new Registry();           // bun:sqlite, scans the HF cache
await reg.scan();
const m = reg.resolve("12B");         // unique-match query, throws on ambiguity
const report = fit(await loadModelConfig(m.path), m.sizeBytes, 8192,
                   undefined, undefined, m.expertsBytes);
// report: { fits, maxSafeContext, predictedDecodeTps, kvBytes, … }
```

`fit` is calibrated per chip family (MoE-aware: decode reads active
experts only). The server uses it for admission; `mlx-bun fit <query>`
is the CLI face.

## LoRA hot-swap

```ts
import { AdapterManager } from "./src/lora";
const adapters = new AdapterManager(model);
await adapters.mount("upper", "/path/to/adapter-dir");  // all-or-nothing validation
const gen = generate(model, promptIds, { adapters: ["upper"] });
```

Mount N adapters on one base; selection is per-generation; an
unselected adapter costs nothing; base logits are byte-identical after
any amount of switching.

## Memory & disposal rules

- `MlxArray` wrappers have explicit `.dispose()` with a
  FinalizationRegistry backstop — dispose what you create in hot paths.
- Caches you own (from `model.makeCache()` outside the prompt cache):
  dispose each via `c.dispose()` when done.
- GPU OOM is **uncatchable** (mlx throws from a Metal completion
  handler → process death). Use `fit`/admission before generating, not
  try/catch around it.
- Never read a typed array that native code wrote in a hot path; use
  the `read.*` helpers (bun#32054 — see PLAN-archive.md Phase 4 findings).
