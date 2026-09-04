# Library API

The HTTP server is one consumer of a library-first API. Everything it
does — generation, sampling, KV schemes, LoRA, vision, caching, memory
admission — is importable directly into a Bun process. Published as
`mlx-bun` on npm; `bunx mlx-bun` runs the CLI, `import … from "mlx-bun"`
(or `./src/index` in a clone) is the programmatic surface.

This page is the canonical description of that surface. The source of
truth is `src/index.ts`: what it re-exports is the semver contract;
everything else under `src/` is internal and may change without notice.
Every export is documented below, grouped the way `src/index.ts` groups
them.

One rule everywhere: **one generation at a time per process** (one GPU).
The server serializes through a queue (or, under `--batch N`, its
continuous scheduler — a server scheduling mechanism, not a library
surface); direct library callers must do the same.

## Export map

| Group | Values | Types |
|---|---|---|
| [Native runtime](#native-runtime) | `ensureNativeRuntime`, `nativeRuntimeDir` | — |
| [Config and weights](#config-and-weights) | `loadModelConfig`, `Weights` | — |
| [Model profiles](#model-profiles) | `resolveModelProfile`, `configFingerprint`, `externalArtifactFingerprint`, `BUILTIN_ARTIFACT_PROFILES`, `ENGINE_CAPABILITIES` | `ArtifactModelProfile`, `EngineCapability`, `FidelityTarget`, `FidelityTier`, `GenerationLoop`, `ModelArtifactIdentity`, `ModelExecutionComposition`, `ModelGraph`, `ModelLoader`, `ModelProfile`, `ModelSpecialization`, `ResolveModelProfileOptions`, `ResolvedModelProfile` |
| [Opening a model](#opening-a-model) | `openModel`, `createModel`, `openGlm52RuntimeModel` | `RuntimeModel`, `Glm52RuntimeOpenOptions` |
| [Concrete model classes](#concrete-model-classes) | `Gemma4Model`, `MiniCPM5Model`, `Qwen3Model` | — |
| [Tokenizer](#tokenizer) | `loadTokenizer` | — |
| [Chat templates](#chat-templates) | `ChatTemplate` | — |
| [Generation](#generatemodel-prompttokens-options--generation) | `generate` | — |
| [Text embeddings](#text-embeddings) | `embedOne`, `embedMany`, `isEmbeddingModel`, `withInstruction` | `EmbedResult` |
| [Model discovery](#model-discovery-registry) | `Registry` | — |
| [Downloads](#downloads) | `downloadModel` | — |
| [Memory fit](#memory-fit) | `fit`, `skuMatrix`, `thisMachine`, `chooseAutoModel`, `recommendedRepoId`, `largestRecommendedRepoId`, `DEFAULT_REPO_ID`, `COEXIST_FRACTION` | — |
| [Serving](#serving) | `loadContext`, `createServer` | `LoadContextOptions`, `ServerContext`, `ServerOptions` |

Types that are *not* exported (`GenerateOptions`, `GenerateStats`,
`GeneratedToken`, `Generation`, `LoadedTokenizer`, `ChatMessage`,
`RenderOptions`, `ModelConfig`, `MachineSpec`, `FitReport`, `ModelRecord`,
`DownloadOptions`, `Cache`) are reachable through inference — e.g.
`Parameters<typeof generate>[2]`, `Awaited<ReturnType<typeof loadTokenizer>>`.

## Quick start

```ts
import {
  ensureNativeRuntime,
  openModel,         // artifact-aware dispatch, including bounded GLM-5.2
  loadTokenizer,
  ChatTemplate,
  generate,
} from "mlx-bun";   // or "./src/index" in-repo

await ensureNativeRuntime();
const dir = "/path/to/hf-snapshot";          // mlx-bun ls prints these
const model = await openModel(dir);
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);

// The template emits <bos> as text and the tokenizer post-processor prepends
// one too; trim the duplicate exactly the way the server does.
const ids = tok.encode(template.render([{ role: "user", content: "hi" }]));
const promptIds = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;

const gen = generate(model, promptIds, { maxTokens: 256, temperature: 0 });
const out: number[] = [];
for await (const t of gen) out.push(t.token);   // t: { token, index }
console.log(tok.decode(out, true));
console.log(gen.stats);                          // set once iteration ends
```

Ordinary safetensors loading is lazy (mmap + mlx native loader). GLM-5.2
first runs its header-only exact process equation, then opens the bounded
Colibri resident/expert tiers; impossible plans fail before either tier is
committed.

## Native runtime

Library consumers bypass the CLI's first-run step, so call
`ensureNativeRuntime()` once before constructing a model on a machine that
may not have the MLX native runtime yet. It downloads the sha256-verified
native pack (MLX plus the direct-Colibri expert-I/O helper) to
`~/Library/Caches/mlx-bun/` and is a no-op when the runtime is already
present (beside the executable, already cached, `MLX_BUN_LIBMLXC`, or
installed via homebrew). It resolves to the runtime directory.
`nativeRuntimeDir()` returns the resolved directory, or `null` on a fresh
machine.

```ts
import { ensureNativeRuntime, nativeRuntimeDir } from "mlx-bun";

if (nativeRuntimeDir() === null) console.log("first run: fetching the native pack");
const runtime = await ensureNativeRuntime({
  onProgress: (received, total) => console.log(`${received}/${total}`),
});
console.log(runtime);
```

`ensureNativeRuntime(opts?)` also accepts `url`, `sha256`, `sizeBytes`, and
`destDir` overrides for pinned/offline installs; production callers pass
nothing.

## Config and weights

`loadModelConfig(modelDir)` parses `config.json` (and, for GLM-5.2,
`generation_config.json`) into the normalized `ModelConfig` every other
entry point consumes: `modelType`, `text` (layer/head geometry, rope,
window, MoE), `quantization`, `kvQuant` (from `kv_config.json`),
`eosTokenIds`, `hasVisionSidecar`, and the `raw` object.

`Weights.open(modelDir)` opens every safetensors shard through the mlx
native loader on the CPU stream: header-parsed, mmap-backed, no bytes
materialize until a tensor is touched. It is the input to `createModel` and
to the concrete model constructors. Ownership is explicit: `dispose()`
frees every native map and cached tensor; `releaseShard(file)` frees one
shard's materialized tensors (it transparently re-opens on the next
`tensor()` that needs it — the seam whole-model transforms use at 27B
scale). `tensor(name)`, `has(name)`, `info(name)`, `fileOf(name)`, and
`tensorNames` are the read side.

```ts
import { loadModelConfig, Weights } from "mlx-bun";

const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
console.log(config.modelType, config.text.numHiddenLayers, weights.tensorNames.length);
weights.dispose();
```

## Model profiles

`openModel()`, `createModel()`, and `loadContext()` resolve a declared
model profile before they open weights. A profile declares construction
only — loader, model graph, generation loop, specialization — and carries
its fidelity contract (`l1` bit-exact vs mlx-lm, `l2` bit-exact vs
mlx-optiq, `l3` measured). Exact artifact profiles outrank family
profiles; dedicated/generated graphs outrank the universal fallback.
Profile selection never rewrites generation options: `kvConfig`,
TurboQuant KV, adapters, grammar, sampling, or an explicitly configured
draft method stay authoritative.

`resolveModelProfile(config, options?)` returns a `ResolvedModelProfile`:
`profile` (the declaration), `artifact` (`fingerprint` —
`hf:<org>/<repo>@<revision>` when the path is an immutable Hugging Face
snapshot, else `null` — plus `configFingerprint`), and `exactArtifact`.
`configFingerprint(config)` is the stable hash over every config field that
changes the decode graph structure plus the kv_config layout.
`externalArtifactFingerprint(modelDir)` is the HF-snapshot identity rule
on its own. `BUILTIN_ARTIFACT_PROFILES` lists the exact declarations this
repository backs with parity or measured evidence; `ENGINE_CAPABILITIES`
is the frozen capability vocabulary profiles declare against.

```ts
import { loadModelConfig, resolveModelProfile } from "mlx-bun";

const config = await loadModelConfig(dir);
const resolved = resolveModelProfile(config);
console.log(resolved.profile.id);
console.log(resolved.artifact.fingerprint);      // hf:<org>/<repo>@<revision> or null
console.log(resolved.profile.fidelity);          // { tier, oracle, claim }
console.log(resolved.profile.execution);         // { loader, graph, loop, specialization }
```

For a local artifact that is not stored under an immutable HF snapshot
path, an application supplies its own provenance fingerprint and exact
declaration. The resolver checks the declared config fingerprint and the
required engine capabilities; an exact match that fails either check
refuses instead of taking the family or generic fallback.

```ts
import {
  configFingerprint,
  loadModelConfig,
  resolveModelProfile,
  type ArtifactModelProfile,
} from "mlx-bun";

const config = await loadModelConfig(dir);
const mine: ArtifactModelProfile = {
  id: "acme/gemma4-e4b-custom@2026-08",
  artifactFingerprint: "acme:gemma4-e4b-custom@sha256-…",
  configFingerprint: configFingerprint(config),
  fidelity: { tier: "l1", oracle: "mlx-lm", claim: "bit-exact" },
  // Must cover everything the execution composition implies.
  requiredCapabilities: ["safetensors", "autoregressive", "gemma4-graph"],
  execution: {
    loader: "safetensors", graph: "gemma4",
    loop: "autoregressive", specialization: "dedicated",
  },
};
const resolved = resolveModelProfile(config, {
  artifactFingerprint: mine.artifactFingerprint,
  artifactProfiles: [mine],
});
console.log(resolved.exactArtifact);             // true
```

## Opening a model

`openModel(modelDir, options?)` is the artifact-aware constructor and the
preferred entry point: it loads the config, resolves the profile, and
either opens safetensors weights and builds the graph the profile names, or
— when the profile's loader is `colibri` — routes to
`openGlm52RuntimeModel`. It resolves to a `RuntimeModel`, the union every
other API accepts (`Gemma4Model | MiniCPM5Model | Qwen35Model | Qwen3Model
| Qwen3MoeModel | DiffusionGemmaModel | Glm52Model | UniversalDenseModel`).
`options` is `Glm52RuntimeOpenOptions`; models other than the direct
Colibri GLM-5.2 artifact ignore it.

`createModel(weights, config, resolved?)` is the direct-construction form
for callers that already hold `Weights` and a `ModelConfig` (and
optionally a previously resolved profile — it re-validates the profile
against the config). It throws for the GLM-5.2 graph, which has no
ordinary safetensors index and must go through `openModel` /
`openGlm52RuntimeModel`.

`openGlm52RuntimeModel(modelDir, options?)` opens the direct Colibri
artifact through the bounded expert runtime and resolves to `{ model, plan }`
— the model plus the exact header-derived memory plan (`Glm52MemoryPlan`)
that was checked before any resident tensor or expert slab was touched.
Options: `memoryBudgetBytes` (whole-process ceiling; default = the smaller
of the validated preset and physical RAM), `contextTokens`,
`maxGenerationTokens`, `batchSize`, `enableMtp` (default on),
`mtpDraftTokens`, `libraryPath` (expert-I/O dylib override), and
`machineBytes` (test seam).

```ts
import { createModel, loadModelConfig, openModel, resolveModelProfile, Weights } from "mlx-bun";

// Preferred.
const model = await openModel(dir);

// Equivalent for safetensors artifacts, with each step visible.
const config = await loadModelConfig(dir);
const profile = resolveModelProfile(config);
const same = createModel(await Weights.open(dir), config, profile);

// The direct Colibri GLM-5.2 artifact takes its load-only resource controls here.
const glm = await openModel(glmDir, {
  contextTokens: 4096, maxGenerationTokens: 256, enableMtp: false,
});
```

Direct `generate()` on a GLM-5.2 model supports the full
sampling/grammar/logprobs contract but does not itself mount a drafter;
native MTP is a serving-context feature (`loadContext`).

## Concrete model classes

`Gemma4Model`, `MiniCPM5Model`, and `Qwen3Model` are exported today for
callers that need the concrete type (e.g. `model.layers`,
`model.loraTargets()`, `Qwen3Model.embedPooled`). Each constructs as
`new X(weights, config)` from `Weights` + `ModelConfig` and exposes
`makeCache(): Cache[]`, `forward(tokens, cache)`, and `config`.

> **Prefer `openModel` / `createModel`.** These class exports may be removed
> from the public surface: the factory is the supported way to obtain a
> `RuntimeModel`, and the other graphs (Qwen3.5, Qwen3-MoE, DiffusionGemma,
> GLM-5.2, the universal dense graph) are already reachable only through
> it. Narrow with `instanceof` when a concrete type is genuinely needed
> (`isEmbeddingModel` below is the shipped example).

```ts
import { Gemma4Model, loadModelConfig, Weights } from "mlx-bun";

const config = await loadModelConfig(dir);
const gemma = new Gemma4Model(await Weights.open(dir), config);   // same object createModel returns
console.log(gemma.layers.length, gemma.windowSize);
```

## Tokenizer

`loadTokenizer(modelDir)` loads `tokenizer.json` + `tokenizer_config.json`
through a pure-JS tokenizer (no native code; embeds in `bun build
--compile`) with round-trip parity against the Python oracle. The result
exposes `encode(text, addSpecialTokens = true)`, `decode(ids,
skipSpecialTokens = false)`, `idToToken(id)` (the undecoded vocab piece,
for logprobs), `bosTokenId`, `eosTokenId`, and the streaming-detokenizer
parity flags (`trimsLeadingSpace`, `bareSpaceTokenId`) the server consults.
`encode` memoizes byte-identical inputs and splices incrementally on
shared prefixes.

```ts
import { loadTokenizer } from "mlx-bun";

const tok = await loadTokenizer(dir);
const ids = tok.encode("The quick brown fox", false);   // no BOS
console.log(ids, tok.decode(ids), tok.idToToken(ids[0]!));
```

## Chat templates

`ChatTemplate.load(modelDir, { disableThinking? })` renders the model's own
`chat_template` (from `tokenizer_config.json` or `chat_template.jinja`)
via a pure-JS Jinja engine, so the template cannot rot when the model
updates it; GLM-5.2's pinned template ships as a built-in renderer.
`render(messages, options?)` takes OpenAI-shaped `ChatMessage`s (`role`,
`content`, `tool_calls`, `tool_call_id`, `name`, `reasoning`) and
`RenderOptions`: `addGenerationPrompt` (default true), `tools`,
`enableThinking`, `reasoningEffort` (`"xhigh" | "medium" | "low"`, only for
templates that read it — see `readsReasoningEffort`), and
`preserveThinking`. Capability flags on the instance: `supportsThinking`,
`thinkingFormat` (`"think-tag" | "gemma-channel" | null`),
`readsReasoningEffort`, `readsPreserveThinking`.

```ts
import { ChatTemplate } from "mlx-bun";

const template = await ChatTemplate.load(dir);
const rendered = template.render(
  [
    { role: "system", content: "Answer briefly." },
    { role: "user", content: "What is 2+2?" },
  ],
  { enableThinking: template.supportsThinking ? false : undefined },
);
```

## generate(model, promptTokens, options) → Generation

`generate` is the streaming port of mlx-lm's `generate_step`: chunked
prefill with per-chunk cache evaluation, pipelined decode via async eval,
on-device sampling (only the chosen token id crosses to JS). It returns a
`Generation`: an `AsyncIterable<GeneratedToken>` (`{ token, index,
logprobs? }`) with a `stats` property (`GenerateStats`, available after
iteration completes — also after an early `break`, which cleanly cancels
the in-flight step). Adapters, the wired-memory scope, and GLM usage
flushing are all scoped to the iteration.

`GenerateOptions` (all optional):

| option | default | notes |
|---|---|---|
| `maxTokens` | 512 | |
| `temperature` / `topP` / `topK` / `minP` / `minTokensToKeep` / `seed` | greedy when temperature 0 | on-device sampling; seeded per (seed, step); reference chain order top-p → min-p → XTC → top-k |
| `xtcProbability` / `xtcThreshold` / `xtcSpecialTokens` | off | XTC ("exclude top choices") |
| `hlg` / `curve` | off | tone-curve and log-prob transfer-curve samplers (replace the flat temperature slope) |
| `logitBias` | none | additive per-token-id bias, applied before penalties |
| `repetitionPenalty` / `repetitionContextSize` | off / 20 | |
| `presencePenalty` / `frequencyPenalty` (+ `…ContextSize`) | off | OpenAI-style, may be negative |
| `eosTokenIds` | from config | includes the tool-handoff token |
| `prefillChunkSize` | 2048 | matches mlx-lm |
| `signal` | none | `AbortSignal`; cancels before allocation, between AR prefill chunks, and between decode steps. An active native operation completes before the next cancellation check. |
| `onPrefillDone` / `snapshotAt` | — | fired once at the stable cache boundary before further KV is written (the server's prompt-cache snapshot hook) |
| `cache` | fresh | pre-warmed `Cache[]`; `cache[0].offset` tokens are treated as already prefilled. Caller keeps ownership |
| `kvBits` / `kvGroupSize` / `quantizedKvStart` | off / 64 / 5000 | uniform KV quantization (4 or 8), incl. rotating caches |
| `kvConfig` | off | per-layer mixed precision from `kv_config.json` (`config.kvQuant`); overrides `kvBits`, start 0 — optiq serve semantics |
| `turboQuant` | off | TurboQuant KV scheme (docs/design/turboquant.md), a rotation-based alternative to uniform `kvBits`; mutually exclusive with `kvBits`/`kvConfig` |
| `pagedKv` | off | `{ blockSize? }` — OPTIONAL paged KV cache (docs/design/kv-cache.md); v1 scope is serial batch=1 Gemma4-family bf16, mutually exclusive with `kvBits`/`kvConfig`/`turboQuant`/draft/compiled decode |
| `adapters` | none | mounted LoRA adapter ids, applied for exactly this generation |
| `promptEmbeddings` / `imageMask` / `multimodalMask` / `visionPixels` | — | vision and audio paths (see `src/vision/`, docs/design/generic-model-support.md); caller keeps ownership |
| `logprobs` / `topLogprobs` | off | per-token logprob capture (mlx_lm.server parity): the emitted token's log-probability and the top-k (id, logprob) pairs — full-vocab log-softmax after logits processors, before the sampler |
| `grammar` | off | a compiled `GrammarController` (`src/grammar.ts`) for structured output — masks invalid tokens to `-inf` each step (L2-class, oMLX oracle) |

`GenerateStats`: `promptTokens`, `cachedTokens`, `generatedTokens`,
`prefillTps` / `prefillMs`, `decodeTps` / `decodeMs`, `cacheTokens` (the
exact token sequence whose KV is in the cache — feed it to
`PromptCache.put`). Timing semantics match mlx-lm: the prompt clock runs
until the first token arrives (the prefill→decode boundary is prompt time),
the decode clock from there. An optional `spec` field carries
speculative-decoding telemetry (serve `--draft-model` path only):
`drafted`, `accepted`, `targetCalls`, and per-draft-position
`draftedByPos` / `acceptedByPos` counts.

```ts
import { generate } from "mlx-bun";

const gen = generate(model, promptIds, {
  maxTokens: 256,
  temperature: 0.7, topP: 0.95, seed: 42,     // reproducible sampling
  kvBits: 8, quantizedKvStart: 4096,          // optional: quantized KV past 4k
  logprobs: true, topLogprobs: 5,
});
for await (const t of gen) {
  process.stdout.write(tok.decode([t.token], true));
  if (t.index > 64) break;                    // early break cancels cleanly
}
console.log(gen.stats?.decodeTps, gen.stats?.cacheTokens.length);
```

## Text embeddings

Qwen3-Embedding models run on the plain-Qwen3 backbone, the only graph
exposing `embedPooled` (last-token hidden → L2-norm). `isEmbeddingModel`
narrows a `RuntimeModel` to `Qwen3Model`; `embedOne(model, tok, text,
instruction?)` and `embedMany(model, tok, texts, instruction?)` encode
without BOS, append the `<|endoftext|>` pooling token, run one forward per
text (the runtime is single-sequence), and return `EmbedResult`s:
`vector` (`Float32Array`, L2-normalized, so dot product = cosine) and
`tokens`. `withInstruction(text, instruction?)` applies Qwen3-Embedding's
query format (`Instruct: …\nQuery:…`); documents embed raw, only queries
take an instruction. These are the same vectors the CLI (`mlx-bun embed`)
and `/v1/embeddings` produce — bit-exact vs mlx-lm.

```ts
import { embedMany, embedOne, isEmbeddingModel, loadTokenizer, openModel } from "mlx-bun";

const model = await openModel(embedDir);                 // a Qwen3-Embedding snapshot
if (!isEmbeddingModel(model)) throw new Error("not an embedding model");
const tok = await loadTokenizer(embedDir);

const query = embedOne(model, tok, "cats", "Given a query, retrieve relevant passages");
const docs = embedMany(model, tok, ["the cat sat", "a kitten rested", "tax law"]);
const cosine = (a: Float32Array, b: Float32Array) =>
  a.reduce((s, x, i) => s + x * b[i]!, 0);
console.log(docs.map((d) => cosine(query.vector, d.vector)));
```

## Model discovery (Registry)

`Registry` is the model index behind `mlx-bun ls` / `scan` / `/v1/models`: a
`bun:sqlite` cache (default `~/.cache/mlx-bun/registry.sqlite`, or
`":memory:"`) of every snapshot in the Hugging Face hub cache (`HF_HUB_CACHE`
> `HF_HOME/hub` > `~/.cache/huggingface/hub`). `scan(hubDir?)` re-walks the
cache and returns the record count; `list(filter?)` returns `ModelRecord`s
(`path`, `repoId`, `modelType`, `sizeBytes`, `expertsBytes`, `sidecarBytes`,
quantization fields, vision/audio/kv-config/tool-template capability flags,
`license`) filtered by `vision`, `maxBytes`, or a substring `query`;
`listCanonical(filter?)` collapses to one record per repo (the `refs/main`
snapshot); `resolve(query)` returns exactly one model or throws listing the
candidates; `close()` closes the database.

```ts
import { Registry } from "mlx-bun";

const reg = new Registry();
await reg.scan();
for (const m of reg.listCanonical({ vision: true })) console.log(m.repoId, m.sizeBytes);
const m = reg.resolve("e4b");                            // unique-match query
console.log(m.path);
reg.close();
```

## Downloads

`downloadModel(repoId, opts?)` fetches a Hugging Face repo into the
standard hub cache layout (blobs + snapshots + refs), resumable and
sha-verified through the same machinery the native pack uses, with a disk
preflight that credits verified blobs and partial prefixes before the first
payload. It resolves to the snapshot directory — the `dir` every other
entry point takes. `DownloadOptions`: `revision` (default `main`),
`cacheDir`, `endpoint`, `token` (default: the local HF login), and
`onProgress(file, received, total)`. Multi-GB downloads are the caller's
decision; nothing here starts one implicitly.

```ts
import { DEFAULT_REPO_ID, downloadModel } from "mlx-bun";

const dir = await downloadModel(DEFAULT_REPO_ID, {
  onProgress: (file, received, total) => console.log(file, received, total),
});
console.log(dir);                                        // …/snapshots/<sha>
```

## Memory fit

`fit` is the deterministic memory contract behind `mlx-bun fit` and server
admission: weights (bytes from the registry) + KV at the requested context
(config geometry; sliding-window layers saturate at the window; quantized
schemes billed via `kvScheme`) + prefill transient (chunk × calibrated
bytes/token) against the machine's usable envelope (RAM × wired fraction,
or an explicit `usableBytes` budget). MoE-aware: decode reads active
experts only. Signature: `fit(config, weightsBytes, ctx, machine =
thisMachine(), chunk = 2048, expertsBytes = 0, usableBytes?, kvScheme?)` →
`FitReport` (`fits`, `maxSafeContext`, `predictedDecodeTps`, `weightsBytes`,
`kvBytes`, `transientBytes`, `totalBytes`, `usableBytes`, …).

`thisMachine(bandwidthGBs?)` detects the chip and RAM; `skuMatrix(config,
weightsBytes, ctx, expertsBytes?, kvScheme?)` runs `fit` across the
representative Apple Silicon SKU table. `DEFAULT_REPO_ID` is the default
model everywhere (e4b); `recommendedRepoId()` returns it;
`largestRecommendedRepoId(ramBytes?)` is the per-RAM-tier "biggest Gemma"
for explicit opt-in. `chooseAutoModel(candidates, defaultRepoId,
fitsFullBudget, fitsCoexistBudget)` is the pure auto-pick rule (default if
it fits → largest that leaves `COEXIST_FRACTION` headroom → largest that
fits at all); the caller supplies the fit predicates.

```ts
import {
  chooseAutoModel, COEXIST_FRACTION, DEFAULT_REPO_ID, fit, loadModelConfig,
  Registry, skuMatrix, thisMachine,
} from "mlx-bun";

const reg = new Registry();
await reg.scan();
const m = reg.resolve("12B");
const config = await loadModelConfig(m.path);

const report = fit(config, m.sizeBytes, 8192, thisMachine(), 2048, m.expertsBytes);
console.log(report.fits, report.maxSafeContext, report.predictedDecodeTps);
console.table(skuMatrix(config, m.sizeBytes, 8192, m.expertsBytes));

const machine = thisMachine();
const pick = chooseAutoModel(
  reg.listCanonical(),
  DEFAULT_REPO_ID,
  (c) => c.sizeBytes <= machine.ramBytes * 0.75,
  (c) => c.sizeBytes <= machine.ramBytes * COEXIST_FRACTION,
);
console.log(pick?.repoId);
```

## Serving

`loadContext(modelDir, modelId?, opts?)` builds the `ServerContext` the
server runs on: the `model` (via the same profile resolution as
`openModel`), `profile`, `tokenizer`, `template`, `modelId`, lazily-loaded
vision/audio towers, the `adapters` manager, the model's `kvConfig`,
`genDefaults` from `generation_config.json`, an optional speculative
`draft` provider, and `glmMemoryPlan` for the Colibri runtime. It refuses
models that cannot serve any context within the budget (pre-GPU, mmap-only
check). `LoadContextOptions`: `memoryBudgetBytes`, `glm`
(`Glm52RuntimeOpenOptions`, ignored by other models), and the speculative
decoding trio `draftModelDir` / `numDraftTokens` / `draftKind`
(`"dspark" | "deepspec" | "assistant" | "two-model" | "ngram" | "mtp"`)
plus `ngramMax` / `ngramMin`.

`createServer(ctx, port = 0, serverOptions?)` returns Bun's `Server`
exposing OpenAI chat completions, Anthropic `/v1/messages`, OpenAI
Responses, embeddings, adapters, and `/stats` —
[server-api.md](./server-api.md). `ServerOptions` mirrors the CLI flags in
[server-config.md](./server-config.md): `promptCacheBytes` (byte-capped
LRU, never count-capped), `kvBudgetBytes`, `kvQuant` (`"off" | "config" |
bits`; unset = bf16), `turboQuant`, `pagedKv`, `memoryBudgetBytes`
(admission control — the only OOM defense), `batch`, `hostname`,
`unixSocket`, `owner`, `defaultThinking`, `defaultTemperature` /
`defaultTopP` / `defaultTopK` / `defaultMaxTokens`, `defaultAdapter`, `hlg`,
and the SSD tier (`ssdCacheDir`, `ssdCacheMaxBytes`, `ssdDemoteIdleSec`,
`ssdCacheVerify`).

```ts
import { createServer, loadContext } from "mlx-bun";

const ctx = await loadContext(dir, "my-model", { memoryBudgetBytes: 12e9 });
const server = createServer(ctx, 8080, {
  promptCacheBytes: 2e9,
  kvQuant: "config",             // apply the model's kv_config.json
  memoryBudgetBytes: 12e9,
  owner: "embedded",
});
console.log(server.port);
// … later
server.stop();
```

For GLM-5.2, pass its load-only resource controls under `glm`:

```ts
const glmCtx = await loadContext(glmDir, "glm-5.2", {
  glm: {
    contextTokens: 4096,
    maxGenerationTokens: 128,
    batchSize: 8,
    enableMtp: true,   // default; native MTP routes requests serial+spec
  },
});
```

## Internal pieces referenced above (not exported)

`PromptCache` (`src/prompt-cache.ts`, the byte-capped in-process prefix
cache), `AdapterManager` (`src/lora.ts`, LoRA hot-swap — reachable as
`ctx.adapters` on a `ServerContext`), and `saveKvCache` / `loadKvCache`
(`src/kv-store.ts`, cross-process KV persistence) are deliberately **not**
re-exported from `"mlx-bun"`: they are implementation-level and may change
without notice. In a clone they import from their internal paths; the
`adapters` and `cache` options of `generate` are the public seams they plug
into.

```ts
import { PromptCache } from "./src/prompt-cache";
const cache = new PromptCache(2e9);                   // BYTE-capped LRU
const hit = cache.take(promptIds, /*namespace*/ "");  // longest common prefix, trimmed
const caches = hit?.caches ?? model.makeCache();
const gen = generate(model, promptIds, { cache: caches });
for await (const t of gen) { /* … */ }
cache.put(gen.stats!.cacheTokens, caches, "");        // hand ownership back
```

Namespace entries by adapter spec when LoRA is in play (KV computed under
one adapter must not seed another's prefill).

## Memory & disposal rules

- `MlxArray` wrappers have explicit `.dispose()` with a
  FinalizationRegistry backstop — dispose what you create in hot paths.
- Caches you own (from `model.makeCache()` outside the prompt cache):
  dispose each via `c.dispose()` when done. `Weights` you opened yourself:
  `weights.dispose()`.
- GPU OOM is **uncatchable** (mlx throws from a Metal completion
  handler → process death). Use `fit`/admission before generating, not
  try/catch around it.
- Never read a typed array that native code wrote in a hot path; use
  the `read.*` helpers (bun#32054 — see the Phase 4 findings in the PLAN
  archive: `git show 3199c75:PLAN-archive.md`).
