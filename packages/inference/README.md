# @mlx-bun/inference

Composable inference components built on [`@mlx-bun/mlx`](../mlx/README.md).
Callers choose artifacts and graphs, own state, and invoke inference directly.
The package includes the kernels, the layers that bind them, the entire graphs
selected by the loader for each composition, the cache legos, input processing,
sampling, generation, embeddings, transcription, and optional execution.

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

Each graph declares its construction facts (`GraphDeclaration`, portable; a model
exposes it as `graphCapabilities`): its method, media
input, compiled decode, sparse attention, hidden-layer taps for
drafts, a draft head its checkpoint carries (`nativeDraft`), whether long prompts prefill in workspace-bounded
chunks, and what its verifier qualifies (adapters, logprobs, external tokens,
grammar proposals). None names a cache format: the composition's caches serve
every method, and the planner never reads how they store keys and values.
Pooled embedding support is the presence of `embedPooled` itself; graphs supply no
separate `embeddings` flag. `graphCapabilitiesOf` derives that boolean in the
portable `GraphCapabilities` description consumed by the gateway. `isEmbeddingModel`
narrows the graph to its required pooling operation, and the existing
`embedOne`/`embedMany` entry points consume it directly. The architecture ratchet
rejects independent pooling flags and reads of the retired declaration field.
`MlxDeclaredGraph` names the operations behind the other promises (`embed`, `bindMediaInput`,
`mediaEncoders`, `pixelInput`, `draftTarget`, `nativeDraftHead`, `trainable`,
`compiledDecodeStep` and `releaseCompiledDecode`, `expertResidency`) and the facts its
composition declares (`verifyRoundCosts`, `knownSpans`, `mixed`), and
`declaredGraph` in `models/capabilities` checks the pairing once when composition
binds the graph: an undeclared graph, malformed pooling operation, or media
declaration without its operation is refused. The gateway plans from the
declarations, the request and dynamic state
(batch membership, cache contents, cancellation), and
`MlxGatewayBinding.capabilities` reports what it resolved. Supporting a new graph
means declaring and implementing; `execution/` and the app engine need no edit.
The batch group and the autoregressive binding take the structural `MlxTokenGraph`
(`models/graph`: config, caches, the named phases, and the declared ports), not
the registry's `RuntimeModel` union. A graph's compiled decode step lives with that
graph (`models/gemma4/compiled-decode`) and reaches them through `compiledDecodeStep`;
it drives caches through the `CompiledDecodeCache` protocol (`contracts/mlx/cache`,
implemented by the KV caches in `state/`) and names no cache class. Every cache
lego has that form except direct pages the kernel reads, which declare none
(`pagedDecodeCompiles` in `state/paged/cache`). The autoregressive binding resolves
replay eligibility from the paging and KV configuration once; requests with active
adapters use the ordinary declared operations.
The architecture gate rejects concrete model imports, model-class `instanceof`,
model-type and `architectures` checks, family predicates and model-scoped flags there,
in the app's engine, server and CLI, and in `@mlx-bun/training`. What those need to
know about a model is declared in its family record and read through its profile
(`models/profile`: `embeddingDeclarationFor`, `sentinelDeclarationFor`,
`mediaTokenDeclarationFor`, `generationDefaultsFor`, `chatTemplateFallbackFor`,
`trainingDefaultsFor`) or returned by its opened runtime (`models/runtime`,
`models/memory-plan`); token text resolves to
ids against the tokenizer in use (`input/special-tokens`). One record per model
family (`models/family`, listed in `models/families`) holds the family's `accepts`
rule, its graph id (an open string), tier, loader, loop, fidelity, engine
capabilities, roles and those declarations; support tiers, profiles, engine
capabilities, implementation loader/loop and fit's expert count derive from the list.
A new model is a record in `<family>/family.ts`, an entry in `MODEL_FAMILIES` and its
native implementation in `models/factory`; the records import no graph class, so
resolving a profile never loads MLX. The gate keeps model-type comparisons and family
predicates inside the registry, the family directories and the artifact readers
(`artifacts/config-dialects`, which spell how a `model_type`'s `config.json` is laid
out). `trainable`
(`TrainableGraph`) declares what the trainer consumes: the quantized
`lmHead` for fused linear-CE heads, `segmented` backward (how a range of layers
runs and which reused K/V crosses segment boundaries), `prefixShared` forwards,
`gradCheckpoint`, the `flashAttention` constraint, and the `denoising` objective.
The trainer names the declaration a graph lacks. The loader resolves module configuration once
(`contracts/portable/composition`, `models/composition`) from the caller's request
and the machine: KV scheme and paging, scheduler row cap and prompt chunk size,
draft method and depth, sampling and request policy. The file names its kernel
and compilation choices. Alternative layer forms remain importable for callers
writing their own graphs. Each request names its adapter file; its trained delta
adds to the outputs of the projections it targets, under that request's scheduler
context, independently of the file's projection kernel choices.

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
token. This is not 100-step full-vector parity. The loader's Gemma 4 table
builds the written 12B graph only for the `kv_config` composition it serves, so
for plain KV (the default composition) `createModel` builds `Gemma4Model` too,
and the test asserts that. Opt in with all of
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
the plain-KV scope above; the written graph's unrolled `kv_config` path and
performance remain separate checks.

The [written Gemma graph test](tests/parity/gemma4-written.test.ts) is that
unrolled-path check, ported from `02d723a:tests/parity/generated-parity.test.ts`
for each registered fingerprint (12B, e4b, 26B-A4B). With
`MLX_BUN_TEST_GEMMA4_GRAPH_MODEL` naming an artifact that ships `kv_config.json`, it
requires the `kv_config` composition (`--kv-quant config`) to select the written
graph and the default composition `Gemma4Model`; byte-identical vectors against
`Gemma4Model` over caches converted to `kv_config` before a prompt past the
sliding window; identical 24-token greedy trajectories under the `kv_config`
composition, each graph reading its own composed caches (stop tokens off, so
every trajectory is full length), uncompiled, where from the second forward on
every listed cache answers from its quantized storage, and with compiled decode;
and identical vectors over plain caches. This is identity between the written
graph and the family's generic graph within this tree, not an oracle claim. On 2026-09-28 it
passed on the M1 Max for mlx-community gemma-4-e4b-it-OptiQ-4bit (`98d7dc6a`; 24
unrolled forwards uncompiled, 2 compiled) and gemma-4-12B-it-OptiQ-4bit
(`5b110106`; 24 uncompiled, 1 compiled). The 26B-A4B cell was not run. A final
cell runs two different rows through one forward over `kv_config` caches and
requires bytes equal to the generic graph's; it caught the committed e4b graph slicing
its per-layer inputs for one row, and passes on e4b and 12B after regeneration
(2026-09-29, M1 Max).

The three Gemma files are written directly under `models/gemma4/`. Each names
its sliding/full attention, KV donors, per-layer inputs, activation and expert
operations in order. Changes to one file are checked by that file's numerical
gates. A shared block or kernel change reaches the files that import it.

The identity tests compare each specialized file with its family's generic graph
at maxDiff 0 where both serve the same operation. Real-weight parity suites and
app-path digests (`scripts/digest.ts`) hold the served numbers; recorded synthetic
digests (`scripts/synthetic-digests.ts`) cover cases without an artifact. There is
no source generator, parallel input description or generator drift test.

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

### MOSS-Image comparison (acceptance pending)

