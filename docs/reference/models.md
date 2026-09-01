# Models: supported roster + management (get / scan / ls / gc)

The one supported-model list, plus how mlx-bun downloads, indexes, lists,
and reclaims models. The store is the standard Hugging Face hub cache —
nothing proprietary; `hf` and mlx-lm read/write the same tree.

## Supported models

The source of truth is code, not this table: `src/model/profile.ts`
(which `model_type` loads via which graph), `src/model/support.ts` (the
support tier `mlx-bun ls` prints), `src/model/universal/archs.ts` (the
Tier-0 descriptor table), `src/spec/source.ts` + `src/server.ts` (draft
sources), and the `instanceof` gates in `src/server.ts` for image / video /
audio. If this table and the code disagree, the code wins and this table
is the bug.

Scope is deliberate: a few families held to explicit oracle contracts
(L1 = bit-exact vs mlx-lm, L2 = bit-exact vs mlx-optiq, L3 = measured, no
oracle), plus a declared Tier-0 generic surface. There is no alias table —
the "query" column is a substring that `resolve()` matches against
already-downloaded repos (it must match exactly one repo; see
[Query resolution rules](#query-resolution-rules-per-verb)).

| `serve` query | Validated artifact (HF repo) | Family · load path · tier | Modalities | Draft sources | KV schemes | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `e4b` | `mlx-community/gemma-4-e4b-it-OptiQ-4bit` | Gemma 4 (`gemma4*`) · dedicated `gemma4` graph with a **generated** specialization keyed on the config fingerprint · L1 | text · **image** (SigLIP tower in the bf16 `optiq_vision.safetensors` sidecar) · **audio** (Conformer tower in the same sidecar) | two-model · Gemma `-assistant` (L2) · locally-trained DSpark (`dspark.json`) · ngram | bf16 · uniform 4/8 · `config` (kv_config.json, batches) · turbo · `--paged-kv` | **Default model** (`DEFAULT_REPO_ID`, src/fit.ts). The only audio-capable artifact. ~7.0 GB on disk (benchmarks.md legend, 2026-06-15). Trains (LoRA / ORPO / SFT). |
| `12B` | `mlx-community/gemma-4-12B-it-OptiQ-4bit` | Gemma 4 · generated specialization · L1 | text · **image** (encoder-free `gemma4_unified_vision` declared in config.json — no sidecar needed). No audio: the snapshot's sidecar is an audio **stub** (`embed_audio` only, no `audio_tower.*`) | two-model · `-assistant` · DSpark local · **DeepSpec released** (`deepseek-ai/dspark_gemma4_12b_block7`) · ngram | bf16 · uniform · `config` · turbo · `--paged-kv` | ~8.4 GB (2026-06-15). `largestRecommendedRepoId` pick for ≥ 24 GB RAM (src/fit.ts). Trains. |
| `26B` | `mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit` | Gemma 4 MoE · generated specialization · L1 | text · image **only if** the snapshot ships the SigLIP sidecar (registry `has_vision_sidecar`; the tower is `gemma4_vision`). No `audio_config` → no audio | two-model · `-assistant` · ngram | bf16 · uniform · `config` · turbo · `--paged-kv` | ~18 GB (2026-06-15). `largestRecommendedRepoId` pick for ≥ 48 GB RAM. |
| any other `gemma4*` config (1B, e2b, 31B, …) | — | Gemma 4 · the `Gemma4Model` monolith (no generated specialization) · L1 by family | per the registry's vision/audio flags | same as the family | same as the family | Loads by `model_type`; **no artifact is pinned in tests/support/goldens for these**, so treat as family-supported, artifact-unvalidated. |
| `MiniCPM5` | `mlx-community/MiniCPM5-1B-OptiQ-4bit` | MiniCPM5 · `model_type: llama` matched by exact shape (`isMiniCPM5Config`) → dedicated `minicpm5` graph · L1 / L2 | text | two-model · ngram | bf16 · uniform · `config` (batches — Phase 3.1) · turbo (quality curve measured 2026-07-06, benchmarks.md §3) | Sub-GB starter (benchmarks.md legend). Trains (segmented backward). Tool calling (XML). |
| `Qwen3.5-4B` | `mlx-community/Qwen3.5-4B-OptiQ-4bit` | Qwen3.5 (`qwen3_5` / `qwen3_5_text`, dense hybrid gated-DeltaNet) · dedicated `qwen3.5` graph · L1 | text (image/video only when the artifact ships vision weights — see Qwen3.8) | two-model · ngram · `mtp` if a `qwen3_5_mtp` companion exists | bf16 (L1) · `config` (KV-ON parity passed 2026-06-15, PLAN 14e) | Thinking + tool calling. Batches on the SSM path (`MLX_BUN_BATCH_SSM=0` reverts). The MoE variant `qwen3_5_moe` is **not** supported. |
| `Qwen3.8` | `mlx-community/Qwen3.8-27B-OptiQ-4bit` @ `b04599de95d7a9bfbd7f208d347c0f10d9432a42` | Qwen3.5 family · **exact artifact profile** `qwen3.8-27b-optiq-4bit` (safetensors + `qwen3.5` graph) · L1 | text · **image** · **video** (`image_url` / `video_url` parts; Qwen3-VL tower + mRoPE; video decodes via the AVFoundation sidecar `mlx-bun-frame-extract`, 2 fps, ≤ 768 frames). Video never combines with audio; no audio | **native MTP head** (`mlx-community/Qwen3.8-27B-MTP-bf16`, auto-detected `qwen3_5_mtp`; `--draft-kind mtp` with no `--draft-model` uses a bundled `mtp/` subfolder) · two-model · ngram | bf16 (L1) · `config` is **Lab** — policy copied from the same-topology Qwen3.6 artifact, no model-specific oracle (benchmarks.md, 2026-08-22) | `reasoning_effort` (xhigh/medium/low) + `preserve_thinking` + tool calling. `/v1/models` advertises vision. Shipped in v0.2.0. |
| `Qwen3-Embedding` | `mlx-community/Qwen3-Embedding-4B-4bit-DWQ` | plain `qwen3` · dedicated `qwen3` graph · L1 | text | — | — | **Embeddings only**: `/v1/embeddings` + `mlx-bun embed`. Auto-picked by `embed` when no query is given; never the chat default. |
| `Qwen3-30B` | `mlx-community/Qwen3-30B-A3B-Thinking-2507-4bit` | Qwen3-MoE (`qwen3_moe`) · dedicated `qwen3-moe` graph · L1 (opt-in slow parity test, `MLX_BUN_TEST_QWEN3_MOE=1`) | text | two-model · ngram | bf16 (the artifact ships no kv_config.json) | Sparse top-k SwitchGLU experts. |
| `diffusiongemma` | `mlx-community/diffusiongemma-26B-A4B-it-OptiQ-4bit` | DiffusionGemma (`diffusion_gemma`) · dedicated graph + **denoising loop** (non-autoregressive) · L2 (optiq) | text · **image** (single image; its own inline-quantized SigLIP tower). No video / audio | — (no AR verify loop) | — (canvas model; the `--kv-quant` axis does not apply) | Serial lane always. Diffusion-native LoRA trains. |
| `GLM-5.2-colibri` | `mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp` @ `3cc8db99b1b13fc79325d987ba3c1c430766b3b8` | GLM-5.2 (`glm_moe_dsa`) · **Colibri container loader** + dedicated `glm5.2` graph (streamed experts) · **exact artifact profile**, L3 | text | **checkpoint-native MTP** (`--mtp on`, the default; mutually exclusive with `--draft-model`) | checkpoint-native compressed **MLA/DSA** cache (its own scheme; SSD tier v3 persists it) | Fixed-context admission: `--context-length` (4096) and `--max-tokens` (128) are reserved by the header-only resource equation before weights open; `--memory-budget` defaults to min(25 GiB, RAM). `--mtp off` enables ordinary batching. Embeddings, vision/audio, adapters, and training are unsupported. See [below](#direct-container-artifacts-glm-5x). |
| Tier-0 generic | validated manifest (`tests/support/universal-manifest.ts`): `Llama-3.2-1B-Instruct-4bit`, `Qwen2.5-0.5B-Instruct-4bit`, `Qwen3-0.6B-4bit`, `quantized-gemma-2b-it`, `gemma-2-2b-it-4bit`, `Phi-3.5-mini-instruct-4bit`, `GLM-4-9B-0414-4bit`, `granite-3.3-2b-instruct-4bit`, `starcoder2-3b-4bit`, `SmolLM3-3B-4bit` (all `mlx-community/`) and `ekryski/OLMo-2-0425-1B-Instruct-4bit` | 11 `model_type`s: `llama`, `smollm3`, `qwen2`, `qwen3`, `gemma`, `gemma2`, `phi3`, `olmo2`, `glm4`, `granite`, `starcoder2` (+ mlx-lm remaps `mistral`, `iquestcoder` → `llama`) · `universal-dense` graph · L1 | text | two-model · ngram | bf16 (the validated cell) | `ls` labels these `supported (generic)`. Batch only for plain full-attention archs (gated B=2 on Llama-3.2-3B); gemma2-family / sliding-window archs run serial. No compiled specialization. A `model_type` absent from the table refuses to load. |

Rules that apply across rows (all enforced in `src/server.ts`):

- **Draft sources.** Two-model and ngram work on any autoregressive target
  (two-model requires the same tokenizer family — probe-checked at startup).
  The KV-borrowing drafters (`-assistant`, DSpark, DeepSpec) require a
  Gemma 4 target; `qwen3_5_mtp` heads require a Qwen3.5-family target; GLM's
  MTP is its own row. Any quantized KV scheme excludes the speculative lane
  (requests keep the scheme and decode serially without speculation).
- **Qwen3.5-family checkpoint generations.** Both ship the same graph and both
  load: the mlx-lm-converted naming (`language_model.model.*`,
  `language_model.lm_head`, `vision_tower.*`) and the transformers-5.8 export
  (`model.language_model.*`, top-level `lm_head`, `model.visual.*`, in-repo
  `mtp.*`, HF-layout `conv1d.weight` `[C,1,K]`, RMSNorm gains stored as γ−1).
  The load seam (`src/model/qwen3_5-checkpoint.ts`) replicates mlx-lm's
  `sanitize()` exactly: in-repo `mtp.*` and the vision tensors are dropped from
  the text graph, and the +1.0 γ shift fires **only** when the artifact carries
  `mtp.*` tensors **or** an unsanitized `conv1d.weight` — never on the naming
  alone, so an old artifact can never be shifted.
- **KV schemes.** `--kv-quant 4|8` (uniform, L1) and `config` (per-layer
  `kv_config.json`, L2) apply to the autoregressive families that ship the
  file; `turbo` additionally requires a full-attention `head_dim` in
  {64, 128, 256, 512} (refused at startup otherwise) and is solo-only;
  `--paged-kv` is Gemma 4 only, bf16, serial. Flag detail:
  [server-config.md](server-config.md).
- **Modalities.** Image requests reach a Gemma 4 model only when
  `has_vision_sidecar` or a `*_unified_vision` config is present; audio only
  when `audio_config` AND the sidecar's `audio_tower.*` tensors are both
  present; video only on a Qwen3.5-family model. A request carrying media the
  model cannot take is an explicit 400, never a silent text-only degrade.
  Wire formats: [server-api.md](server-api.md).
- **Memory.** Disk sizes above are the dated figures from
  [benchmarks.md](benchmarks.md); for RAM, ask `mlx-bun fit <query> --ctx
  <n>` rather than a table (src/fit.ts is the calculator).

### How a new model gets here

A `model_type` earns a row by landing a descriptor (Tier-0) or a dedicated
graph (targeted) **plus a green parity manifest entry** against the oracle
that already ships it — the process, cost per arch, and the graduation path
from generic to targeted are in
[docs/design/generic-model-support.md](../design/generic-model-support.md)
(§3.1 descriptor table, §3.5 the parity gate, §3.6 graduation). Exact
artifacts additionally get a declared profile (see
[Declared model profiles](#declared-model-profiles)).

## The cache layout (and why duplicates happen)

Default root: `~/.cache/huggingface/hub` (override with `HF_HUB_CACHE`,
or `HF_HOME` — the root becomes `$HF_HOME/hub`). Per repo:

```
models--<org>--<name>/
  blobs/<digest>                     # verified content, one file per blob
  snapshots/<commit>/<file> → ../../blobs/<digest>   # symlink farm
  refs/<revision>                    # e.g. refs/main = the commit sha
```

**Snapshot-per-commit semantics:** every revision you download gets its
own `snapshots/<commit>` directory, and nothing ever deletes old ones.
When upstream pushes a new commit and you `get` again, you gain a new
snapshot; the previous one — and any blobs only it references, i.e. the
old weights — stays on disk forever. That is why one repo can appear
several times in a raw snapshot listing, and how tens of GB of dead
blobs accumulate. `refs/main` always names the current (canonical)
snapshot; the registry and every query verb resolve through it.

## get — download (resumable, verified)

```
mlx-bun get <org/repo> [--revision main]
mlx-bun get <substring>          # no "/" = registry query, re-gets the match
```

- Plain HTTPS resolve/CDN (no Xet), sequential files, `Range`-resume of
  partial blobs (`<blob>.incomplete`). Auth: `HF_TOKEN` env, then the
  token `hf auth login` writes. 401/403 answers get a "gated repo" hint.
- Before the first payload request, mlx-bun totals the bytes still absent,
  credits complete shared blobs and valid `.incomplete` prefixes, and checks
  the target volume for that remainder plus a fixed 1 GiB safety reserve. An
  impossible acquisition fails immediately with required/available GiB and a
  rerun/resume instruction rather than filling the disk halfway through.
- A substring argument (no `/`) resolves against already-downloaded
  repos — `mlx-bun get 12B` refreshes the 12B to upstream's latest. An
  unknown substring errors with a pointer to `mlx-bun ls <q>`.
- Concurrent-writer safety: an `O_EXCL` lockfile (`<blob>.lock`, pid +
  timestamp) serializes two processes downloading the same blob (e.g. a
  foreground `get` racing the server's background auto-download). Locks
  from dead pids, or older than ~1 h, are stolen; a live lock fails fast
  with "another download … is in progress".
- If the download created a new snapshot (upstream pushed), `get` says
  so and estimates what `mlx-bun gc` would reclaim.

### Verification story

Every blob is checksummed **while streaming** (a resume re-hashes the
existing prefix in chunks — no whole-file allocation):

- **LFS files** (weights): sha256 must equal the API's current `lfs.sha256`
  field (the older `lfs.oid` spelling is also accepted) — which is also the
  blob's filename.
- **Small files** (configs, tokenizer): git blob identity,
  `sha1("blob <size>\0" + content)`, must equal the API's `blobId`.

A mismatch deletes the partial (never resume corrupt bytes); a short
read keeps the `.incomplete` for resume.

## Direct-container artifacts (GLM-5.x)

Models that load through the Colibri container loader (`loader: "colibri"`
in `src/model/profile.ts`) skip `Weights.open` entirely: a header-only
resource equation runs before any resident tensor or expert slab opens, and
an impossible plan fails without committing memory. One validated artifact
today; a GLM-5.3+ artifact joins as a new row in the roster above plus a
subsection here once it has a declared profile.

### GLM-5.2 on a 32 GB Mac

The validated direct-container artifact is
`mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp` at revision
`3cc8db99b1b13fc79325d987ba3c1c430766b3b8`. It is approximately 384 GB
decimal / 357 GiB on disk, so choose the Hugging Face cache volume before the
download. Fast internal NVMe is strongly preferred; an external volume also
needs to sustain the expert-streaming workload after acquisition.

```sh
# Optional: choose a large fast volume before downloading.
export HF_HUB_CACHE=/Volumes/FastSSD/huggingface/hub

mlx-bun get mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp \
  --revision 3cc8db99b1b13fc79325d987ba3c1c430766b3b8
mlx-bun scan
mlx-bun serve GLM-5.2-colibri \
  --memory-budget 26.8435456 \
  --context-length 4096 \
  --max-tokens 128 \
  --mtp on
```

`26.8435456` decimal GB is exactly 25 GiB. The validated plan reserves about
19.9 GiB for the process and leaves the rest of the 32 GiB machine to macOS.
Startup runs the exact header-only resource equation before opening resident
weights or expert slabs. The server reports the resulting plan at
`GET /stats` under `glm52`.

If acquisition is interrupted, rerun the identical `get` command: mlx-bun
rehashes each existing prefix in bounded chunks, sends a Range request for the
remainder, and verifies the complete blob before publishing it. If the disk
preflight refuses, free space or point `HF_HUB_CACHE` at another volume and
rerun. No Python environment and no converted copy inside the mlx-bun checkout
are involved.

The artifact is an external MIT-licensed derivative of
`zai-org/GLM-5.2-FP8`, converted with Colibri and extended with int8 MTP
weights. Model weights are not bundled with mlx-bun; review the artifact model
card before redistribution.

## Declared model profiles

Model loading resolves one immutable profile before weights are opened. A
profile names four things: the external artifact fingerprint when one is
known, its fidelity target, the engine capabilities it requires, and the
composed loader/model-graph/generation-loop path.

Exact artifact profiles outrank family profiles. The current exact declarations
are:

| profile | external artifact | fidelity | execution |
| --- | --- | --- | --- |
| `qwen3.8-27b-optiq-4bit` | `mlx-community/Qwen3.8-27B-OptiQ-4bit` revision `b04599de95d7a9bfbd7f208d347c0f10d9432a42` | L1: bit-exact mlx-lm | safetensors + dedicated Qwen3.5/3.8 graph + autoregressive loop |
| `glm5.2-colibri-int4-int8-mtp` | `mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp` revision `3cc8db99b1b13fc79325d987ba3c1c430766b3b8` | L3: measured, no matching tier oracle | Colibri container + dedicated GLM-5.2 graph + autoregressive loop |

The fingerprint is the Hugging Face repo plus immutable snapshot revision, so
moving the cache does not change it. A mutable alias such as `snapshots/staged`
or an arbitrary local directory is not treated as exact. Those artifacts use
the dedicated model-family profile when one matches, then the universal dense
profile when that architecture is supported. Unsupported architectures still
refuse with the existing targeted/generic support list.

Profiles select construction only. They do not enable, disable, or replace MTP,
mixed-precision KV from `kv_config.json`, TurboQuant KV, adapters, grammar, or
sampling. Those methods remain explicit flags/request fields or documented
defaults. If an exact profile requires a capability the running engine does not
have, loading refuses; it never downgrades to another model path.

Fidelity labels mean L1 = bit-exact mlx-lm, L2 = bit-exact mlx-optiq, and L3 =
measured evidence without a matching oracle. Model profiles do not imply that a
quantized artifact retains the base model's benchmark score; quality evidence
belongs to that exact artifact.

## scan + the registry

`mlx-bun scan` walks `models--*/snapshots/*` reading only `config.json`
+ safetensors **headers** (never tensor bytes) into
`~/.cache/mlx-bun/registry.sqlite`. The registry is a derived cache: on
schema drift it rebuilds; rows whose snapshot dir vanished are reaped.

Schema (table `models`, one row **per snapshot**, keyed on `path`):

| column | meaning |
| --- | --- |
| `path` (PK) | `<hub>/models--…/snapshots/<commit>` |
| `repo_id`, `model_type` | identity |
| `param_count`, `num_layers`, `hidden_size`, `vocab_size` | shape |
| `size_bytes` | language-model weights (sidecar excluded) |
| `sidecar_bytes` | `optiq_vision.safetensors` (bf16 SigLIP sidecar) |
| `experts_bytes` | `.experts.` tensor bytes (MoE fit math) |
| `quant_bits`, `quant_group_size`, `quant_mode` | quantization |
| `has_vision_sidecar` | sidecar file present |
| `vision_config_type` | `config.json`'s `vision_config.model_type` when it names a vision tower (`*_vision`) |
| `has_audio_config` | `config.json` declares an `audio_config` block |
| `has_audio_tower` | sidecar header names `audio_tower.*` tensors |
| `has_kv_config`, `has_tool_template`, `license` | capabilities/terms |
| `scanned_at` | freshness (canonical tie-break) |

**Vision capability** is `has_vision_sidecar OR vision_config_type =
*unified_vision`: the SigLIP models (e2b/e4b/26B/31B,
`gemma4_vision`) need the bf16 sidecar; the unified 12B
(`gemma4_unified_vision`) declares its encoder-free tower in config.
Presence of a `vision_config` key alone is **not** a signal — Qwen3.5
nests a copy of its own text config there.

**Audio capability** is `has_audio_config AND has_audio_tower`: both
legs are required because the 12B OptiQ snapshot carries an
`audio_config` but a stub sidecar whose only audio entry is
`embed_audio.embedding_projection.weight` (no `audio_tower.*` Conformer
tensors) — config presence alone would advertise audio that fails at
request time. The check reads only the sidecar's safetensors header,
never tensor bytes.

## Query resolution rules (per verb)

Every verb resolves fuzzy queries the same way, with revision collapsing
so a stale snapshot never makes a repo "ambiguous":

- **`ls [query]`** — substring match on repo id / model type; shows **one
  row per repo** (the canonical revision). `--all-revisions` shows the
  per-snapshot truth with the canonical marked `*`. Capabilities column
  labels the support tier: `supported (targeted)` (dedicated forward,
  L2/opt-in paths) vs `supported (generic)` (Tier-0 universal module).
- **`fit` / `serve` / `train` / … (single-model verbs)** — `resolve()`:
  the query must match exactly one **repo**; multiple cached revisions of
  that repo collapse to the canonical snapshot (refs/main, else most
  recently scanned). Drafter companions (`*_assistant`) never count.
- **`get <substring>`** — same `resolve()`, then re-downloads that repo id.

Canonical = the snapshot `refs/main` points at; if no `refs/main`, the
most recently scanned snapshot (stable path tie-break).

## gc — reclaim superseded snapshots + dead blobs

```
mlx-bun gc              # plan + per-repo reclaim summary, deletes nothing
mlx-bun gc --yes        # actually delete (destructive)
mlx-bun gc --dry-run    # never delete, even with --yes
mlx-bun gc --yes --force  # also prune warned snapshots (see below)
```

Per repo: keep every snapshot a `refs/*` file points at, delete the
rest, then delete blobs no surviving snapshot symlinks to. Prints
keep/prune/skip counts and reclaimable bytes per repo.

Safety rails:

- **Deletion requires `--yes`.** The default run is a report.
- **File-loss tripwire:** a superseded snapshot containing files the
  kept snapshots *lack* is skipped with a warning naming those files —
  deleting it would delete the machine's only copy (live example: a
  stale gemma-4-12B snapshot holds an `optiq_vision.safetensors` that
  the canonical revision dropped). `--force` overrides, deliberately.
- Repos with no usable refs (no `refs/`, or refs naming a missing
  snapshot) are left untouched.
- `.incomplete` / `.lock` resume artifacts in `blobs/` are never touched.

After a real deletion, gc re-scans so the registry drops the reaped
rows immediately.
