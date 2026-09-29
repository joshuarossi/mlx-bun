# @mlx-bun/inference

Composable inference components built on [`@mlx-bun/mlx`](../mlx/README.md).
Callers choose artifacts and graphs, own state, and invoke inference directly.
The package includes the existing specialized kernels and graph implementations,
input processing, sampling, generation, embeddings, transcription, and optional execution.

## Contracts and composition

The root API composes the lower layers for loading and generation. Component
subpaths remain available for direct use and custom graphs. See the
[architecture](../../ARCHITECTURE.md) for dependency direction and ownership.

`contracts/portable` contains platform-free inference interfaces and can be consumed
without Bun or MLX types. `contracts/mlx` describes tensor and state interactions
using MLX types. `contracts` exports both. Use the portable entry when sharing
inference output or scheduling types with application and browser code.
Application protocols and job contracts migrate with their owning apps.

Paged attention accepts numerical storage; adapter mounting accepts named LoRA
targets; prompt preparation accepts encoder interfaces. Callers can supply their
own implementations without subclassing a concrete model or cache.

Each graph declares what it can do (`GraphCapabilities`, portable; a model exposes
it as `graphCapabilities`): its method, batched adapters, media input, paged
attention, compiled decode, hidden-layer taps for drafts, a draft head its
checkpoint carries (`nativeDraft`), which delayed affine KV levels its attention is
qualified for, dense reads, and what its verifier qualifies (adapters, logprobs,
affine and TurboQuant KV, external tokens, grammar proposals).
`MlxDeclaredGraph` names the operations behind those promises (`bindMediaInput`,
`mediaEncoders`, `pixelInput`, `draftTarget`, `trainable`, `expertResidency`), and
`declaredGraph` in `models/capabilities` checks the pairing once when composition
binds the graph: an undeclared graph, or a declaration without its operation, is
refused. The gateway plans from the declarations, the request and dynamic state
(batch membership, cache contents, cancellation), and
`MlxGatewayBinding.capabilities` reports what it resolved. Supporting a new graph
means declaring and implementing; `execution/` and the app engine need no edit.
The architecture gate rejects concrete model imports, model-class `instanceof`,
model-type and `architectures` checks, family predicates and model-scoped flags there,
in the app's engine, server and CLI, and in `@mlx-bun/training`. What those need to
know about a model is declared in its profile (`models/profile`:
`embeddingDeclarationFor`, `sentinelDeclarationFor`, `mediaTokenDeclarationFor`,
`generationDefaultsFor`, `chatTemplateFallbackFor`, `trainingDefaultsFor`) or returned
by its opened runtime (`models/runtime`, `models/memory-plan`); token text resolves to
ids against the tokenizer in use (`input/special-tokens`). `trainable`
(`TrainableGraph`) declares what the trainer consumes: the quantized
`lmHead` for fused linear-CE heads, `segmented` backward (how a range of layers
runs and which reused K/V crosses segment boundaries), `prefixShared` forwards,
`gradCheckpoint`, the `flashAttention` constraint, and the `denoising` objective.
The trainer names the declaration a graph lacks. A model-level option stays
with its graph: Qwen3.5 reads `MLX_BUN_QWEN_SPEC_KV4` (on by default) where it
declares speculation over affine KV.

## Numerical and execution policy