[`moss-image-oracle.test.ts`](tests/parity/moss-image-oracle.test.ts) compares
the MOSS-Image stages with the external PyTorch reference: the snapshot's own
`pipeline_moss_image.py` with transformers 5.12.1's `Qwen3_5Model` (on the CPU it
takes transformers' torch fallback for linear attention) and diffusers 0.38.0's
`AutoencoderKLFlux2`, torch 2.9.1 on the CPU, Python 3.12.13 (accelerate 1.15.0,
safetensors 0.9.0rc1, numpy 2.5.4). That reference runs outside every checkout
from `~/oracles/moss-image` (script SHA-256
`7105613cfde4b67061490fef123e4a3cc7c88d9be9ebe098a3026797b415d3f1`, frozen
requirements `937e32db24ba825eff0f431eed77af44f00a50c33ff254b6b249c90f864089da`;
the stages before `delta` were written by earlier versions of the script whose
changes only added the device option and the `delta` stage) and writes
safetensors captures: the tokenized prompts and hidden states, the schedule, its
own seeded noise (an input here: equal seeds do not give equal noise across
backends), DiT stage outputs at steps 0 and 4 of 8 with and without block 22, the
8-step guided trajectory at 256x256, decoded pixels, the same DiT stages and
trajectory on its MPS backend as a measure of its own variation, and the
conditioner's linear attention (`delta`, `gated-norm`). Before any comparison the
test computes the SHA-256 of every snapshot file and capture it reads and fails
unless each equals its pin for that revision; Hugging Face cache symlink names
are recorded as provenance only. Opt in with `MLX_BUN_MOSS_IMAGE_SNAPSHOT` and
`MLX_BUN_MOSS_IMAGE_ORACLE`; `MLX_BUN_MOSS_IMAGE_RESULTS` names the results file
(each check's measurement and verdicts, the verified hashes, the implementation's
commit and modified files). The VAE has its own comparison in
[`moss-image-vae.test.ts`](tests/models/moss-image-vae.test.ts).

Original criteria, fixed before the first run: token ids and the schedule exact;
hidden states and every DiT stage output relative Frobenius error <= 3e-2,
per-token cosine >= 0.999 and mean cosine >= 0.9995; each trajectory step relative
error <= 6e-2 and cosine >= 0.995; the decoder within 1e-5 before decoding and,
after it, a maximum of 1e-3, a mean of 1e-4 and no pixel off by more than one
level. The first runs exposed two calculation bugs, fixed in the code, not the
bounds: the schedule rounded `torch.linspace`'s product separately (the reference
fuses it), moving two noise levels by one float32 ulp, and the test read a
transposed MLX view in storage order.

Independent review adjudicated one exception: the last DiT block's text rows feed
no later operation, so they are reported and its image rows hold the original
bounds. Every other check holds the original bounds, so two checks fail and keep
acceptance open: Base's block 22 at step 4 and trajectory steps 5 to 7. The
review's proposed experiments are block 22 alone on identical captured block-21
inputs and modulation, comparing its norm, projections, RoPE, attention, SITU and
residual outputs, and each step's velocity on identical reference trajectory
states. "Each step within twice the reference's MPS-vs-CPU relative error" is
recorded as an investigative bound, not asserted.

Linear-attention bounds, fixed before their first comparison: transformers'
`l2norm` within 1 bf16 ulp per element, `Qwen3_5RMSNormGated` within 1 bf16 ulp,
softplus within 4 and the log-decay within 8 float32 ulps, the recurrence from the
reference's own float32 inputs within 1e-4 relative, the whole rule within 4e-3
relative with every row's cosine at least 0.99999, and a real layer's linear
attention within 1e-2 with every token's cosine at least 0.9999. The captures hold
seeded bf16 inputs at lengths 1, 63, 64, 65, 127, 128, 129 and 300 (around the
64-token chunk) and layers 0 and 30 on a 23-token and a 203-token prompt. The
first run (`dc3e85ab`) failed the l2norm at every length (about a fifth of the
elements, up to 3 ulps); host replays against the captures showed torch computes
a bf16 `rsqrt` as a square root and then a reciprocal, each stored in bf16, and
that sequence matches every captured element. The second run (`615f8167`) missed
the gated norm on 7 elements; replays showed torch's SiLU is `x / (1 + exp(-x))`
and its float32 `rsqrt` a square root and then a reciprocal. Both are in the
layers now; the bounds did not change.

Results on 2026-10-23, Apple M4 Pro, macOS 27.2, Bun 1.4.2, MLX 0.32.2, tree
`0ba290b6`, Base `85975793` and SFT `f972bd4b`, inputs verified:

| Check | Base | SFT | Reference MPS vs CPU |
|---|---|---|---|
| token ids, schedule (8 and 50 steps) | exact | exact | |
| conditioner, positive / negative (relative, min cosine) | 1.53e-2 0.99952 / 2.24e-2 0.99932 | the same (the same files) | |
| velocity step 0 / 4 (relative) | 8.3e-3 / 2.0e-2 | 1.04e-2 / 1.76e-2 | 8.7e-3 / 2.4e-2 (Base) |
| block 22 step 4, worst token cosine | 0.998336 (row 40), not met | 0.999828 | 0.999552 (Base) |
| block 41, image rows (min cosine, step 0 / 4) | 0.99945 / 0.99900 | 0.99904 / 0.99942 | 0.99850 / 0.99886 (Base) |
| block 41, text rows | reported (adjudicated) | reported | |
| trajectory step 5 / 6 / 7 (relative) | 6.7e-2 / 1.25e-1 / 1.25e-1, not met (cosine 0.9931 / 0.9827 / 0.9829) | 8.0e-2 / 1.46e-1 / 1.46e-1, not met | 4.2e-2 / 1.02e-1 / 1.01e-1 (Base) |
| l2norm, 8 lengths | every element equal | equal | |
| softplus / log-decay, 8 lengths | at most 4 / 5 float32 ulps | the same | |
| recurrence from identical float32 inputs | 2.3e-7 to 1.6e-6 relative | the same | |
| whole rule (bf16), 8 lengths | at most 8.8e-5 relative, min row cosine 0.9999986 | the same | |
| gated norm, 8 lengths | 12 of 3,592,192 elements differ; 2 ulps at length 128, not met | the same | |
| layers 0 / 30, 23- and 203-token prompts | 8.5e-5, 7.2e-5 / 3.1e-4, 5.4e-4 relative | the same | |
| VAE (unpatched max, image max, pixels off by more than 1 level) | 0, 2.5e-5, 0 | | |

The conditioner's previous binding (the shared delta and gated-norm kernels)
measured 1.65e-3, 9.5e-4 / 3.5e-3, 4.7e-3 relative on the same real-layer
captures. The gated norm's remaining elements follow the variance's float32
summation order: MLX's GPU reduction does not follow torch's, and no simple order
tried on the host reproduced it exactly. Base's trajectory exceeds the original
bound from step 5 by up to 1.61 times the reference's own cross-backend spread.
Acceptance stays open until the three failures are resolved or decided. Not
covered: other prompts, sizes and step counts, the decoded 8-step images against
each other beyond the VAE comparison, and performance.

### Packed Qwen Trellis parity

[`tests/parity/qwen-trellis-parity.test.ts`](tests/parity/qwen-trellis-parity.test.ts)
compares the 11.99 GB `qwen38-trellis-global-exit5-h39-q4b-v2` and its folded
MTP companion with pre-refactor main. Stock mlx-lm cannot read this packed
artifact. Produce the reference with
[`scripts/main-qwen-trellis-reference.ts`](scripts/main-qwen-trellis-reference.ts),
passing `--main <main-checkout> --target <snapshot> --draft <companion> --out
<external-reference.json>` and main's native library through `MLX_BUN_LIBMLXC`.
The producer does not modify main. Its reference pins model metadata and every
weight shard by content, the main revision, MLX version and GPU architecture.
Set all of `MLX_BUN_TEST_QWEN_TRELLIS_TARGET`,
`MLX_BUN_TEST_QWEN_TRELLIS_DRAFT`, `MLX_BUN_TEST_QWEN_TRELLIS_REFERENCE` and
`MLX_BUN_TEST_QWEN_TRELLIS_REFERENCE_SHA256`, then run:

