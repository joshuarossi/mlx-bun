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

- **LFS files** (weights): sha256 must equal the API's `lfs.oid` — which
  is also the blob's filename.
- **Small files** (configs, tokenizer): git blob identity,
  `sha1("blob <size>\0" + content)`, must equal the API's `blobId`.

A mismatch deletes the partial (never resume corrupt bytes); a short
read keeps the `.incomplete` for resume.

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
| `has_kv_config`, `has_tool_template`, `license` | capabilities/terms |
| `scanned_at` | freshness (canonical tie-break) |

**Vision capability** is `has_vision_sidecar OR vision_config_type =
*unified_vision`: the SigLIP models (e2b/e4b/26B/31B,
`gemma4_vision`) need the bf16 sidecar; the unified 12B
(`gemma4_unified_vision`) declares its encoder-free tower in config.
Presence of a `vision_config` key alone is **not** a signal — Qwen3.5
nests a copy of its own text config there.

## Query resolution rules (per verb)

Every verb resolves fuzzy queries the same way, with revision collapsing
so a stale snapshot never makes a repo "ambiguous":

- **`ls [query]`** — substring match on repo id / model type; shows **one
  row per repo** (the canonical revision). `--all-revisions` shows the
  per-snapshot truth with the canonical marked `*`. Capabilities column
  labels the support tier: `supported (targeted)` (dedicated forward,
  L2/L3 paths) vs `supported (generic)` (Tier-0 universal module).
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