The inherited fidelity policy is L1 by default: bit-exact numerics against the
pinned mlx-lm oracle for matching artifacts, inputs, and settings. L2 covers
schemes with a different oracle, including mlx-optiq mixed-KV, and requires
bit-exact comparison to that scheme's reference. Lab paths without an oracle
need numerical/quality evaluation and a paired A/B before becoming defaults.
These are correctness obligations; the outstanding real-weight verification is
tracked in the [refactor plan](../../PLAN.md#verify-the-migrated-library).
They do not make application sampling or serving defaults identical to mlx-lm.

Execution policy treats default memory estimates as advisory. Attempt the
requested work without rejecting it or clamping output tokens solely because
of a predicted memory estimate. Explicit user limits, queue capacity, and actual
layout requirements still apply; release owned resources on failure. Application
composition must preserve this policy when binding the optional execution layer.

### External parity evidence

On 2026-09-24, inference at `5527989` and main at `02d723a` independently matched
the external mlx-lm reference for MiniCPM5-1B-OptiQ-4bit, snapshot
`664aabaed233c653f82716d8dc822234d0091f78`. On an Apple M1 Max with 32 GiB RAM,
macOS 27.0 (26A428), and Bun 1.4.2, all 100 greedy tokens and all 13,056,000
float32 logits were byte-identical; all logits were finite. The prompt was
`The capital of France is` (six matching tokenizer IDs), batch one, default
unquantized KV, with no `MLX_BUN_*` overrides and no EOS early stopping.

The external environment used Python 3.13.5, MLX/MLX-Metal 0.32.2 and mlx-lm
0.31.3. Reference generation used the unchanged Python body from
`02d723a:scripts/regen/minicpm5.ts`; model-file and per-step reference hashes
were checked. The reference manifest SHA-256 is
`e20d64193328d5dfe1c4b9681651730b35b2eeb2f5152b0ae3d8fb50b05dfd5f`.
The [MiniCPM5 parity test](tests/parity/minicpm5-parity.test.ts) is that harness:
public root, model, and scoring imports, forwarding the prompt once and each
selected token thereafter with the same live cache (plain KV from the model).
It requires byte-identical finite logits and the greedy token at all 100 steps.
Opt in with all of `MLX_BUN_TEST_MINICPM5_MODEL`, `MLX_BUN_TEST_MINICPM5_REFERENCE`
(the directory holding `minicpm5-parity.json` and the 100 step blobs) and
`MLX_BUN_TEST_MINICPM5_REFERENCE_SHA256`; absent all three it skips, any other
combination fails. Before native libraries load it verifies the manifest hash, the
pinned model files and shards by content (relocated copies pass) and every blob;
the runtime must match the reference's MLX version and GPU architecture.
This covers that path only, not other models, batching, quantized KV,
snapshot restore, long contexts, or speed. Raw outputs and the reference
remain external; Python is not a project dependency.

The [Gemma4 parity test](tests/parity/gemma4-parity.test.ts) restores main's
Gemma4 12B OptiQ-4bit oracle consumer on the same terms (batch one, plain KV
from the model's `makeCache`, the artifact's `kv_config.json` not applied). Its
reference is main's `scripts/regen/parity.ts` output: the prompt
`The capital of France is`, 100 greedy IDs and the first four full-vocabulary
float32 vectors. Through `createModel` it checks the 100-token greedy trajectory
and those four vectors byte for byte; a separate 12-step control does the same
through `new Gemma4Model`. Every step must be finite and select the reference
token. This is not 100-step full-vector parity. For this artifact `createModel`
selects the generated 12B graph, whose unrolled path serves only the quantized
`kv_config` cache layout; under plain KV it runs its monolith fallback, and the
test asserts the unrolled path never ran. Opt in with all of
`MLX_BUN_TEST_GEMMA4_MODEL`, `MLX_BUN_TEST_GEMMA4_REFERENCE` (the directory
holding `gemma4-parity.json`, the producer's unchanged `parity.json` and the four
step blobs) and `MLX_BUN_TEST_GEMMA4_REFERENCE_SHA256`. Before native libraries
load it verifies the manifest hash; the producer provenance (script hash, main
revision, installed mlx, mlx-lm and mlx-optiq source hashes and versions, and the
pinned `parity.json`, which must agree with the manifest); the tokenizer, config,
index and exactly its shards by content; and every blob. The runtime must match
the reference's MLX version and GPU architecture. Main's retained capture
(`02d723a:goldens/apple-m1-max/parity.json`) has no tokenizer, index, shard or
producer-source pins, so it cannot qualify. The reviewed run in
[#202](https://github.com/joshuarossi/mlx-bun/pull/202) used a fresh, fully pinned
capture from main `02d723a` and passed both consumer paths at `e7288425` on an
Apple M1 Max (MLX 0.32.2, mlx-lm 0.31.3), with input pins unchanged. This qualifies
the plain-KV scope above; the generated graph's unrolled `kv_config` path and
performance remain separate checks.

The [generated-graph test](tests/parity/gemma4-generated.test.ts) is that
unrolled-path check, ported from `02d723a:tests/parity/generated-parity.test.ts`
for each registered fingerprint (12B, e4b, 26B-A4B). With
`MLX_BUN_TEST_GENERATED_MODEL` naming an artifact that ships `kv_config.json`, it
requires `createModel` to select the generated graph, byte-identical vectors
against `new Gemma4Model` over caches converted to `kv_config` before a prompt past
the sliding window, identical 24-token greedy trajectories (stop tokens off, so
every trajectory is full length) uncompiled and with compiled decode (counting
generated forwards), and the monolith fallback under plain caches. This is
specialization identity within this tree, not an oracle claim. On 2026-09-28 it
passed on the M1 Max for mlx-community gemma-4-e4b-it-OptiQ-4bit (`98d7dc6a`; 24
generated forwards uncompiled, 2 compiled) and gemma-4-12B-it-OptiQ-4bit
(`5b110106`; 24 uncompiled, 1 compiled). The 26B-A4B cell was not run. A final
cell runs two different rows through one forward over `kv_config` caches and
requires bytes equal to the monolith's; it caught the committed e4b graph slicing
its per-layer inputs for one row, and passes on e4b and 12B after regeneration
(2026-09-29, M1 Max).

The generated files are compiled from the model description by
`bun packages/inference/scripts/gen-gemma4.ts <model-dir> <stem> --help`
(`gemma4-12b`, `gemma4-e4b`, `gemma4-26b`), which reads `config.json`,
`kv_config.json` and the index's tensor names, never weights. A change to
`Gemma4Model`, its layers or the generator is a regeneration, not a hand edit.
[`tests/models/gemma4-generated-sync.test.ts`](tests/models/gemma4-generated-sync.test.ts)
regenerates all three from the committed inputs in `tests/fixtures/gemma4-graphs`
(stripped hub-layout copies of the three snapshots) and fails when a committed
file differs; it does not say the regenerated graph is numerically right, which
is the real-weight test above.

On 2026-09-27 UTC, the rotating live-window correction (source `5ec1f4ae`) was
checked on the same M1 Max (MLX 0.32.2, pinned native library) against selections
made independently of `temporalView`, main `02d723a`, and pinned optiq 0.2.7.
Gemma4 e2b and a custom graph over unchanged Llama-3.2-3B weights (alternating
sliding layers, window 8; not a published model) matched main's B1 logits byte for
byte in 13 cases. In 14 late-join and initial two-row cases, at both tail-split
settings, every projection, token and valid state equaled the same batching code
reading rows through the independent selection, and merged rows equaled their own
B1 state; before the correction, late joins without a tail split and initial
two-row batches merged the oldest window. Gemma4 e4b donor attention (plain and
affine) and the deterministic assistant-drafter chain
(`gemma-4-E4B-it-assistant-bf16` `844e008e`) equaled their independent references
byte for byte through prefill, a verify block, a rollback and a decode; below the
window the chain equaled main's. For DiffusionGemma 26B-A4B with a 1,500-token
prompt, the decoder-selected encoder K/V of all 30 layers and the full first-pass
logits equaled the pinned optiq reference byte for byte, and the opt-in real-weight
test passed with measured main references. This covers these paths only, not
stochastic speculative verification, other models, performance or full-candidate
qualification. Raw evidence remains external.

Three opt-in consumers repeat these checks. The
[rotating-join test](tests/execution/rotating-join.test.ts) takes
`MLX_BUN_TEST_ROTATING_JOIN_MODEL` (a Gemma4 artifact with sliding layers) and, for a
custom graph over a Llama-family artifact's unchanged weights,
`MLX_BUN_TEST_ROTATING_JOIN_WINDOW`; it runs late joins and two-row preparation with
the prompt tail split off and on, each against the same run reading rows through an
independent newest-window selection, and compares merged rows with their solo state.
The [Gemma4 assistant test](tests/parity/gemma4-assistant.test.ts) takes
`MLX_BUN_TEST_ASSISTANT_TARGET` and `MLX_BUN_TEST_ASSISTANT_DRAFT` and compares donor
attention and deterministic draft chains with independently selected donors past the
window. Its separate generation consumer uses the real assistant provider at B1,
depth 2, with plain KV below the sliding window, and compares greedy output with
ordinary generation. It checks complete forward blocks and retained K/V against independent direct-graph replay, including
acceptance, rejection and continuation; this is not main or external-oracle parity.
On 2026-09-27 UTC, this consumer passed at `9be1c241` on an M1 Max with 32 GiB
(macOS 27.0, Bun 1.4.2), using e4b `98d7dc6a` and assistant `844e008e`. Its 67
output tokens matched ordinary generation; 44 rounds included 24 accepted
proposals and 39 genuine target-disagreement rounds. All 45 forward blocks and
the retained state matched the direct replay byte for byte. This does not qualify
B>1, persistence or performance. Captures and their content pins remain external.
The [DiffusionGemma window test](tests/parity/diffusion-gemma-window.test.ts)
takes `MLX_BUN_TEST_DIFFUSION_WINDOW_MODEL`, `MLX_BUN_TEST_DIFFUSION_WINDOW_REFERENCE`
(a directory holding `manifest.json` and raw tensors, produced outside this
repository) and `MLX_BUN_TEST_DIFFUSION_WINDOW_REFERENCE_SHA256`; the manifest pins
the inputs, artifact files, producing runtime and every tensor. The artifact, inputs,
geometry and reference tensors are verified before native libraries load; the
producing runtime (MLX version, GPU architecture) is checked right after the native
import, and each produced tensor's shape and dtype before its bytes. Each of these
tests skips only when none of its settings is present.


### Speech and embedding parity

Three opt-in consumers, ported from main `02d723a`, compare Whisper, Silero VAD and
Qwen3-Embedding with real weights against both the external oracle and main.
They skip only when none of their settings is present; any other combination
fails, and every reference and model pin is verified before native libraries load.
The oracle producers are main's unchanged scripts, run outside this repository in
their own environments: `scripts/oracle/gen-whisper-golden.py` and
`gen-silero-golden.py` (mlx-whisper 0.4.3 and silero-vad 6.2.1, MLX 0.32.2, in
`~/Code/mlx-whisper-oracle/.venv`) and `gen-qwen3-embed-golden.py` (mlx-lm 0.31.3,
MLX 0.32.2, `~/Code/mlx-lm/.venv-mlx-0.32.2-macos14`). The main side is
[`scripts/main-speech-reference.ts`](scripts/main-speech-reference.ts), run from a
main checkout (`whisper`, `vad` and `embed` commands; see its header): it imports
main's own modules by path, changes nothing there, and writes JSON outside this
repository. Nothing produced is committed.

- [Whisper](tests/parity/whisper-parity.test.ts): `MLX_BUN_TEST_WHISPER_MODEL`
  (the mlx-community snapshot), `_AUDIO` (speech-fox.wav and jfk.wav), `_REFERENCE`
  (the oracle's `whisper.json` and blobs plus `main-whisper.json`),
  `_REFERENCE_SHA256` and `_MAIN_SHA256`. Against the oracle: mel and window-0
  encoder output bit for bit, window-0 per-step logits bit for bit on the faithful
  graph, identical transcripts, segment tokens, timestamps and seeks. Against main:
  whole results and encoder hashes identical for the faithful and the fast path,
  greedy and beam 5, word timestamps and a run fed one second at a time. The fast
  path is held to the oracle within two tokens per clip, the bound main recorded.
  The openai/whisper-large-v3-turbo tokenizer must be in the Hugging Face cache.
- [Silero VAD](tests/parity/silero-vad-parity.test.ts): `MLX_BUN_TEST_VAD_MODEL`
  (`ggml-silero-v6.2.0.bin`), `_AUDIO` (adds chirp-1s6.wav), `_REFERENCE`
  (`silero-vad.json` and `main-vad.json`), `_REFERENCE_SHA256`, `_MAIN_SHA256`.
  Probabilities against the torch reference within 5e-3 (the ggml weights are fp16)
  and identical segments under both parameter sets; against main, probabilities,
  100 ms-streamed probabilities and segments bit for bit. The oracle's noise clip
  uses numpy's generator and is not compared.
- [Qwen3-Embedding](tests/parity/embedding-parity.test.ts): `MLX_BUN_TEST_EMBED_MODEL`,
  `_REFERENCE` (`meta.json`, `hidden.bin`, `pooled.bin`, `main-embed.json`),
  `_REFERENCE_SHA256`, `_MAIN_SHA256`. Hidden states and the pooled vector for the
  oracle's ids bit for bit, the tokenizer's ids equal to the oracle's, and `embedMany`
  vectors and token counts bit for bit with main for four texts, raw and with a
  query instruction; it also checks the embed call counter.

The app repeats the served surfaces with the same references.
[`transcription-parity.test.ts`](../../apps/mlx-bun/tests/engine/transcription-parity.test.ts)
(`MLX_BUN_TEST_NATIVE=1`, `MLX_BUN_APP_TEST_WHISPER_MODEL`, `MLX_BUN_TEST_WHISPER_AUDIO`,
`_REFERENCE`, `_REFERENCE_SHA256`) requires the transcription-only server's
transcripts to equal the oracle's for the same audio across multipart and JSON
requests, beam search with vocabulary, SRT, translation, event streaming, VAD-gated
sessions and the error path. [`embeddings-parity.test.ts`](../../apps/mlx-bun/tests/engine/embeddings-parity.test.ts)
(`MLX_BUN_APP_TEST_EMBED_MODEL` and the embedding references) requires `/v1/embeddings`
to return the oracle's and main's vectors bit for bit. The
[voice test](../../apps/mlx-bun/tests/engine/voice.test.ts) covers the CLIs and the
chat-server companion on synthesized speech at word level.

On 2026-09-29 all of these passed on an Apple M1 Max with 32 GiB, macOS 27.0.1
(26A434), Bun 1.4.2, native MLX 0.32.2, with this tree on `e878baaa` plus the tests
above and main at `02d723a`. Whisper: 36 of 36 (7 oracle cases, 21 main runs,
3 clips), including every mel, encoder output and per-step logit vector bit for bit
with the oracle; the fast path differed from the oracle by 0 tokens except 2 on
`long-noprev-en` (the recorded bound), and fast and faithful beam 5 agreed exactly.
VAD: 4 of 4 clips; the largest difference from torch was 2.8e-3 (jfk) and main matched
bit for bit. Embedding: 4 of 4; 35,840 hidden values and 2,560 pooled values identical
to mlx-lm, and main's vectors identical. App: 6 of 6 transcription and 3 of 3 embedding
route tests. Artifacts: whisper-large-v3-turbo `a4aaeec0` (weights SHA-256
`951ed3fc1203e6a62467abb2144a96ce7eafca8fa77e3704fdb8635ff3e7f8a6`), tokenizer from
openai/whisper-large-v3-turbo `41f01f3f`, Silero `ggml-silero-v6.2.0.bin` (SHA-256
`2aa269b785eeb53a82983a20501ddf7c1d9c48e33ab63a41391ac6c9f7fb6987`),
Qwen3-Embedding-4B-4bit-DWQ `b5d88f1f` (weights SHA-256
`cd373d0bc76a3464a69b036ac6beca217a0d668bdf901ff3b05a7d7997d2d607`). Reference
SHA-256s: whisper.json `348fb1ff2097f6b9b57b236293a67fd6da7c5eedaa886f793866eaba4a0aa965`,
main-whisper.json `e307ac92f636ac03a4ae95c39b8a1ae5d1cb09c6b42644a79979205281037a67`,
silero-vad.json `e961872b71f458894658f2f43c2eab6112c4517edaa9f49f5ff8fbc500460a51`,
main-vad.json `f9194f6d70c030f59f95e049b39e019c658e6486e75c274e79a96c830650a38d`,
meta.json `cb63915245d57da88f7df0ac088fd19ac249bcebd1829e4b25840163cf9059b3`,
main-embed.json `85e13387bda46cf9c2aff8181b8dc575cce926a5bf90ff5293211287412f08a1`.
Inputs were main's `speech-fox.wav` and `chirp-1s6.wav` fixtures and whisper.cpp's
`jfk.wav`; the mel comparison confirms the same samples. A deliberate change of the
attention scale made 13 Whisper tests fail, so the comparisons discriminate.
This covers these checkpoints and clips only: no other Whisper size, no non-WAV
input (AudioToolbox decoding), no oracle for word timestamps or the streaming run
(main only), no Whisper batching, and no performance. Raw references remain external.

### Repeatable runtime comparison

The source-checkout tool `bun packages/inference/scripts/runtime-oracle.ts --help`
explains the plan schema and `emit`/`compare` commands. It hashes complete logits,
live cache planes and one-token continuation; `compare` is CPU-only. Supply local
weights and external reference reports. No Python environment or reference data
is installed by this repository. The opt-in test uses `MLX_BUN_PARITY_PLAN` and
`MLX_BUN_PARITY_REFERENCE`; it skips only when none of its settings (those two,
`MLX_BUN_PARITY_TIMEOUT_MS`, `MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG`,
`MLX_BUN_PARITY_REFERENCE_SHA256`) is set, and a partial or blank opt-in fails.
`MLX_BUN_PARITY_REFERENCE_SHA256` pins a published reference revision: the report's
bytes must match before the worker starts. Legacy reports require explicit
`--allow-unrecorded-config` (test: `MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG=1`), after
verifying their environment separately. New reports record runtime overrides,
source/harness/native hashes, machine and plan; `--hash-weights` adds weight hashes.

The same consumer covers Qwen Trellis and Gemma; no such run is recorded yet.
Produce references outside this repository with the unchanged producers at main
`02d723a`, sequentially on the comparison machine. Stock mlx-lm architectures
(Gemma4 e2b/e4b/26B-A4B, Gemma2, Llama, MiniCPM5) use
`MLX_BUN_TEST_RUNTIME_ORACLE=1 HF_HUB_OFFLINE=1 python scripts/oracle/check-runtime.py plan.json reference.json`
in the pinned oracle environment; it registers no OptiQ architectures, so the 12B
`gemma4_unified` artifact keeps its dedicated consumer above. Packed Qwen Trellis
has no external oracle (mlx-lm cannot load it), so main is the reference:
`MLX_BUN_TEST_RUNTIME_ORACLE=1 MLX_BUN_COMPILED_DECODE=0 bun --no-env-file tests/support/runtime-oracle-worker.ts plan.json reference.json`
in the main checkout. Neither producer records provenance or applies `kv`, so
compare plain-KV plans with the legacy acceptance and pin the report:
`MLX_BUN_COMPILED_DECODE=0 MLX_BUN_PARITY_PLAN=plan.json MLX_BUN_PARITY_REFERENCE=reference.json MLX_BUN_PARITY_REFERENCE_SHA256=<sha256> MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG=1 bun --no-env-file test packages/inference/tests/parity/runtime-oracle.test.ts`.
Useful plans keep main's IDs and vary geometry: for Trellis, contexts 0/64/512 ×
lengths 1/3/4/8/16/128 with prefix chunk 256 cover the M≤4, M5–15 and M≥16
dispatch profiles; for Gemma4 e2b/e4b, a context past the 512-token window (for
example 0/64/600 × 1/8/128, chunk 128) covers sliding-window wrap; for MiniCPM5
beyond the recorded cases, a longer multi-chunk context with `restore: true` adds
persisted-state continuation. Mixed KV (`kv: "artifact"`) has no reference producer
until the mixed-KV reference contract in [PLAN](../../PLAN.md#verify-the-migrated-library)
is confirmed.

On 2026-09-25 UTC, `6b0fd69` matched main `02d723a` and its unchanged external
`02d723a:scripts/oracle/check-runtime.py` for the same MiniCPM snapshot above. All nine
cases (contexts 0/64/320 × append lengths 1/8/128, prefix chunk 128, batch one)
matched bit-for-bit for full logits, prefix/append state and continuation logits/state.
The machine was the same M1 Max; Python was 3.14.5, MLX/MLX-Metal 0.32.2,
mlx-lm 0.31.3. Runtime overrides were only `MLX_BUN_COMPILED_DECODE=0` and
`MLX_BUN_TEST_RUNTIME_ORACLE=1`; references ran sequentially with HF offline.
The weight SHA-256 was
`88bb686ed4a28f7c2065e27aabef7669f84961ac47c83efe2d003436c179e2e4`;
the Python report SHA-256 was
`bc034fd8f6aec39ec9f90c1aeeed1caed713efc58453e85f4cfc32b6046c86d5`.
This covers plain KV and chunked prefix continuation, not mixed KV, saved-state
restoration, compiled decode, sliding-window wrap, other families or performance.
Raw reports remain outside Git; the broader PLAN verification item stays open.

The plan can additionally request `kv: "artifact"` for the checkpoint's existing
mixed-KV policy and `restore: true` for persisted state and continuation checks.
Conversion happens after each forward, never on empty state. Restore verifies
tensor integrity, the saved token prefix, live planes and continuation against
the uninterrupted path; it does not restore sampling or execution sessions.
Temporary checkpoints are removed after each case.

Oracle goldens and recorded comparisons are published outside this repository;
run the tool against a pinned golden revision or regenerate one. A mixed-KV
comparison must use the documented per-path composition (stock mlx-lm attention
for one query, OptiQ tiled attention for multi-query input), not every default of
`optiq serve`, whose fused install also changes single-query decode.

### Compiled decode verification

The opt-in `tests/parity/compiled-decode.test.ts` accepts local checkpoint paths
through `MLX_BUN_COMPILED_GEMMA_E4B` and `MLX_BUN_COMPILED_GEMMA12B`. Run it with
`bun --no-env-file test packages/inference/tests/parity/compiled-decode.test.ts`
from the root. Each unset path skips that family; a supplied invalid path fails.
The checkpoints must include their existing mixed-KV configuration. No model or
reference data is downloaded.

The test compares native full-logit bytes for identical fixed tokens with plain
and artifact-configured KV, both before and after the sliding window fills.
Greedy trajectories and dense Gemma's mid-segment failure recovery use main's
original tokenizer-rendered prompts (12B targets 600/1100 tokens; e4b targets 700).
Those checks require actual compiled-step activation and zero unexpected retraces.
The forced-token full-logit matrix uses deterministic IDs independently of EOS. These are
compiled-versus-ordinary checks, not an external-oracle or performance claim.
Runtime compilation overrides stay inside the test; this adds no application option.


### Scheduler continuation and specialized-path checks

The opt-in [continuation test](tests/parity/ordinary-continuation.test.ts) takes
`MLX_BUN_TEST_CONTINUATION_MODEL=/cached/checkpoint`. It compares uninterrupted
and interrupted/restarted B1/B4 generation, including pending tokens, seeded
sampling history, byte-identical checkpoint planes, and actual restored-row
counts. `MLX_BUN_TEST_CONTINUATION_ADAPTER=/cached/adapter` adds adapter-context
and cache-namespace isolation without bundled fixtures; with it,
`MLX_BUN_TEST_CONTINUATION_IGNORED_DRAFT=1` binds a two-model draft whose rows
fail if opened and requires the adapter rows to match a draftless adapter
control, tokens and checkpoint planes. The existing KV matrix
uses `MLX_BUN_TEST_CONTINUATION_KV=bf16|4|8|per-layer|turbo`,
`MLX_BUN_TEST_CONTINUATION_KV_START=0` (or `prompt+N`), and
`MLX_BUN_TEST_CONTINUATION_INTERRUPT=6` (6–15).
The test uses the actual capability planner. With an adapter and positive affine
start it also checks grouped admission, an event-driven late join, cancellation
against a matched stop control, queued base-context isolation and reuse after
drain. Mounting must change full logits, and unmounting must restore the base.
Full-attention universal graphs accept ordinary adapter requests with uniform
or per-layer delayed affine KV and adapter-aware continuation. Paired B1
Qwen2.5-0.5B acceptance without a configured draft matched main for uniform
KV4/KV8 and partial mixed KV, greedy/seeded sampling, and fresh-process
continuation before and after conversion: full logits, every valid cache plane,
adapter identity and unmount restoration. Separate candidate B2/B4 tests without
a configured draft passed joins, cancellation, queued adapter/base isolation
and reuse after drain.

Gemma4 adapter rows also take ordinary generation checkpoints when the server's
paging option is enabled: the resolved row uses plain KV, so checkpoint identity
and continuation are the same with paging enabled or disabled. Paired B1 checks
on Gemma4 e2b OptiQ-4bit (snapshot `b0162532`, MacBookPro18,2, MLX 0.32.2)
matched main `02d723a` at capacity 1 against continuous capacity 8 for 16 tokens,
greedy and seeded sampling, and fresh-process restoration across both settings.
Full logits and all 15 donor KV states matched; all 35 layer outputs and the
final norm matched by hash. The nonzero adapter changed logits and unmounting
restored the base. Actual paged rows remained checkpoint-ineligible. This covers
one active row within the sliding window, not grouped rows, paged numerics,
hard-kill durability, external-oracle parity or performance.

An adapter request whose draft cannot serve target adapters (the two-model
provider on any graph; any provider on a softcap graph, which never speculates
with adapters) decodes ordinarily, ignores the draft and, without fill, grammar
or logprobs, takes generation checkpoints like a draftless adapter request.
The continuation test's ignored-draft opt-in passed with a synthetic nonzero
q/v adapter on gemma-2-2b-it-4bit (with fresh-process restore) and on
Llama-3.2-3B-Instruct-4bit with a custom 4-token window (M1 Max, bf16 KV).

With `MLX_BUN_TEST_CONTINUATION_KV=turbo`, every saved and restored checkpoint
after conversion (immediately with a start of 0) must hold TurboQuant's exact
inventory: five encoded planes per full-attention cache (K indices, float16 K
scales and zeros per 32-wide group, packed uint8 V, float16 V scales) at the
scheme's bits, the fused decode when `MLX_BUN_TURBOQUANT_FUSED_DECODE` is unset,
a plain ring per sliding cache, every KV layer at the checkpoint's offset, and
no reuse floor with a start of 0. Before a positive start converts, checkpoints
are still plain. Paired B1 checks on Gemma4
e4b OptiQ-4bit (snapshot `98d7dc6a`, MacBookPro18,2, MLX 0.32.2) with
server-wide TurboQuant k8v3 from token 0 matched main `02d723a` through each
side's continuous gateway at capacity 8 for 16 tokens, greedy and seeded
sampling: full logits, all 42 layer outputs and the final norm by hash, and all
24 donor states at every forward (20 plain sliding rings; the 4 full donors
plain on the prefill forward and TurboQuant, all five planes, from the next),
checkpoint saves at 4, 8 and 12, an interruption at 10 and a fresh-process
resume from the durable record at 8. Within this tree, the continuation test
passed on the same artifact at B1 and B4 with TurboQuant from token 0: seeded
sampling (temperature 0.7, seed 42 plus the row, repetition penalty 1.1) for
16 tokens, interrupted at 6 with durable checkpoints at 4, then restored in the
same process and in a fresh one; every restored record held 12 tokens over 24
caches of 2 or 5 planes. The main-paired evidence is B1 only; a wrapped sliding
ring, a delayed TurboQuant start, hard-kill durability, external-oracle parity
and performance are not claimed.

MiniCPM5 and these universal graphs also ignore a configured draft and supplied
fill for adapter requests, as main did; requested logprobs remain available.
Without fill/logprobs/grammar, ordinary checkpoints remain eligible. The fallback
does not invoke the provider during a request; loading an artifact-backed draft
still performs its existing compatibility probe. Paired B1 acceptance on cached
Qwen2.5-0.5B and MiniCPM5-1B compared six scenarios per model, each with a matched
draftless adapter control, over 16 generated tokens. The scenarios cover
TwoModel and Ngram, uniform KV4/KV8 and partial mixed KV, ignored strict/verify/echo
fill, requested logprobs, and greedy or seeded sampling. Full logits and all valid
KV planes matched main and controls; request-time draft/fill counters stayed zero,
nonzero adapters changed logits, and physical unmount restored base logits.
The no-fill scenarios retained plain or encoded checkpoints and matched
uninterrupted output after graceful cancellation and fresh-process restoration.
This does not qualify every combination or multi-row configured-draft requests.

Only the first cold decode/resume token may have signed versus unsigned int32
metadata; its raw bytes, value and computed state must match exactly. Supplied
fill also falls back to ordinary decoding without adapters or a configured draft:
main ignored it on these graphs because no affine append binding exists.
Paired B1 acceptance on cached MiniCPM5-1B and Qwen2.5-0.5B matched main and
no-fill controls for supplied strict/echo fill, unseeded greedy sampling and
KV4 starting at token 8. Each request generated 16 tokens across conversion;
all 17 forward states, 16 full-vocabulary projections and valid cache planes
matched, and every fill hook stayed unused. Main planned fill and disabled it
inside generation; the new planner reports `fill-incompatible-with-request`
and selects ordinary continuous decoding. This pair does not qualify B2 or
cancellation.
Requests that supply fill remain ineligible for generation checkpoints. Actual
delayed speculation remains excluded. Each graph declares at construction the
layers its attention reads as plain keys and values (`requiredDenseKvLayers`:
Gemma2's softcap layers; none for graphs that attend the storage their caches
hold). The gateway and a directly composed
batch group each bind that declaration once against the graph's fresh caches;
an absent or malformed declaration is refused rather than read as none. A row
whose next append would not read plain in a declared layer is refused with
`DenseKvReadError` before that append. A graph whose attention reads dense KV
(a softcap graph such as Gemma2, reading keys and values as arrays) admits a KV
scheme when that scheme's own maintenance leaves every layer's storage certified
for dense reads (`Cache.denseKvReads`, answered by the storage and the
maintenance that owns it, probed when the binding or group is composed). Affine
KV serves ordinary continuous decoding, with checkpoints, while each row's
storage still reads plain; on a softcap graph a drafted request ignores the
draft. At a row's actual transition its pending token publishes first, and the
row may finish there; otherwise that row alone is rejected with `DenseKvReadError` before any shared append (HTTP 501
`unsupported_kv_transition`, or the stream's error event once it has opened).
Main's serial path threw at that forward instead. TurboQuant storage decodes on
read, so these graphs admit TurboQuant KV for ordinary continuous decoding
throughout, with checkpoints; a drafted request ignores the draft. Supplied
fill decodes ordinarily without fill, as in main, whose serial path filled
only through a committed append declaring the scheme's formats (none for
TurboQuant on this graph). Direct grammar jump commits its
spans over it through the shared span method, as main's serial jump did: one
maintenance call, then one unsplit forward of the pending token and the forced
span, once the gateway has certified the scheme. Affine KV commits spans the
same way while a row's storage still reads plain: a span whose maintenance ran
before the transition appends unsplit even across it, and a row whose next
append would no longer read plain is refused with `DenseKvReadError` before any
layer appends, where direct generation fails in that forward. The span method
binds the graph's dense-read layers explicitly; the gateway supplies the
graph's own declaration. On 2026-09-28 UTC (M1 Max, MLX 0.32.2) the opt-in
`tests/parity/affine-grammar-spans.test.ts` (`MLX_BUN_TEST_AFFINE_SPANS_MODEL`)
passed on cached Gemma2-2B-4bit `2c715097` with KV4: below the transition, B1
spans matched direct jump-forward generation in tokens, matcher history and
every projection's bytes; a row crossing it was refused with the same published
tokens and matcher history; an interleaved peer matched its solo run and the
group served again.

On 2026-09-28 UTC, cached Gemma2-2B-4bit snapshot `2c715097` (26 full-attention
layers) passed bounded TurboQuant k8v3 acceptance on an M1 Max, MLX 0.32.2 and
Bun 1.4.2. [#210](https://github.com/joshuarossi/mlx-bun/pull/210) qualified
ordinary decoding, fresh-process continuation and HTTP cancellation/recovery
against main, with separate same-geometry candidate batching controls.
[#212](https://github.com/joshuarossi/mlx-bun/pull/212), tested at `e783c7b4`,
matched main `02d723a` byte for byte in full-vocabulary logits and all valid cache
planes for immediate and delayed conversion with real choice/JSON grammars.
The checks cover unsplit forced spans followed by sampling, callback stop within
a committed span, actual prefix reuse with conversion before the suffix,
cancellation with an active peer, and same-scheduler recovery. Graph calls remain
B1 and interleaved; this does not qualify stacked B2 grammar numerics, other
artifacts, an external TurboQuant oracle or performance. Captures and input pins
remain outside Git.

Universal graphs
with sliding layers take the same ordinary delayed path when their bound
attention reads encoded KV. Qwen3 and Qwen3-MoE attend affine KV as mlx-lm's
`scaled_dot_product_attention` does (quantized SDPA over a quantized cache) and
take the same encoded-read path: immediate affine KV batches and speculates,
and delayed affine rows serve ordinary decoding, generation checkpoints and
committed grammar spans across their conversion. On 2026-09-28 UTC (M1 Max,
MLX 0.32.2), cached Qwen3-4B-Instruct-2507-4bit `50d42775` matched mlx-lm
0.31.3's `generate_step` order bit for bit in six greedy steps' full logits
through direct generation with KV8 and KV4 at starts 0, 8 and 14 (a one-off
comparison); the opt-in spans test and the ordinary-continuation test (KV8 from
0, KV4 from prompt+4, KV8 from prompt+2) passed on it; and a grouped n-gram
draft over immediate KV8 and KV4 reproduced ordinary greedy output. No
Qwen3-MoE artifact was run.
On encoded-read universal graphs and on MiniCPM5, delayed affine
rows stay ordinary-only, and their direct grammar jump commits spans through the
same span method with no dense-read requirement, before and after conversion.
The same opt-in real-weight spans test passed on cached MiniCPM5-1B-OptiQ-4bit
`664aabae` and Qwen2.5-0.5B-Instruct-4bit `a5339a41` with KV4: B1 spans matched
direct generation in tokens, matcher history and every projection's bytes, both
below the transition and for a row converting three tokens into decode and
continuing over converted layers; an interleaved peer matched its solo run. On 2026-09-27 UTC (M1 Max, MLX 0.32.2) at `a9b60646`,
a custom graph over unchanged Llama-3.2-3B-Instruct-4bit weights with window 8
(not a published model) matched main's serial path at B1 in full logits and all
valid cache planes for bf16, immediate affine, KV4 and KV8 converting in decode
after the ring wrapped, and KV4 converting in prefill at token 32. Gateway and
direct execution agreed at B1 and B2, with rows converting separately, a
prefill-converted joiner, a cancelled row's survivor and same-group reuse
matching a fresh group; the continuation test restored B1 and B4 rows in a
fresh process for KV4 and KV8. Gemma4's delayed rotating rows share the
single-row adoption: on e4b OptiQ-4bit, one-block and wrapped singletons matched
main's serial path through conversion (hidden states, logits, valid planes and
physical ring order), as did the speculative target layout and two rows in both
orders at the same batch width; main-produced wrapped checkpoints loaded into
both trees gave identical adoption and continuation, and RAM and disk restores
agreed. A restored wrapped ring's continuation can still differ from the live
one ([State and attention](#state-and-attention)). Captures and their content
pins remain external. These checks do not cover cross-version checkpoint
files, hard-kill durability, an external oracle or performance.

Grammar, grammar proposals and supplied fill on these graphs have a separate
opt-in consumer, the
[sliding-window grammar and fill test](tests/parity/sliding-grammar-fill.test.ts).
It takes `MLX_BUN_TEST_SLIDING_GRAMMAR_FILL_MODEL` (a Llama-family artifact) and
`MLX_BUN_TEST_SLIDING_GRAMMAR_FILL_WINDOW` (at least 4) and builds the same custom
graph as the rotating-join and continuation consumers. The reference is this
tree's direct token-by-token generation; the gateway runs its placement path
(plan, `methodRequest` or row sampling, the binding's group), with every case past
the window:
- Grammar (JSON schema, choice, EBNF): at B1, tokens, every forward's IDs and
  valid K/V, and every projection's complete logits. At B2, prepared together
  or joining late, each row's tokens.
- With `MLX_BUN_GRAMMAR_JUMP=1`: the speculative group verifies the matcher's
  forced string instead of committing it. Tokens equal direct token-by-token
  generation at B1 and B2, rejected proposals leave the ring, and proposals are
  both accepted and rejected.
- Supplied strict and echo fill is applied through the shared fill binding and
  by direct `generate`: strict rows restate the fill-off control, and echo and
  scripted proposals (one accepted, one rejected after the ring wrapped) are
  verified, so output equals the control while the session records injected and
  accepted tokens. B2 pairs start together and late (a strict row joining beside
  a wrapped echo row, whose first multi-position verify forward reads a ring the
  joiner's one in-place write has rotated).
- For each of these shapes: a B2 row cancelled at its third token beside a
  surviving peer, then reuse of the drained group.

Run it with
`MLX_BUN_TEST_SLIDING_GRAMMAR_FILL_MODEL=/Llama-3.2-3B-Instruct-4bit MLX_BUN_TEST_SLIDING_GRAMMAR_FILL_WINDOW=8 bun --no-env-file test packages/inference/tests/parity/sliding-grammar-fill.test.ts`.

The [padded-prefill test](tests/parity/padded-prefill-model.test.ts) takes
`MLX_BUN_TEST_PADDED_PREFILL_MODEL` and `MLX_BUN_TEST_PADDED_PREFILL_REFERENCE`.
The external JSON report is `{ runtime, configSha256, rows }`, where `rows` is
the output of the unchanged Python body in
[`02d723a:tests/parity/padded-prefill-model.test.ts` lines 9–56](https://github.com/joshuarossi/mlx-bun/blob/02d723a/tests/parity/padded-prefill-model.test.ts#L9-L56): prompts, padding side, chunk counts,
recurrent-state hashes, four per-row logit hashes, and row offsets. The test
requires all 18 cases (36 with `MLX_BUN_TEST_PADDED_PREFILL_WIDE=1`), then compares
the full-vocabulary float32 logit slice at the last prompt position for each row
and each of three continuation steps via SHA-256, plus recurrent state.
`runtime` is the MLX core version (for example, `0.32.2`), not the mlx-lm version. Generate the reference outside this repository on the same machine with
the pinned oracle and identical weights; this test never starts Python.
`MLX_BUN_TEST_PADDED_FULL_LAYOUT=affine|turbo`,
`MLX_BUN_TEST_SPECULATIVE_ROTATING_LAYOUT=1`, or
`MLX_BUN_TEST_PADDED_ROTATING_LAYOUT=1` exercise the corresponding pre-conversion
cache layouts against the same plain-KV reference, not quantized arithmetic.

The [Gemma2 batching test](tests/models/universal/gemma2-batching.test.ts) runs
synthetic mask checks with `MLX_BUN_GEMMA2_NATIVE=1`; add
`MLX_BUN_GEMMA2_MODEL=/cached/gemma2` for real B1/B2/B4 continuous lifecycle checks.
Supplying a model or reference without the native opt-in, a reference without a
model, or an invalid model config fails before native initialization.
`MLX_BUN_GEMMA2_REFERENCE=/external/report.json` adds full-logit and KV hashes
against same-shaped pinned Python runs. The reference uses upstream Gemma2
and `BatchKVCache`, adding only a GQA axis to the upstream row mask. B1 is
compared exactly with direct execution; B>1 uses the same-shaped reference,
since quantized matmul dispatch can change numerical results across batch sizes.
The app gateway's real Gemma2 placement test uses the same
`MLX_BUN_GEMMA2_NATIVE=1` opt-in: importing the graph loads MLX even though
that test only checks placement and allocates no tensors. Native-blocked CPU
runs skip this check; synthetic gateway tests remain CPU-only.

With `MLX_BUN_GRAMMAR_JUMP=1`, Gemma2 plain-KV ordinary requests preserve
main's direct forced spans through the shared scheduler: one graph append for
`[pending, ...forced]`, with no sampling of forced IDs. Graphs already using
verified grammar proposals retain that behavior. Paired greedy Gemma2-2B checks
against main passed a terminating choice and nonterminal JSON schema, including
full-vocabulary logits, all 26 valid KV layers, masks and publication order.
Separate real-gateway checks passed callback stop inside a committed span,
retention and restoration of the complete prefix, fixed-suffix continuation,
mid-span cancellation with an active peer, and same-scheduler recovery. Graph
calls remain B1; this is not stacked batching or an all-model qualification.
The shared gateway owns prefix transfer and, as on main's shared path, returns
an empty `stats.cacheTokens`; direct generation retains its exact cache history.
No full-stats, HTTP cancellation, abort-last/abort-plus-stop, oracle or performance
identity is claimed by these checks.

Shared Gemma2 qualifies plain KV, including grammar-constrained and adapter
requests; the opt-in [constrained Gemma2 test](../../apps/mlx-bun/tests/engine/gemma2-constrained.test.ts)
compares them exactly with direct generation. Plain-KV fill uses the shared fill
binding: with `MLX_BUN_GEMMA2_MODEL`, the batching test replays main's serial fill
(one-position assert appends, one verify forward per echo span, trim on rejection)
and requires B1 logits bit for bit, then B2/B3/B4 tokens through joins and
cancellation, observing each capacity as the batch's high water. Fill also runs
inside a request's adapter context; the constrained test's grouped case checks
four-row adapter groups, partition from base rows, an event-driven join and a
replacement, a cancellation against a same-count stop control, and no leak. Plain-KV
generation continuation uses the shared continuation binding once persistence is
configured; the opt-in [Gemma2 continuation test](../../apps/mlx-bun/tests/engine/gemma2-continuation.test.ts)
runs it through the app's serving composition: interval snapshots, a durable
record surviving cancellation, its restore after a fresh engine, and cleanup on
completion. Plain-KV two-model speculation uses the shared speculative group
with a second loaded instance as the draft; the batching test's opt-in two-model
case checks B1 determinism, main's gate that greedy grammar with speculation
equals greedy grammar alone, a ragged joined group (its measured target batch),
cancellation, and a follow-on request that reproduces the fresh B1 run. N-gram
lookup drafting uses the same group; its opt-in case observes rounds where a
proposing row verifies beside an empty, right-padded peer and rounds where no row
proposes, swaps the padded peer's content without changing the target's forwards,
proposals, tokens or logits (greedy and seeded), cancels a ragged third row against
a same-count stop control, and checks main's grammar gate. Encoded
KV, draft providers whose rows tap target hidden layers (this graph has no tap
operation), and paging retain typed unsupported placement.
Its full-attention policy remains the pinned mlx-lm policy documented in the
[architecture descriptor](src/models/universal/archs.ts).
A plain-KV adapter request with a configured TwoModel or Ngram draft uses
ordinary continuous decoding and ignores both draft and fill, as main did.
This is an ordinary fallback, not adapter speculation support. Paired B1 greedy
acceptance against main passed with a synthetic nonzero adapter on Gemma2-2B:
full logits and valid KV match with either draft configured, with or without
fill and logprobs; draft and fill stay unused, and physical unmount restores
the base computation. This does not qualify multi-row adapter/draft requests.

A plain-KV request without adapters keeps two-model or n-gram speculation when
fill is supplied, but ignores the fill session (strict, verify or echo), as main
did. Logprobs instead select ordinary decoding and ignore both draft and fill.
Paired B1 greedy acceptance on Gemma2-2B matched main and each fill-off control:
full target/draft logits, valid KV, proposals, continuing commits, output and
logprobs; genuine drafting ran when selected, and every fill hook stayed unused.
Main omits its terminal speculative commit; the candidate's terminal state was
checked against its verified prefix, without a main-terminal parity claim.
This does not qualify B>1, external-oracle parity or performance, or enable
speculative fill.

The [Trellis specialization test](tests/parity/trellis-shared-m.test.ts) takes
`MLX_BUN_TEST_TRELLIS_MODEL=/cached/packed-qwen`. It preserves main's variant
comparison: `MLX_BUN_TRELLIS_AB_VARIANT` (default 7) against
`MLX_BUN_TRELLIS_AB_BASELINE` (default 6). Use variant 13 against baseline 12
for the optimized expansion path. M=1–5 compares complete logits, recurrent/KV
state and continuation; variant 13 also checks M=16/128/512 with the last-position
head. Six alternating-order blocks also screen the last-position head at
M=1–5/8/9/16, M=32 for variants 11–13, and M=128/512 for variant 13.
These are exact within-artifact specialization checks, not a Python oracle
or timing claim.

Run each file with `bun --no-env-file test <file>` and exclusive GPU access.
Unset required paths skip before native imports; supplied invalid model paths
or a partial padded-prefill opt-in fail. Open acceptance work lives in
[PLAN](../../PLAN.md#verify-the-migrated-library).
They extend rather than repeat [#61](https://github.com/joshuarossi/mlx-bun/pull/61)
(MiniCPM/Gemma plain and mixed state restore; Trellis against main),
[#62](https://github.com/joshuarossi/mlx-bun/pull/62) (Gemma e4b window-wrap state
restore), and [#64](https://github.com/joshuarossi/mlx-bun/pull/64) (compiled
Gemma e4b/12B). Those completed comparisons do not cover scheduler sampling
recovery, padded cohorts, or this real-model Trellis variant matrix.


## Direct library use

See [Qwen3 loading and generation](examples/qwen3-generate.ts). Run it from the
repository root with `bun packages/inference/examples/qwen3-generate.ts <checkpoint-directory> "Hello"`.
It loads the local tokenizer, streams tokens from the supplied graph, and releases
weights after generation completes.

Use the graph matching your checkpoint, or compose your own operations and supply
an explicit binding. The root export contains common loading and generation
helpers; the subpaths below expose individual components. These workspace packages
are version `0.0.0` during the refactor and have not been published to npm.

## Trellis weight expansion

See the runnable [Trellis expansion example](examples/trellis-expand.ts). Its
`expandWeights` function borrows codes and scales and returns an owned lazy tensor.
`bun packages/inference/examples/trellis-expand.ts` demonstrates the layout with
small generated inputs, without a model download.

The caller supplies uint32 packed codes, one floating-point scale per stored
row, and matching geometry. The eligibility helper checks the kernel's supported
geometry and output dtype; callers remain responsible for matching tensor
shapes and dtypes. This kernel supports the existing 1MAD codebook with L=12,
256-symbol blocks, and 2-, 3-, or 4-bit codes. Output is the stored matrix in
bfloat16, shaped `[rows, cols]`. For axis 0, that is the transposed weight layout.

The existing interleaved 3-bit layout uses `blockInterleave: 2` and codes shaped
`[cols / 512, rows, 48]`. Row-major codes use `[rows, cols * k / 32]`.

Expansion is lazy. The caller decides when to evaluate the result and owns its
array handle. The kernel does not load checkpoints or choose a model.

## Packed operations

All operations are imported from `@mlx-bun/inference/kernels/trellis`.
They borrow input arrays and return an owned, lazy output array.

| Operation | Input and purpose |
| --- | --- |
| `trellisReduce(x, codes, scales, geometry, variant)` | Axis-1 projection; `x` is `[M, inFeatures]`, M=1..4 |
| `trellisScatter(x, codes, scales, geometry, variant, useSharedScatterCodebook?)` | Axis-0 projection; same input shape and row budget |
| `fusedGateUpSwiglu(x, gate, up, variant)` | Matching axis-1 gate/up geometry and bit width; preserves leading input dimensions, with 1..4 total rows |
| `fusedGateUpSwigluMixed(x, gate, up, variant, tail?)` | Matching axis-1 geometry with independent bit widths; `tail` is `"fused"` or `"split"` |
| `expandTrellis(codes, scales, geometry, dtype, variant)` | Existing general expansion and variant-13 vector specialization |
| `tiledTrellisPrefill(x, codes, scales, geometry)` | Axis-1 packed prefill, M=5..32 |
| `splitKTrellisPrefill(x, codes, scales, geometry)` | Axis-0 packed prefill, M=5..8 |
| `wideTrellisPrefill(x, codes, scales, geometry)` | Axis-1 prefill following MLX's GemvWide arithmetic, M=5..15 |

`gate` and `up` are `TrellisWeights`: `{ codes, scales, geometry }`.
Callers supply compatible tensors and choose the variant explicitly. Existing
variant numbers are preserved: 6 uses the original packed f32 code/scale path;
13 adds the existing shared-work and expansion specializations. Variant 4 is
the inherited timing-only path and does not compute decoded weights correctly.
No application environment flags are read by these operations.

For prefill, use the corresponding `*Eligible(geometry, rowCount, dtype)` helper
to preserve the existing dispatch profile. Wide prefill additionally requires
caller-proven aligned, row-contiguous input. These profiles and numerical
contracts are unchanged; they are not universal dispatch rules for every shape.

## Artifact, input, and layer APIs

- `@mlx-bun/inference/artifacts`: model configuration, safetensors metadata,
  and lazy native weight loading through `Weights.open(directory)`. The caller
  supplies the local artifact directory and any graph-specific weight view.
- `@mlx-bun/inference/artifacts/auxiliary-files`: `copyAuxFiles(source, output)`
  copies tokenizer, template, and other non-weight checkpoint files when present,
  without loading MLX.
- `@mlx-bun/inference/input`: `loadTokenizer(directory)` consumes the existing
  Hugging Face tokenizer files; `ChatTemplate.load(directory)` loads the template.
- `@mlx-bun/inference/layers`: quantized linear and embedding layers, RMSNorm,
  and `TrellisLinear`, which composes the standalone Trellis kernels and retains
  the existing dispatch and expansion fallback.
- `@mlx-bun/inference/layers/lora`: inference-time LoRA state and weights.
- `@mlx-bun/inference/runtime/config`: immutable execution settings and scoped
  overrides. The existing `MLX_BUN_*` defaults are preserved during migration.

These modules do not download models or start services. Tensor handles returned
by `Weights.tensor()` are borrowed from the weights owner; release them through
`Weights.release()`, `releaseShard()`, or `dispose()`. Layer outputs are owned
by the caller.

## Concrete graphs

Import a graph directly, provide its weights and configuration, and own its state:

See [explicit forward passes and state ownership](examples/qwen3-forward.ts).
Run `bun packages/inference/examples/qwen3-forward.ts <checkpoint-directory> "[1,2,3]"`
with token IDs from your checkpoint’s tokenizer. The example forwards the prompt,
selects a token, continues with the same cache, and disposes cache before weights.

The direct graph imports currently include `models/gemma4`,
`models/gemma4/generated`, `models/minicpm5`, `models/qwen3`, `models/qwen3-moe`,
`models/qwen3_5`, `models/qwen38-27b-trellis-tq`, and `models/universal`.
`models/glm52`, `models/diffusion-gemma`, and `models/whisper` provide the other
existing graph families. These retain the dedicated and specialized implementations.
`@mlx-bun/inference/models` exposes the existing profile/implementation registry
and model construction helpers. Direct graph constructors remain available. Runtimes
that plan memory before opening weights (streamed experts) are opened with
`openPlannedRuntime` from generic `RuntimeOpenOptions` and return a generic
`MemoryPlan` and telemetry; `planRuntimeMemory` (`models/memory-plan`, native-free)
returns the plan from artifact headers, or null for models without one. A graph
that carries its own draft head declares it (`GraphCapabilities.nativeDraft`), and
`DraftProviderRegistry.native(graph)` builds the provider.

For explicit state and tensor operations, use `graph.makeCache()`,
`graph.forwardHidden(ids, state)`, and `graph.logitsFromHidden(hidden)`.
Release state with each cache's `dispose()` and release returned arrays when
finished. `bindMlxGraph` from `models/graph` adapts caller-supplied operations to
an explicit graph descriptor and logits selection contract without owning weights.

Shared dense/quantized layers, activations, normalization, and RoPE live under
`layers/`; architecture assembly lives under `models/<family>/`. DeltaNet
kernels remain independently importable through `kernels/delta`.

## Native expert I/O

GLM's expert I/O support is built from `native/expert-io.c` with
`bun run --filter @mlx-bun/inference build:native`. The resulting dylib lives in
`dist/native/` and is included in the package archive. `prepack` rejects missing
artifacts. An existing build can be staged with `bun run stage:native <directory>`
inside this package. Loading uses the bundled library, or the caller's explicit
`libraryPath` / `MLX_BUN_EXPERT_IO_DYLIB` override.

`artifacts/experts` owns native I/O bindings, residency, and usage accounting;
`artifacts/glm52` owns direct-container and quantized-weight loading. Numeric
streamed expert kernels are independently available through `kernels/glm52`.

## State and attention

`@mlx-bun/inference/state` exposes the existing plain, affine, rotating,
TurboQuant, recurrent, and GLM compressed caches, plus row batching, scoped KV
maintenance, cloning, and persistence. The caller creates and owns the state.
`@mlx-bun/inference/contracts` holds the shared cache and ownership interfaces.
A rotating cache's `temporalView()` is its live window: the newest
`min(offset, maxSize)` positions in chronological order, including right after a
multi-token write leaves the ring oversized. Serial, batched, speculative and
aligned rotating layouts select the same window.
A single solo rotating row adopted into a shared layout keeps its physical
columns, ring phase and offset, so it attends over its keys in the solo cache's
order and later writes land where the solo cache's would; several rows are
aligned in temporal order behind their left padding. `extractRow`, like mlx-lm's
`BatchRotatingKVCache.extract`, and persistence store a row in temporal order,
so a restored wrapped ring starts a new physical phase: its continuation can
differ from the live row's, in main as well. RAM and disk restores agreed in the
checks below.

- `state/`: storage layout, positions, row membership, precision transitions,
  snapshots, and persistence. `persistence.worker.js` performs CPU disk I/O.
- `layers/quantized-attention.ts`: existing fused/unfused attention dispatch.
- `kernels/turboquant/`: packing, rotation, codebooks, and packed decode kernels.
- `kernels/delta/gated.ts`: DeltaNet kernels; recurrent storage lives in
  `state/ssm.ts`. A layer driven by a `TrainingSSMCache` (the training forward)
  runs the same kernel with a backward attached that differentiates an ops
  recomputation of the recurrence.
- `state/paged/`: existing opt-in paged state and its persistence codec.
  The numerical attention implementation lives in `kernels/attention/paged.ts`.

Public kernel imports are `@mlx-bun/inference/kernels/turboquant`,
`@mlx-bun/inference/kernels/delta`, and
`@mlx-bun/inference/kernels/attention/paged`. Paged state is available through
`@mlx-bun/inference/state/paged`. No cache mode or experimental default changed.

The opt-in [Gemma4 paged test](tests/parity/gemma4-paged.test.ts) takes
`MLX_BUN_TEST_PAGED_MODEL` (any Gemma4 artifact) and places requests through the
gateway binding's plan, state policy and execution group. Gathered bf16 pages must
equal plain KV at B1 and B3 with blocks 16 and 256 (tokens, every sampled vector,
each retired row's valid K/V), the bit-exact contract. Over bf16, KV4 and KV8
pages it also requires the direct reader to serve decode, each call within 2^-4
of the gathered reader's output scale over the same query and pages (Lab
numerics; greedy tokens are reported, not compared, since that difference can
flip a low-margin step), abort-versus-stop survivor identity with recovery on
the drained group, and RAM then fresh-SSD-store reuse of pages of the same
encoding and reader. It passes on Gemma4 E4B and 12B. Run it from the root with
`MLX_BUN_TEST_PAGED_MODEL=/gemma4/snapshot bun --no-env-file test packages/inference/tests/parity/gemma4-paged.test.ts`.

## Source ownership

All kernel files below live under `src/kernels/trellis/`.

| File | Responsibility |
| --- | --- |
| `codebook.ts` | Shared 1MAD Metal helpers, host LUT, and decoder variant mapping |
| `geometry.ts` | Trellis geometry and borrowed weight types |
| `reduce.ts` | Axis-1 packed matvec and its shared-row variant |
| `scatter.ts` | Axis-0 packed matvec, balanced/shared variants, and partial reduction |
| `gate-up.ts` | Same-width fused gate/up SwiGLU |
| `mixed-gate-up.ts` | Independent-width gate/up and its two activation tails |
| `expand.ts` | General stored-matrix expansion and vector dispatch |
| `vector-expand.ts` | Four-weight vector expansion |
| `tiled-prefill.ts` | Axis-1 tiled prefill |
| `splitk-prefill.ts` | Axis-0 split-K prefill and ordered reduction |
| `wide-prefill.ts` | GemvWide-compatible prefill and hardware eligibility |
| `index.ts` | Public Trellis imports |

Tests in `tests/kernels/` cover the host decoding reference, variant equivalence,
activation tails, packing, strides, and existing prefill comparisons against MLX.
The wide-prefill native comparison runs only on supported hardware.

The MLX runtime libraries belong to `@mlx-bun/mlx`; this package bundles its
expert I/O and video helpers. Set up
that package's native artifacts, then run `bun run typecheck` and `bun run test`
from the repository root.


## Sampling, embeddings, and adapters

`@mlx-bun/inference/sampling` exposes `makeSampler`, `makeLogitsProcessors`,
`makeStepSampler`, and the individual top-p/top-k/min-p/XTC and tone-curve
operations. `sampling/types.ts` owns options; `filters.ts`, `processors.ts`,
`hlg.ts`, and `curve.ts` own transformations; `step.ts` owns token history and
per-step sampling; `extras.ts` owns captured log-probability readback and disposal.
The caller supplies scores and chooses options. Returned arrays belong to the caller.

`sampling/grammar` compiles constraints against the caller's loaded tokenizer
using the existing xgrammar dependency. Await `ready()`, apply the mask to logits,
accept the sampled token, and dispose the controller when finished. The normalized
argmax and token-bitmask kernels are exposed through `kernels/sampling`.

`embeddings` provides the pooled-embedding helpers: `embedOne`, `embedMany`,
`embeddingTerminatorId` and `withInstruction`. Any graph declaring `embeddings` and
providing `embedPooled` works; the pooling token comes from the graph's profile
(`embeddingDeclarationFor`, resolved with the tokenizer). Supply the graph and tokenizer explicitly. `adapters`
provides `AdapterManager` for loading and applying existing mlx-lm and PEFT LoRA
artifacts to a caller-owned graph; adapter weight/state types are also exported.

## Generation

The [generation example](examples/qwen3-generate.ts) iterates over emitted tokens
and returns the final generation statistics. It uses the same public generation
API available through the root and `@mlx-bun/inference/generation`.

`generate` uses the graph supplied by the caller. `generateAutoregressive` accepts
an explicit `MlxAutoregressiveBinding` from `generation/bindings/autoregressive`, including
caller-defined graph operations, state construction, and optional compiled decode.
`generateDenoising` accepts a denoising binding; `generation/diffusion` also exposes
`denoiseSync` and `denoiseAsync` directly. No service or model selection is involved.

`generation/autoregressive.ts` owns prefill and token iteration;
`generation/diffusion.ts` owns canvas denoising; `generation/result.ts` owns the
async iterator and final stats. `generation/scopes.ts` owns adapter,
wired-memory, and expert-usage lifetimes. Existing cancellation and early-return
cleanup behavior is preserved. `generation/fill` exposes the existing optional
fill session and proposal interfaces.

## Speech and vision

- `input/audio`: WAV parsing, AudioToolbox decoding, transcoding, mel features,
  and the existing Whisper tokenizer. `loadWhisperTokenizer` reads local HF
  artifacts; it does not download them.
- `transcription`: Whisper decoding, long-form and streaming transcription,
  word timing, and text/SRT/VTT formatting. Callers supply the Whisper graph,
  tokenizer, and audio samples. `transcription/format` exposes the
  text/SRT/VTT/verbose-JSON formatters alone, without loading native MLX, for
  HTTP layers that only shape responses.
- `models/audio/conformer` and `models/audio/silero-vad`: existing audio encoder
  and voice-activity graphs.
- `input/vision`: image decoding/preprocessing, multimodal prompt assembly,
  and video frames. Qwen preprocessing and prompt assembly have separate
  `input/vision/qwen3vl` and `input/vision/qwen3vl-prompt` imports.
- `models/vision/siglip`, `models/vision/qwen3vl`, and `models/vision/unified`:
  concrete vision encoders.

The AVFoundation frame extractor is built by `build:native` and bundled beside
expert I/O in `dist/native`. It needs no runtime download or compilation.
`MLX_BUN_FRAME_EXTRACT` remains an explicit override. AudioToolbox and `afconvert`
use macOS system facilities. Optional encoder caching lives in `state/encoder-cache`;
media fetching keeps the existing destination, size, and timeout controls.

## Speculative generation

`generation/speculative` exposes `generateSpeculative`, `specRun`, and the existing
assistant, two-model, Qwen/GLM MTP, DFlash, DeepSpec, and n-gram proposal providers.
Supply the target graph, draft provider, token budget, and token callback yourself.
`specRun` accepts an explicit binding from `generation/speculative/binding`; it does not
require a concrete model class. The former `specServeRun` name remains available.
`generation/speculative/loader` loads a `dspark.json` checkpoint (`loadDsparkDrafter`) and
also exports the drafter class and its config types, which `@mlx-bun/training/dspark` uses
to produce those checkpoints.

`DraftProviderRegistry` (`generation/speculative/draft-registry`) is how a server
selects and loads a draft: each provider kind registers `detect(artifact)` (files
only, never MLX) and `load(request)`, and `defaultDraftProviders()` registers the
built-in kinds (`dspark`, `deepspec`, `assistant`, `mtp`, `two-model` as the
catch-all, `ngram` by name only). An application uses the default, extends a copy
with `register`, or hands `loadContext` a ready provider (`draftProvider`); it never
names a provider class, and the architecture gate rejects one there. A graph whose
checkpoint carries its own draft head declares it as `GraphCapabilities.nativeDraft`
(GLM-5.2's MTP row); `registry.native(graph)` binds the registered provider.
Providers read the target through capability-named ports on `TargetView`
(`assistantRows`, `hiddenLayerTaps`, `recurrentMtp`) and refuse a target lacking
one with `target graph does not provide <port>`.

Draft graphs live in `models/gemma4/assistant`, `models/qwen/mtp`, `models/glm52/mtp`,
and `models/speculative/*`. Proposal sources live in `generation/speculative/sources`;
verification and acceptance belong to `generation/speculative`; batched draft work
belongs to `generation/speculative/bindings`; draft checkpoints belong to `state/speculative`.
Existing sampling, rejection, rollback, and specialized kernel behavior is preserved.
One intentional correction: grouped speculation maintains a reused target prefix
before its first forward. A round without drafts maintains only before its append,
so under a delayed KV scheme a stored prefix can still owe the conversion its last
append reached. Main's batched lane read that prefix unconverted in its first
suffix chunk.

Grouped speculation binds any provider whose operations the target meets: batchable
caches, row layouts for verification and rollback, and a forward that captures the
hidden layers the provider taps. A provider whose rows tap target layers declares
them with `targetTapLayers(target)` on its grouped provider; the binding resolves
the list once for the bound target, rows opened for it must tap exactly that list,
and placement refuses the provider when the target forward cannot capture those
layers. The post-final-norm sentinel (index = layer count) is the forward output.

The [Qwen MTP group-prefix test](tests/parity/qwen-mtp-group-prefix.test.ts) takes
`MLX_BUN_TEST_MTP_TARGET` and `MLX_BUN_TEST_MTP_DRAFT` (both or neither) and runs
the Trellis target with its folded MTP draft through the gateway binding at B2,
depth 2, plain KV and EOS disabled: two unequal prompts, the first retiring by a
stop, an abort or a consumer failure, greedy and seeded. It observes every verify
round and each row's committed target state, attributed to its request through
joins and filters, and checks within this tree the exact committed inventory,
accepted and rejected proposals while both rows are active, retirement outcomes,
and that a stopped or finished request publishes one generated checkpoint equal
to its terminal committed state while a cancelled or failed one publishes none.
Both requests then continue from those checkpoints, twice from RAM and once in a
fresh process from the flushed SSD store, with identical records. Main parity is
external evidence; B>2, KV quantization, HTTP and performance are not covered.

The [grouped speculation test](tests/parity/speculative-group.test.ts) covers
each built-in draft provider over its target with plain, affine, TurboQuant or
per-layer KV. It takes `MLX_BUN_TEST_SPEC_TARGET`, `MLX_BUN_TEST_SPEC_KIND`
(`ngram|two-model|assistant|mtp|dspark|deepspec|glm-mtp`) and
`MLX_BUN_TEST_SPEC_DRAFT` (none for n-gram or `glm-mtp`), and optionally
`MLX_BUN_TEST_SPEC_KV` (`bf16|4|8|turbo|config`),
`MLX_BUN_TEST_SPEC_KV_START`, `MLX_BUN_TEST_SPEC_DEPTH`, `MLX_BUN_TEST_SPEC_WINDOW`
(the custom sliding-window graph over a Llama-family target) and
`MLX_BUN_TEST_SPEC_ADAPTER`. Providers load through `defaultDraftProviders()`, as
the app's model host loads them. Requests go through placement, `methodRequest` and
the binding's group: B1 equal to the serial `specServeRun` producer where that
producer serves the KV settings, B4 cohorts that prefill together and repeat,
stop/failure/abort retirement at exact counts, late and prefill joins, prompt
snapshots with their draft attachment, generated prefixes restored from RAM and
a fresh SSD store after a provider reload, and, with an adapter, a live adapter
whose B2/B4 rows with the draft configured equal B1 controls, context
partitioning, failure cleanup and adapter-isolated prefix reuse. Adapter rows
speculate only through providers that support target adapters. It has run for
n-gram, two-model and assistant providers; MTP, DSpark, DeepSpec and GLM
native MTP have not.
For example:
`MLX_BUN_TEST_SPEC_TARGET=/gemma4-e4b MLX_BUN_TEST_SPEC_KIND=assistant MLX_BUN_TEST_SPEC_DRAFT=/e4b-assistant MLX_BUN_TEST_SPEC_KV=4 bun --no-env-file test packages/inference/tests/parity/speculative-group.test.ts`.

`glm-mtp` selects GLM-5.2's checkpoint-native MTP (`--mtp on`), mounted as the
app's model host mounts it: the Colibri runtime opened with the MTP tier planned
for one drafting lane, and the provider the graph declares
(`GraphCapabilities.nativeDraft`) at the plan's draft depth unless `MLX_BUN_TEST_SPEC_DEPTH` overrides it. The same checks run as for the
other providers, except the KV matrix: GLM's compressed MLA cache has no affine
or TurboQuant conversion, so this kind takes plain KV only and no custom window:
`MLX_BUN_TEST_SPEC_TARGET=/GLM-5.2 MLX_BUN_TEST_SPEC_KIND=glm-mtp bun --no-env-file test packages/inference/tests/parity/speculative-group.test.ts`.

`state` also exposes the byte-limited `PromptCache`, retention policies, row state,
and checkpoint attachments. The caller owns cache lifetime and reuse namespaces.

## Optional execution and persistence

`execution` exposes `createInferenceEngine`, method adapters, cancellation,
admission, and continuous batching. Supply an execution planner and its graph
bindings; the engine manages in-process session lifetimes and bounded output.
It opens no network listener. `createAutoregressiveMethod`,
`createSpeculativeMethod`, and `createDenoisingMethod` adapt the direct methods
when a consumer needs sessions. `MlxBatchExecutionGroup` owns batched rows;
`ExecutionCoordinator` and `driveExecutionGroup` coordinate its work.

DiffusionGemma requests share that group through `execution/denoising-group`.
This is interleaved execution, not stacked canvases: each row keeps its own
encoder state, canvas, feedback and MLX key sequence, and the group advances one
row by one bounded unit per iteration in round-robin order. The first unit is the
whole prompt prefill and first canvas draw; each later unit is one denoising step.
A row publishes only its finished result, and its decode time ends when that result
is computed. Rows borrow one dequantized embedding table, which the group releases
after the last row's run closes. Each unit runs with only its row's adapters
active. An image request passes its pixels as the row's prefill input: only the
first unit reads them (the vision encoder runs there), and the request owner
releases them after the row settles. Grammar, draft, logprobs, logits processors,
fill, encoded and paged KV requests are refused with typed plan reasons. `DenoisingKeys` reproduces MLX's
global key sequence per request, so denoising never reads or reseeds the process
key. The [denoising tests](tests/generation/denoising-binding.test.ts) take
`MLX_BUN_DIFFUSION_MODEL=/cached/diffusiongemma` for the real-weight check and
optionally `MLX_BUN_DIFFUSION_REFERENCE`, comma-separated trajectories in main's
`goldens/diffusion/gen*.json` or `goldens/diffusion/vision.json` format. An image
reference must have nonempty output and require more than one denoising step, so
its cancellation check interrupts unfinished image work. With the measured main
image reference, the real-weight check passed image cancellation beside a live
text survivor and image/text reuse on the same group, preserving survivor and
recovery tokens and checking state/table disposal calls and caller-owned pixels.
The disposal checks do not establish allocator leak freedom. Separate paired B1
HTTP acceptance against main passed image SSE disconnect after the first decoder
step, server cancellation, prepared-pixel release, drain and same-server image/text
recovery. Both clients received headers and the initial role frame, with no canvas
tokens published before cancellation. Recovery tokens, messages, finish, usage and
prepared inputs matched controls and main. Concurrent HTTP rows, full logits/KV
planes, external-oracle parity and performance remain unqualified.

`execution/fit` estimates whether a model fits a machine at a context length:
resident weights (bytes the caller supplies, such as a registry's), KV bytes from
`state/kv-scheme`, and the prefill transient, against RAM × `WIRED_FRACTION` or an
explicit budget. `fit` also solves the maximum safe context and predicts decode
tokens per second from memory bandwidth; `skuMatrix` repeats it across Apple Silicon
configurations. Estimates are advisory, and the entry imports without MLX. See the
runnable [fit example](examples/fit-model.ts):
`bun packages/inference/examples/fit-model.ts <checkpoint-directory> [context-tokens]`.

`state` exposes `SsdCacheStore`, `TieredPromptCache`, and
`SsdDurabilityCoordinator` for caller-configured persistence. Execution continuation
helpers retain the existing sampler, pending-token, adapter, and cache identities
when saving or restoring a generation. Applications choose their own storage paths,
capacity, scheduler settings, and shutdown lifecycle. A store's directory is
`<dir>/<configFingerprint>/`; the app's fingerprint joins architecture, KV scheme,
binding compatibility and a content digest of the weights (`modelWeightsIdentity`),
so same-shape models and revised weights never share entries. `scan()` skips, and
never deletes, files whose header names another identity; only its own corrupt
files and `.tmp` orphans are removed. Entries written under the earlier directory
name (no weights digest) are ignored, not migrated or deleted.

## Scoring

`scoring` exposes `forwardSequence` / `forwardSequenceHidden` for full-sequence
logits and hidden states, including the existing padded-batch masks. The original
`trainForward` names remain aliases for compatibility. `evalPpl` computes
perplexity over caller-provided token rows; `klPerToken` compares supplied logits.
Neither requires an evaluation dataset registry or runner. Tool-call parsing is
available from `input`; template/schema fill compilation lives in `generation/fill`.

Standalone app bundles keep the expert-I/O library and frame extractor beside
the executable. Explicit `MLX_BUN_EXPERT_IO_DYLIB` / `MLX_BUN_FRAME_EXTRACT`
overrides take precedence; ordinary source/package execution resolves the
package's `dist/native` directory. The app bundle verification covers relocation
without loading native numerical code.