```sh
bun --no-env-file test packages/inference/tests/parity/qwen-trellis-parity.test.ts
```

The schema-2 reference independently records 96 complete last-position float32
vectors and greedy tokens across three prompts, plus three 64-token native MTP
runs. Each MTP run records emitted tokens, every target input, speculation
counters and the full logits at its actual native heads. Separate teacher-forced
controls record one-row and verify-window vectors, CPU first-maximum IDs, exact
maximum sets and cache positions before, after and after rollback.

The consumer requires equality with those main controls and literal equality
of native MTP tokens, target inputs, counters and head vectors. Every emitted
token must belong to the exact maximum set of its actual head. This preserves
native selection when an exact tie makes the CPU's first maximum a different
token. Window-versus-one-row KL checks remain separate checks of the existing
arithmetic; they do not relax equality against main. The producer records its
source revision and script content hashes, including whether its operational
checkout was dirty. Produce references from an isolated, pinned main checkout
on the same device as the candidate and retain the independent capture's hash.

The MTP scope is the shared gateway with batch capacity one, depth two, plain
KV, greedy sampling and stopping tokens disabled. These checks cover the named
artifact and geometry, not B>1, quantized KV, stochastic sampling, intelligence
or performance. Refactor run results and their source and artifact pins belong
in the PR and external run directory.

The existing runtime-report consumer also matches full logits, all live cache
planes and continuation in 18 cases (contexts 0/64/512 × append lengths
1/3/4/8/16/128, fixed prefix chunk 256, plain KV), including serialized-state
restoration. Main's report SHA-256 is
`8bb68cc58d3aad035111b10e48102595a2c00f91c1b640cc7577da19dae71e54`. Main runs this
comparison with its compiled decode off, and this tree's runtime oracle runs no
compiled decode; the legacy reference's omitted configuration provenance is accepted
explicitly after checking its invocation. Captures and logs remain outside Git.

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

The same consumer covers Qwen Trellis and Gemma. Packed Qwen Trellis has the
measured comparison below; Gemma still needs a recorded run with this consumer.
Produce references outside this repository with the unchanged producers at main
`02d723a`, sequentially on the comparison machine. Stock mlx-lm architectures
(Gemma4 e2b/e4b/26B-A4B, Gemma2, Llama, MiniCPM5) use
`MLX_BUN_TEST_RUNTIME_ORACLE=1 HF_HUB_OFFLINE=1 python scripts/oracle/check-runtime.py plan.json reference.json`
in the pinned oracle environment; it registers no OptiQ architectures, so the 12B
`gemma4_unified` artifact keeps its dedicated consumer above. Packed Qwen Trellis
has no external oracle (mlx-lm cannot load it), so main is the reference:
`MLX_BUN_TEST_RUNTIME_ORACLE=1 MLX_BUN_COMPILED_DECODE=0 bun --no-env-file tests/support/runtime-oracle-worker.ts plan.json reference.json`
in the main checkout (main's own switches; this tree reads neither, and its
runtime oracle runs no compiled decode). Neither producer records provenance or applies `kv`, so
compare plain-KV plans with the legacy acceptance and pin the report:
`MLX_BUN_PARITY_PLAN=plan.json MLX_BUN_PARITY_REFERENCE=reference.json MLX_BUN_PARITY_REFERENCE_SHA256=<sha256> MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG=1 bun --no-env-file test packages/inference/tests/parity/runtime-oracle.test.ts`.
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
mlx-lm 0.31.3. Runtime overrides were only compiled decode off (main's switch,
which that tree also read) and `MLX_BUN_TEST_RUNTIME_ORACLE=1`; references ran
sequentially with HF offline.
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
Greedy trajectories and a dense Gemma mid-segment failure (which ends its generation:
the compiled step has no fallback) use main's original tokenizer-rendered prompts
(12B targets 600/1100 tokens; e4b targets 700).
Those checks require actual compiled-step activation and zero unexpected retraces.
The forced-token full-logit matrix uses deterministic IDs independently of EOS. These are
compiled-versus-ordinary checks, not an external-oracle or performance claim.
Runtime compilation overrides stay inside the test; this adds no application option.


### Scheduler continuation and per-path checks

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

Gemma4 adapter rows take ordinary generation checkpoints. Paired B1 checks, recorded
while adapter rows still bypassed paging (so on plain KV),
on Gemma4 e2b OptiQ-4bit (snapshot `b0162532`, MacBookPro18,2, MLX 0.32.2)
matched main `02d723a` at capacity 1 against continuous capacity 8 for 16 tokens,
greedy and seeded sampling, and fresh-process restoration across both settings.
Full logits and all 15 donor KV states matched; all 35 layer outputs and the
final norm matched by hash. The nonzero adapter changed logits and unmounting
restored the base. This covers one active row within the sliding window, not grouped rows, paged numerics,
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

