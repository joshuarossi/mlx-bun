# Model management: get / scan / ls / gc

How mlx-bun downloads, indexes, lists, and reclaims models. The store is
the standard Hugging Face hub cache — nothing proprietary; `hf` and
mlx-lm read/write the same tree.

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

## GLM-5.2 on a 32 GB Mac

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