MiniCPM5 and these universal graphs also ignore a configured draft for adapter
requests, as main did; requested logprobs remain available. Main also ignored
supplied fill for them, which the shared fill method now serves (the pairing
below predates that). Without fill/logprobs/grammar, ordinary checkpoints remain eligible. Ignoring the draft
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
metadata; its raw bytes, value and computed state must match exactly. Main
ignored supplied fill on these graphs without adapters or a configured draft
too, having no affine append binding; the planner then chose ordinary
decoding, which the pairing below qualified, and now serves it through the
shared fill method. Paired B1 acceptance on cached MiniCPM5-1B and Qwen2.5-0.5B matched main and
no-fill controls for supplied strict/echo fill, unseeded greedy sampling and
KV4 starting at token 8. Each request generated 16 tokens across conversion;
all 17 forward states, 16 full-vocabulary projections and valid cache planes
matched, and every fill hook stayed unused. Main planned fill and disabled it
inside generation; the planner of that pairing reported `fill-incompatible-with-request`
and selected ordinary continuous decoding. This pair does not qualify B2 or
cancellation.
Requests that supply fill remain ineligible for generation checkpoints.
Speculation, grammar proposals and fill are planned over delayed affine KV as
over any other scheme. A graph whose layers softcap their attention scores
(Gemma2) composes the softcapped read (`state/softcap-attention`) at construction
in place of the cache's own read: it fetches each window as plain keys and values
from every storage (plain as stored, TurboQuant decoded, affine dequantized, paged
gathered) and attends with the manual composition. That attention runs unchanged over the dequantized keys and values (dequantize and
read, not a quantized kernel), so affine KV serves its ordinary, grammar,
speculative and fill rows, with checkpoints, before and after each row's
transition; main threw at the first forward past it. No artifact
holds those numbers, so the native Gemma2 suite (`MLX_BUN_GEMMA2_NATIVE=1`)
gates every phase at maxDiff 0 against the plain storage the graph composes
without a scheme, its fetched window requantized by mlx past the transition, and
holds the descriptor and mask cases to recorded synthetic digests
(`tests/models/synthetic-digest.ts`, fixtures under `tests/fixtures/synthetic-digests/`,
`scripts/synthetic-digests.ts record|check`, recorded per GPU architecture). Direct grammar jump commits its spans over any storage
through the shared span method, as main's jump did: one maintenance
call, then one unsplit forward of the pending token and the forced span, plain
across the start and over the converted layers after it. On 2026-09-28 UTC (M1 Max, MLX 0.32.2) the opt-in
`tests/parity/affine-grammar-spans.test.ts` (`MLX_BUN_TEST_AFFINE_SPANS_MODEL`)
passed on cached Gemma2-2B-4bit `2c715097` with KV4: below the transition, B1
spans matched direct jump-forward generation in tokens, matcher history and
every projection's bytes (a row crossing it was then refused, which this tree
no longer does); an interleaved peer matched its solo run and the
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
take the same encoded-read path: affine KV, immediate or delayed, batches,
speculates and takes generation checkpoints across its conversion. On 2026-09-28 UTC (M1 Max,
MLX 0.32.2), cached Qwen3-4B-Instruct-2507-4bit `50d42775` matched mlx-lm
0.31.3's `generate_step` order bit for bit in six greedy steps' full logits
through direct generation with KV8 and KV4 at starts 0, 8 and 14 (a one-off
comparison); the opt-in spans test and the ordinary-continuation test (KV8 from
0, KV4 from prompt+4, KV8 from prompt+2) passed on it; and a grouped n-gram
draft over immediate KV8 and KV4 reproduced ordinary greedy output. No
Qwen3-MoE artifact was run.
On encoded-read universal graphs, Qwen3 and MiniCPM5, whose verifiers qualify
grammar proposals, grammar jump is planned as verified proposals over every KV
scheme; bound directly, the span method commits spans over their delayed affine
rows with no dense-read requirement, before and after conversion.
The same opt-in real-weight spans test passed on cached MiniCPM5-1B-OptiQ-4bit
`664aabae` and Qwen2.5-0.5B-Instruct-4bit `a5339a41` with KV4: B1 spans matched
direct generation in tokens, matcher history and every projection's bytes, both
below the transition and for a row converting three tokens into decode and
continuing over converted layers; an interleaved peer matched its solo run. On 2026-09-27 UTC (M1 Max, MLX 0.32.2) at `a9b60646`,
a custom graph over unchanged Llama-3.2-3B-Instruct-4bit weights with window 8
(not a published model) matched main at B1 in full logits and all
valid cache planes for bf16, immediate affine, KV4 and KV8 converting in decode
after the ring wrapped, and KV4 converting in prefill at token 32. Gateway and
direct execution agreed at B1 and B2, with rows converting separately, a
prefill-converted joiner, a cancelled row's survivor and same-group reuse
matching a fresh group; the continuation test restored B1 and B4 rows in a
fresh process for KV4 and KV8. Gemma4's delayed rotating rows share the
single-row adoption: on e4b OptiQ-4bit, one-block and wrapped singletons matched
main through conversion (hidden states, logits, valid planes and
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
- With the composition's `grammarJump` on: the speculative group verifies the matcher's
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

With the composition's `grammarJump` on, Gemma2 plain-KV ordinary requests preserve
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
binding: with `MLX_BUN_GEMMA2_MODEL`, the batching test replays main's fill
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
a same-count stop control, and checks main's grammar gate. Draft providers whose
rows tap target hidden layers keep a typed refusal (this graph declares no taps);
KV schemes and paging are its composition's legos, read through the softcapped
read above.
Its full-attention policy remains the pinned mlx-lm policy documented in the
[architecture descriptor](src/models/universal/archs.ts).
A plain-KV adapter request with a configured TwoModel or Ngram draft uses
ordinary continuous decoding and ignores both draft and fill, as main did.
This is ordinary decoding, not adapter speculation support. Paired B1 greedy
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

The [Trellis variant test](tests/parity/trellis-shared-m.test.ts) takes
`MLX_BUN_TEST_TRELLIS_MODEL=/cached/packed-qwen`. It preserves main's variant
comparison: `MLX_BUN_TRELLIS_AB_VARIANT` (default 7) against
`MLX_BUN_TRELLIS_AB_BASELINE` (default 6). Use variant 13 against baseline 12
for the optimized expansion path. `TrellisLinear` passes only variant 13, so the
test runs the generic Qwen3.5 graph with MLPs it builds over the loaded weights,
each passing its variant explicitly. M=1–5 compares complete logits, recurrent/KV
state and continuation; variant 13 also checks M=16/128/512 with the last-position
head. Six alternating-order blocks also screen the last-position head at
M=1–5/8/9/16, M=32 for variants 11–13, and M=128/512 for variant 13.
These are exact within-artifact kernel-variant checks, not a Python oracle
or timing claim.

For variant 13, the `applegpu_g13s` single-row bf16 gate/up kernel at
5120 → 17408, matching 2/3/4-bit widths, T=256 and L=12 shares a 16 KiB
threadgroup codebook across sixteen output rows. Its values retain the unrefined
float32 decoder contract, scale multiplication, accumulation order and activation
tail. At the same qualified single-row bf16 geometry, mixed-width gate/up and the
2/3/4-bit down kernels construct the decoder's integer value through exact
float32 mantissa bits before the unchanged reciprocal multiply. This preserves
scale multiplication and reduction order. The qualified down kernels also
generate a 16 KiB float32 threadgroup codebook, using 128/512/256 threads for
2/3/4-bit weights respectively. All 128 partial sums and their reduction order
remain unchanged. Other shapes and shared multi-row kernels keep their existing paths.

These representations are required kernel arguments: `fusedGateUpSwiglu`'s
`codebook`, `fusedGateUpSwigluMixed`'s `exactBits` and `trellisScatter`'s
`ScatterRepresentation` (`bits` for the balanced 3-bit down, `genericBits` for
2/4-bit down, `floatCodebook`). `qualifiedRepresentations(architecture)` turns
them all on for `applegpu_g13s` and off elsewhere; `TrellisLinear` resolves it
once at construction and passes the stored result. Passing `false` selects the
original inline decoding and conversions for A/B runs; disable the float codebook
as well when comparing the down representations.
The [kernel test](tests/kernels/trellis-gateup-codebook.test.ts) checks all 4096
codebook values, all 1021 possible integer decoder values and fused outputs;
the [artifact test](tests/parity/trellis-gateup-codebook.test.ts)
uses `MLX_BUN_TEST_TRELLIS_MODEL` to compare complete finite logits, live cache state
and greedy continuation, running the generic Qwen3.5 graph with MLPs that pass each
representation explicitly. The [standard-request benchmark](../../apps/mlx-bun/scripts/bench-trellis-gateup.ts)
provides `--help`, requires local weights and an external output path, and runs
one fixed prompt with 256 greedy tokens and MTP off.

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
helpers; the subpaths below expose individual components.

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
| `trellisScatter(x, codes, scales, geometry, variant, useSharedScatterCodebook, representation)` | Axis-0 projection; same input shape and row budget |
| `fusedGateUpSwiglu(x, gate, up, variant, codebook)` | Matching axis-1 gate/up geometry and bit width; preserves leading input dimensions, with 1..4 total rows |
| `fusedGateUpSwigluMixed(x, gate, up, variant, tail, exactBits)` | Matching axis-1 geometry with independent bit widths; `tail` is `"fused"` or `"split"` |
| `gateUpReduceRow(x, gate, up, variant, codebook)` / `gateUpReduceRows(x, gate, up, variant)` | `fusedGateUpSwiglu`'s one-row / 2..4 shared-row kernel alone |
| `scatterRow` / `balancedScatterRow(x2, codes, scales, geometry, variant, representation)` | `trellisScatter`'s one-row kernel alone; balanced takes 3-bit codes at T 256, the other every other width |
| `scatterRows(x2, codes, scales, geometry, variant)` / `balancedScatterRows(..., sharedCodebook)` | `trellisScatter`'s 2..4 shared-row kernels alone, the same split |
| `expandTrellis(codes, scales, geometry, dtype, variant)` | General expansion, and variant 13's vector form |
| `tiledTrellisPrefill(x, codes, scales, geometry)` | Axis-1 packed prefill, M=5..32 |
| `splitKTrellisPrefill(x, codes, scales, geometry)` | Axis-0 packed prefill, M=5..8 |
| `wideTrellisPrefill(x, codes, scales, geometry)` | Axis-1 prefill following MLX's GemvWide arithmetic, M=5..15 |

`gate` and `up` are `TrellisWeights`: `{ codes, scales, geometry }`.
Callers supply compatible tensors and choose the variant explicitly. Existing
variant numbers are preserved: 6 uses the original packed f32 code/scale path;
13 adds the shared-work and vector-expansion forms. Variant 4 is
the inherited timing-only path and does not compute decoded weights correctly.
No application environment flags are read by these operations.

For prefill, use the corresponding `*Eligible(geometry, rowCount, dtype)` helper
to preserve the existing dispatch profile; the wide and tiled helpers also take
`widePrefill` from `qualifiedRepresentations(architecture)`, which a caller
resolves once. Wide prefill additionally requires caller-proven aligned,
row-contiguous input. These profiles and numerical
contracts are unchanged; they are not universal dispatch rules for every shape.

Single-purpose kernels from the same entry point: each runs one algorithm for
one row form and one code layout, takes no options beyond the mixed-width
SwiGLU tail, and checks its inputs. The factored kernels decode each weight's
code value y and apply the row scale (with 1/147.8) once per output, or fold it
into each input row's activation; the matrix kernels run on the simdgroup matrix
unit. Both reassociate relative to variant 6 and agree with it to bf16
precision, not bit for bit. The codebook kernels look each code value up in a
threadgroup table and keep variant 13's one-row output bits.

| Operation | Input and purpose |
| --- | --- |
| `gateUpFactoredRow(x, gate, up)` / `gateUpFactoredRows(x, gate, up)` | Same-width axis-1 gate/up/SwiGLU; one row / 2..4 rows sharing each decoded weight |
| `mixedGateUpFactoredRows(x, gate, up)` | Different-width gate/up, 1..4 rows; MLX's compiled-swiglu tail |
| `downFactoredRow` / `downFactoredRows(x2, codes, scales, geometry)` | Axis-0 projection over row-major codes; one row / 2..4 rows |
| `downK3InterleavedFactoredRow` / `downK3InterleavedFactoredRows(...)` | The same over 3-bit block-interleaved codes (T 256, L 12) |
| `gateUpMma(x, gate, up)` | Gate/up/SwiGLU for 1..8 rows; widths may differ |
| `gateUpCodebookRow(x, gate, up, tail)` | One-row gate/up/SwiGLU through a threadgroup codebook; widths may differ; the reduce kernels' bits |
| `downCodebookRow` / `downK3InterleavedCodebookRow(x2, codes, scales, geometry)` | One-row axis-0 projection through a threadgroup codebook, row-major 2/4-bit / 3-bit interleaved codes; the scatter kernels' bits |
| `downMma` / `downK3InterleavedMma(x2, codes, scales, geometry)` | Axis-0 projection for 1..8 rows, row-major / 3-bit interleaved codes |
| `gateUpMmaWide(x, gate, up)` | Gate/up/SwiGLU for any number of rows, each decoded fragment feeding several 8-row blocks (threadgroup codebook, activations staged in threadgroup memory); each row the bits `gateUpMma` gives its block of 8 |
| `downMmaWide` / `downK3InterleavedMmaWide(x2, codes, scales, geometry)` | Axis-0 projection for any number of rows through a threadgroup codebook, each decoded fragment feeding up to three 8-row blocks in the pass the rows plan (`downMmaWidePass` / `downK3InterleavedMmaWidePass` take the pass, `DOWN_ONE_BLOCK` for 1..8 rows); each row the bits `downMma` gives its block of 8 |
| `gateUpCodebookMma(x, gate, up)` | Gate/up/SwiGLU for 1..8 rows, each code value read from a threadgroup codebook (the M1 Max form); `gateUpMma`'s bits |

Outside the Trellis family, `kernels/quantization/affine{3,4}-{rows,mma}` run
3- and 4-bit group-64 affine projections for 2..8 rows (shared decode) and
1..8 rows (matrix unit), and `affine-split-mma` any number of rows of either width,
in blocks of 8, on the matrix unit with output tiles sharing each activation
fragment and K split across the threadgroup (the M1 Max form); `affine-row` is one
row of either width bit for bit MLX's one-row quantized matmul (its qmv's
arithmetic, each threadgroup computing the activation chunks once for 64 rows);
`kernels/attention/kvq4-decode` is one-row attention
over a 4-bit group-64 KV cache with head dim 256, reading each packed row once
for all query heads of its KV head, the tokens per threadgroup the caller's (512 on
the M4 Pro, 128 on the M1 Max); `kernels/attention/multi-query` is causal
flash decoding for 2..8 query rows over a BF16 cache. `kernels/ane` holds the
Neural Engine programs (`linear`) and the GPU kernels that fill their buffers
(`fill`). The layers in `layers/trellis-gate-up`, `layers/trellis-down`,
`layers/trellis-codebook-gate-up`, `layers/trellis-codebook-down`, `layers/affine-verify-linear`, `layers/kv4-decode-attention` and
`layers/ane-prefill-split` bind loaded weights to these kernels, one kernel per
layer.

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
  and `TrellisLinear`, which composes the standalone Trellis kernels at decode
  variant 13 and retains the existing row-count dispatch and dense expansion.
  `ExpandedTrellisLinear` is the 8-bit affine carrier a caller constructs explicitly.
- `@mlx-bun/inference/layers/lora`: inference-time LoRA state and weights.
- `@mlx-bun/inference/runtime/config`: immutable execution settings and scoped
  overrides for the `MLX_BUN_*` keys the library still reads (process settings,
  diagnostics and test opt-ins; the website's configuration reference lists each
  read site). A model-level option is a composition field instead (above).

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
`models/gemma4/graphs`, `models/minicpm5`, `models/qwen3`, `models/qwen3-moe`,
`models/qwen3_5`, `models/qwen38-27b-trellis-m4pro`, `models/qwen38-27b-trellis-m1max`,
and `models/universal`.
`models/glm52`, `models/diffusion-gemma`, `models/whisper` and `models/moss-image`
(a text-to-image pipeline, see [Text-to-image](#text-to-image)) provide the other
graph families.
`@mlx-bun/inference/models` exposes the profile/implementation registry, the
composition resolver and loading helpers: `createModel` loads the graph
its family's selection table (`MLX_GRAPH_TABLES`) recommends for the composition,
else the family's generic graph. Direct graph
constructors remain available. Runtimes
that plan memory before opening weights (streamed experts) are opened with
`openPlannedRuntime` from generic `RuntimeOpenOptions` and return a generic
`MemoryPlan` and telemetry; `planRuntimeMemory` (`models/memory-plan`, native-free)
returns the plan from artifact headers, or null for models without one. A graph
that carries its own draft head declares it (`GraphCapabilities.nativeDraft`), and
`DraftProviderRegistry.native(graph)` builds the provider.

`models/qwen38-27b-trellis-m4pro` and `models/qwen38-27b-trellis-m1max` are
separate written files for `mlx-bun/Qwen3.8-27B-Trellis-3.2bpw`. Each names all 64
layers and the literal projection and MLP forms for its row bindings. M4 Pro
keeps its factored row and matrix-unit kernels. M1 Max names its threadgroup
codebook forms at one row, codebook matrix-unit forms at two to eight rows,
wide matrix-unit forms at nine to 256 rows, and expanded GPU forms above that.
Its prompt projection forms also retain the measured dequantized matmuls.
Its one-row binding fuses the attention residual addition with the MLP's
normalization, the recurrent normalization with its float32 SiLU gate, and
the convolution's SiLU with Q/K normalization and scaling. These retain MLX's
intermediate dtype rounding and reduction order. The
[normalization tests](tests/kernels/normalization-fusion.test.ts) compare raw
and compiled forms bit for bit, including changing shapes and layer weights;
the [DeltaNet heads tests](tests/kernels/delta-heads.test.ts) cover the fused
activation, Q/K scales, V output, and strided convolution inputs.

The files declare the Neural Engine program ranges directly: M4 Pro uses
640..1024, 1025..1536 and 1537..2048 positions; M1 Max uses fifteen capacities
from 256 to 2048, beginning at 224 positions. The scheduler indexes those ranges
for one-sequence pieces, and installation compiles the listed programs. Each
file also states its measured verification costs and draft-gate settings.

The loader recommends a file from its artifact, device and module-configuration
keys. These are defaults: callers can explicitly choose a differently tuned file,
a portable or device-tuned generic family graph, or supply an ordinary load function to `openModel`'s
`graph` option. A custom function needs no family registration and returns the
operations its caller needs, including a graph with prefill and scoring alone.
The code-authoring rules do not restrict those choices.

For explicit state and tensor operations, compose the cache legos with
`composeGraphCaches(graph, configuration)` or use the loader-bound `makeCache`.
Use `MlxPhaseDispatch` to index prompt ranges and exact-row `decode`, `verify`
and serving `logits` tables. Chunk-specific ranges preserve a file's distinct
chunk and tail operations when it declares them. Known appends use whole-span ranges, preserving
arbitrarily long accepted grammar spans without imposing the verifier's row cap.
Scoring heads, media and denoising consumers index their own declared ranges. Each file declares verification costs and known-span operations
where measured. `examples/qwen3-forward.ts` runs a prompt and a decode through
these public components. Dispose each cache and returned array when finished.

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

`@mlx-bun/inference/state` exposes the cache legos (plain, affine, rotating,
TurboQuant, recurrent, paged and GLM's latent caches, each owning its storage and
its read), their row layouts, KV maintenance, the cache service, cloning, and
persistence. The caller creates and owns the state.
`@mlx-bun/inference/contracts` holds the shared cache and ownership interfaces.
A rotating cache's `temporalView()` is its live window: the newest
`min(offset, maxSize)` positions in chronological order, including right after a
multi-token write leaves the ring oversized. A request's own rotating cache and
its batched, speculative and aligned layouts select the same window.
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
  Every storage a graph's caches (or their precision maintenance, or paging) produce
  declares its three row layouts together in `state/layout`'s table, each implementing
  the `BatchableCache` port: `ownedCacheLayout` for ordinary continuous decoding,
  `prefillCacheLayout` for prefill cohorts and `targetCacheLayout` for verification
  rows, which hold the speculative transaction (`SpeculativeRowLayout`). The
  [cache contract test](tests/state/cache-contract.test.ts) runs every lego through
  every read, these layouts, the transaction, snapshots and SSD. The
  batch group only calls `mergeRows`, `filterRows` and `extractRow` on it and names no
  storage family; the gate rejects `execution/` importing a concrete cache module.
  A request's own cache is a row source for its layout, not a batch: an adopted lone row is the
  first source of the layout's first `mergeRows`.
- `layers/quantized-attention.ts`: the affine attention kernels (mlx-lm's unfused
  port, OptiQ's tiled port, the folded and grouped-heads forms). An affine lego
  takes its kernel set at construction (`state/affine-attention`: unfused or
  tiled-causal as the composition names, or the opt-in always-tiled set).
- `layers/folded-attention.ts`: bf16 causal windows of up to eight queries that MLX's
  fused SDPA hands to its unfused fallback (more than 32 query vectors per KV head),
  with GQA folded into rows: that fallback bit for bit, each KV head's keys and values
  read once instead of once per query head. A bf16 storage reads its windows with the
  read its composition names (`KVCache.windowRead`: `sdpaRead`, or `foldedWindowRead`),
  and its row layouts and clones with the same.
- `kernels/turboquant/`: packing, rotation, codebooks, and packed decode kernels.
- `kernels/delta/gated.ts`: DeltaNet kernels; recurrent storage and its
  `recurDecode`/`recurWindow` live in `state/ssm.ts`. The training cache
  (`TrainingSSMCache`, the training forward) implements the same two calls with
  a backward attached that differentiates an ops recomputation of the recurrence.
- `state/paged/`: the paged lego (`--paged-kv`) and its persistence codec.
  The numerical attention implementation lives in `kernels/attention/paged.ts`.

Public kernel imports are `@mlx-bun/inference/kernels/turboquant`,
`@mlx-bun/inference/kernels/delta`, and
`@mlx-bun/inference/kernels/attention/paged`. Paged state is available through
`@mlx-bun/inference/state/paged`.

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
- `models/audio/conformer`: the audio encoder graph. `transcription/silero-vad`:
  the voice-activity gate transcription runs before Whisper.
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
`MediaFetchPolicy.allowPrivate` permits LAN destinations; callers may supply
`privateDestinationHint` when their UI needs a specific configuration instruction.

## Text-to-image

A text-to-image family binds three stages to the contracts in
`contracts/mlx/image-generation`: an `ImageConditioner` (prompt text to the
sequence a denoiser attends to), an `ImageDenoiser` (the flow-matching velocity
of latents at one timestep) and an `ImageLatentDecoder` (latents to RGB in
[-1, 1]), with the noise levels of a `FlowMatchingSchedule`. Each contract states
its tensor shapes, dtypes and ownership. A `TextToImagePipeline` opens each stage
on first use and frees its weights on `release`, so a caller can hold one stage
at a time. `openImagePipeline` (`@mlx-bun/inference/models`) opens a pipeline
snapshot through the family registry and loads no weights; `openModel` refuses
one with an `UnsupportedModelLoadError` naming `openImagePipeline`.

`generation/image` runs a request over those contracts and names no family.
`resolveImageRequest` applies the pipeline's defaults and validates every field
before any stage opens. `encodeConditioning`, `denoiseLatents` and `decodePixels`
are separately callable: the denoiser takes flow-matching Euler steps,
`x + (sigma_next - sigma) * v` in float32, with the velocity of the request's
`GuidanceStep` (`ConditionalVelocity`, or `GuidedVelocity`'s
`uncond + scale * (cond - uncond)` with skip-layer guidance on the unconditional
branch), chosen once per request by `guidanceFor`; pixels are
`round(clip(image / 2 + 0.5, 0, 1) * 255)` read from row-major memory.
`generateImage` runs the stages in order. It releases each stage once its output
is evaluated unless the caller passes `releaseStages: false`, checks cancellation
at every stage boundary and after each load, and on failure or cancellation
releases what it opened and frees every tensor it made. Equal seeds give equal
noise on this backend only. [`image-generation.test.ts`](tests/generation/image-generation.test.ts)
drives every path with substitute stages.

### MOSS-Image

`models/moss-image` (public as `@mlx-bun/inference/models/moss-image`) is the
MOSS-Image family from OpenMOSS: a diffusers snapshot whose `model_index.json`
names `MOSSImagePipeline`. Base and SFT share every component's structure (SFT's
DiT weights differ; its text encoder, tokenizer and VAE are the same files), so
one family and its generic graphs serve both. The family writes its own layers,
composed from kernels, and its graphs arrange them:

- conditioner (`text-encoder`, `text-layers`): the Qwen3.5-9B language model as
  transformers runs it (`Qwen3_5Model` without a head): float32 `(1 + gamma)`
  norms, partial rotary embedding, gated attention, and linear attention in
  the CPU reference's dtypes and order: q and k l2-normalized with bf16
  operations, the gated norm's float32 normalization stored in bf16 before its
  bf16 weight and float32 `silu(gate)`, the log-decay in float32, and the
  recurrence in float32 from a zero state (`kernels/gated-delta-float32`, bound
  by `MossTextDeltaRecurrence` alone). Two operations differ from the
  reference's and are measured against it: the recurrence steps token by token
  where the reference solves 64-token chunks with cumulative log-decays, and
  softplus is `logaddexp(x, 0)` where the reference computes `log1p(exp(x))`.
  The conditioner runs once over the prompt rendered with the tokenizer's chat template (thinking enabled),
  truncated to 4096 tokens, with no token cache. The vision tower is never read.
- DiT (`transformer`, `blocks`, `rope`, `layers`): 42 joint blocks over
  [image, text] tokens under one shared timestep modulation, the two-block text
  refiner, four-axis rotary embedding and the SITU activation (`kernels/situ`).
- decoder (`vae`, `vae-layers`): the FLUX.2 VAE decode path in float32 after the
  batch-norm de-normalization and the 2x2 unpatchify.
- schedule (`scheduler`): the shifted grid snapped to the training grid, float32
  rounding replayed at the reference's operation boundaries, including
  `torch.linspace`'s fused multiply-add.

Each projection and the token embedding bind as the checkpoint stores them:
dense, or MLX affine-quantized with `.scales` and `.biases` and a quantization
table entry; metadata that disagrees with the stored tensors fails at
construction. The defaults are the model card's: 1024x1024, 50 steps, guidance 3,
an empty negative prompt and block 22 skipped on the unconditional branch.
Written graph files for one model on one machine are follow-up work once
profiling chooses their bindings. `@mlx-bun/quantize`'s `quantizeMossImageDir`
builds a local MLX artifact ([quantize README](../quantize/README.md)). The
[ownership test](tests/models/moss-image-ownership.test.ts) holds the family to
its own layers: no imports of other families or shared `layers/`, the SITU kernel
called only inside `MossSitu`, graph files that import neither MLX operations nor
kernels, and no method that branches on a field fixed at construction.

Memory, measured on the M4 Pro (24 GB) on 2026-10-23, Base, 4 steps, seed 1, each
workload in its own process. The OS columns are the process's peak memory
footprint and maximum resident set from `/usr/bin/time -l`; the MLX column is the
allocator's peak. The machine was swapping throughout (8.5 to 12.2 GB of swap in
use, and macOS grew the swap file from 10 to 13 GB), so these runs show completion
under memory pressure, not a fit with headroom. The near-constant 18.4 GB staged
footprint is not explained.

| Workload | OS peak footprint | OS max RSS | MLX peak |
|---|---|---|---|
| q8, stages released, 512x512 | 18.43 GB | 10.13 GB | 7.87 GiB |
| q8, stages kept, 512x512 | 18.38 GB | 11.14 GB | 17.05 GiB |
| bf16, stages released, 512x512 | 18.41 GB | 11.68 GB | 14.80 GiB |
| q8, stages released, 1024x1024 | 18.43 GB | 9.36 GB | 8.15 GiB |
| q8, stages kept, 1024x1024 | 21.34 GB | 9.95 GB | 22.20 GiB |
| bf16, stages released, 1024x1024 | 18.42 GB | 10.77 GB | 14.80 GiB |

One run at the model card's defaults (bf16 Base, 1024x1024, 50 steps, stages
released, seed 7) through `mlx-bun image` completed in 715 s: 6.8 s encoding, 693 s
denoising (13.9 s a step, two DiT passes each under guidance) and 14.6 s decoding.
Its OS peak footprint was 18.48 GB and its maximum resident set 8.98 GB, while swap
in use grew from 6.2 to 9.0 GB. That is one run on a machine that was not idle, not
a performance figure.

## Speculative generation

`bun --no-env-file scripts/bench-mtp.ts --help` describes the paired MTP
performance runner. It consumes this package's production batch-one grouped
method with local target and companion artifacts, pins their content, warms
each proposal depth, and reverses variant order on alternating repetitions.
Reports stay outside the checkout. It records accepted draft proposals and
delivered tokens separately: depth two permits at most two accepted drafts,
while a fully accepted round can deliver three tokens including its bonus.
The optimization score is total delivered tokens divided by total step time;
accepted drafts per step time, request/first-token/decode time, per-position
acceptance, peak MLX memory and output token identity are also recorded.

Separate diagnostic runs report draft, verification, sampling and commit wall
time. They disable device-first overlap and evaluate retained state through
the target and Qwen MTP materialization hooks, including commit work that would
otherwise execute in the next round. Their throughput is not a production
performance estimate. These checks cover plain KV, greedy sampling and B1;
kernel candidates still need their numerical/state gates and serving checks.

The standalone `scripts/bench/build-q4-native.sh` probe builds an offline Metal
library and a native MLX `Primitive` with `output_shapes`, bypassing
`fast.metal_kernel`'s shapeless limitation. It reads packed affine Q4 directly
and shares decoded weights across verification rows. This is a lab experiment,
not a runtime dispatch choice or a Trellis decoder. Its exact Q4-to-half and
BF16-to-FP32 conversions do not establish reduction-order parity; the executable
reports equality and error against MLX separately from projection timings.
Build inputs must match the installed MLX version. The script's usage lists
the required MLX source, Metal C++ headers, native libraries and external output
directory. Offline compilation needs Xcode's Metal Toolchain component;
`--runtime-compile` instead uses macOS's compiler through the native Metal
backend, still without `fast.metal_kernel`. The probe checks all 16 Q4 codes
and all 65,280 finite BF16 bit patterns before measuring projections. Append
`mma` to the executable's arguments to measure its register-only matrix-product
candidate instead of its shared-weight scalar reduction. Both are experiments;
the current runtime dispatch is unchanged.

`generation/speculative` exposes the draft contract and the assistant, two-model,
Qwen/GLM MTP, DFlash, DFlash 2, DeepSpec, and n-gram proposal providers. A provider
drafts only through its grouped rows (`DraftProvider.grouped`), in the gateway's
speculative group; one request is a group of one row, and there is no per-request
draft source. DFlash 2 (`incoai/Qwen3.8-27B-DFlash2`) drafts a whole block in one pass from
five tapped target layers, with
its projections quantized at load to the width the registry passes (4 bits). `bindMlxGateway(model, { provider,
numDraftTokens, adaptiveDepth })` drafts `numDraftTokens` every round, or with
`adaptiveDepth` chooses each round's count (up to that, none included) from the decayed
acceptance at each draft position and the graph's declared `verifyRoundCosts`, weighing a
round of B sequences by the rows it verifies, B(k + 1), against a step without drafts over
the same B rows (past the widest measured forward, at that forward's cost per row). The app
passes `numDraftTokens` as the drafter's own width, or, for an adaptive drafter of a kind
the graph lists in `adaptiveDraftWidths` (the M1 Max graph: an MTP head, 4), the width
measured there; the composition's `draftDepth` records the drafter's own. A round
without drafts is the graph's decode step, pipelined as plain decode is: built from the
previous step's samples on the device before they are read, its input dropped again
(`bindRowStepRollback`) if that sample ends its row. A run of such rounds probes at
intervals that double while drafting keeps not paying: a drafter whose rows draft without
committing (`preview`: the DFlash 2 block, or the Qwen MTP head's first draft under a round of
its own cache that it rolls back) proposes from a step's input and the steps that follow compare
its proposals with their samples; any other drafter verifies one draft. A graph whose composition measured them
declares the gate's constants per drafter kind (`adaptiveDraftGates`: the prior's acceptance and weight, the decay per
round and per step without drafts, the margin, the probe intervals and depth; the M1 Max graph, for DFlash 2 and the
MTP head, counts that keep 95% per observing round and 93% per step without drafts, DFlash 2 probing one draft deep);
other graphs and kinds keep the gate's defaults. A target graph whose residual stream
carries a TurboQuant R1 fold declares it on its draft target (`residualBasis`: the R1 seed and the
final-norm gain the fold moved into the head); the drafter loads unrotated and applies it when a draft group binds.
A graph whose composition measured them declares the kernels of a drafter's own 4-bit projections per width class
(`draftProjections`; the M1 Max graph: the affine row kernel at two to three rows, the split matrix-unit kernel from
four, MLX's quantized matmul at one); the DFlash 2 drafter builds them when its first group binds and
otherwise keeps its own rule (the simdgroup matrix unit at five to eight rows, MLX's quantized matmul otherwise).
A graph whose composition measured it declares the target's frequency-ranked draft vocabulary on its draft head
(`DraftProjection.vocabulary`: the M1 Max graph, the artifact's `mtp/draft_vocab.json`, those rows of its head on the
head's own layers, gathered when a drafter first reads them); DFlash 2 then projects onto those rows and selects among
them, the target still verifying over its full head.
A library caller speculates as the app does: `binding.plan` with `hasDraft`, then
`binding.methodRequest` and `submit` on `binding.createBatchGroup({ maxBatch: 1 })`
(`@mlx-bun/training/dspark`'s calibration runs this way).
`generation/speculative/binding` exports the target operations the groups bind
(`bindSpeculativeTargetModel`); they do not require a concrete model class.
Each request's draft selection is resolved when the binding binds the request and
keys its group: argmax under the composition's `greedyDraft`, else the draft vocabulary
the provider declares for the target (`draftVocabulary`, the Qwen MTP companion's
`draft_vocab.json`) when the request's draft sampler reproduces on it, else each
row's sampler over the full head. A drafter's rows bind one selection operation
when they open and their draft loop calls it; the assistant and DeepSpec drafters
bind their head's selection at construction the same way.
`generation/speculative/loader` (a file of `models/speculative`) loads a `dspark.json`
checkpoint (`loadDsparkDrafter`) and also exports the drafter class and its config types,
which `@mlx-bun/training/dspark` uses to produce those checkpoints.

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
and `models/speculative/*`. Drafters are models: `models/drafters` holds their artifact
conventions and `models/drafter-loaders` their lazy loaders (`loadAssistantDrafter`, `loadDeepspecDrafter`,
`loadDsparkDrafter`, `loadQwenMtpModule`), and hands the sources the ports of
`contracts/mlx/drafter`; a graph that declares `nativeDraft` also provides
`nativeDraftHead()`. Sources and the packages above (quantization included) never name
a drafter class. Proposal sources live in `generation/speculative/sources`;
verification and acceptance belong to `generation/speculative`; batched draft work
belongs to `generation/speculative/bindings`; draft checkpoints belong to `state/speculative`.
Existing sampling, rejection, rollback, and kernel behavior is preserved.
One intentional correction: grouped speculation maintains a reused target prefix
before its first forward. A round without drafts maintains only before its append,
so under a delayed KV scheme a stored prefix can still owe the conversion its last
append reached. Main read that prefix unconverted in its first batched
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
the binding's group: B1 repeating exactly, B4 cohorts that prefill together and repeat,
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
other providers, except the KV matrix: this test takes plain KV only and no custom
window for this kind (the latent cache's affine, TurboQuant and paged legos are
gated over synthetic weights by `tests/models/glm52/` and the cache contract test,
not here):
`MLX_BUN_TEST_SPEC_TARGET=/GLM-5.2 MLX_BUN_TEST_SPEC_KIND=glm-mtp bun --no-env-file test packages/inference/tests/parity/speculative-group.test.ts`.

`state` also exposes the byte-limited `PromptCache`, retention policies, row state,
and checkpoint attachments. The caller owns cache lifetime and reuse namespaces.

## Optional execution and persistence

`execution` exposes `createInferenceEngine`, method adapters, cancellation,
admission, and continuous batching. Supply an execution planner and its graph
bindings; the engine manages in-process session lifetimes and bounded output.
It opens no network listener. `createAutoregressiveMethod` and
`createDenoisingMethod` adapt the direct methods when a consumer needs sessions;
speculation runs only in the batch group. `MlxBatchExecutionGroup` owns batched rows;
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
fill requests are refused with typed plan reasons; its caches are the legos the composition's KV scheme and paging name. `DenoisingKeys` reproduces MLX's
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

`state/cache-service` composes the RAM prompt cache, the KV budget, the saved-state
store and paging into one service per loaded model,
`createKvCacheService(graph, options)`, constructed with its budget (the RAM cap,
`kvBudgetBytes`, a saved-state root with its shared byte budget, and the graph's
paging): the batch group takes it as `cache` and only acquires a request's state
(the prompt tokens it already covers, 0 for a miss), publishes state back,
offers continuation checkpoints and releases the request; it never sees what is
resident, evicted or saved. The service resumes a replayable generation under the
key its continuation request names, with the request's sampler, pending token,
adapter and cache identities. `report()` is what it holds. `SsdCacheStore`,
`TieredPromptCache` and `SsdDurabilityCoordinator` remain for callers composing
their own parts. Applications choose their own storage paths,
capacity, scheduler settings, and shutdown lifecycle. A store's directory is
`<dir>/<configFingerprint>/`; the app's fingerprint joins architecture, KV scheme,
binding compatibility and the hub's resolved model-directory identity. HF snapshot
revisions have separate directories; startup does not hash weights. If weights are
replaced in place, clear saved KV for a fresh run. `scan()` skips, and
never deletes, files whose header names another identity; only its own corrupt
files and `.tmp` orphans are removed. Saved KV is disposable; changes to the
store identity rebuild the cache.

## Scoring

`scoreDecisionAnswers` takes a structural `DecisionScoringGraph`, prompt tokens,
and complete candidate token sequences. It teacher-forces each candidate, applies
the head only to answer-predicting rows, and normalizes average response token
log likelihoods across candidates. It returns `meanLogLikelihoods` and their
softmax `probabilities`. No sampling or generation loop runs. Include the
answer terminator in each candidate; it counts in the average. An optional `execute` callback schedules
each candidate separately; direct consumers can run under their own graph lease.
Prepared media uses the graph's `MlxPromptInput` to feed the supplied tokens at
their positions. Every candidate owns fresh caches, released before it settles.

`sequenceLogProbabilities` and `logitsFromHiddenPadM` are the existing DPO
response-mask reduction and DPO/ORPO head geometry, now owned here and consumed by
training. Response log likelihoods normalize logits in float32 before reduction,
including bf16/f16 inputs, and preserve differentiability. API
schemas, answer text encoding, confidence, and wire responses belong to the app.
`sequenceLogProbabilitiesFromHidden` applies the same scorer after gathering
only response-predicting hidden rows. DPO uses it for both policy and reference:
the transformer still sees the full sequence, while head logits are bounded by
the longest response in the batch. Sparse and weighted masks retain their meaning.

`scoring` exposes `forwardSequence` / `forwardSequenceHidden` for full-sequence
logits and hidden states, including the existing padded-batch masks. The original
`trainForward` names remain aliases for compatibility. `evalPpl` computes
perplexity over caller-provided token rows; `klPerToken` compares supplied logits.
Neither requires an evaluation dataset registry or runner; the app's
`mlx-bun perplexity` drives `evalPpl` over a local text/JSONL file. Tool-call
parsing is available from `input`; template/schema fill compilation lives in
`generation/fill`.

Standalone app bundles keep the expert-I/O library, the Neural Engine bridge
and the frame extractor beside the executable. Explicit
`MLX_BUN_EXPERT_IO_DYLIB` / `MLX_BUN_ANE_DYLIB` / `MLX_BUN_FRAME_EXTRACT`
overrides take precedence; ordinary source/package execution resolves the
package's `dist/native` directory. The app bundle verification covers relocation
without loading native numerical code.
