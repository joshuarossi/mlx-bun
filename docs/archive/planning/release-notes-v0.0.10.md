# mlx-bun v0.0.10 — batching parity, SSD KV cache, sharper serving

## Highlights

**Concurrent serving now matches the fastest MLX batching servers.** With
`--batch 4`, aggregate throughput at 4 parallel requests is at parity with
(or ahead of) oMLX on every shared model we benchmarked on an M1 Max —
MiniCPM5-1B 349 vs 339 tok/s, gemma-4-e4b within 3%, Qwen3.5-4B within 1% —
with 2–3× better time-to-first-token under load, and per-token SSE
streaming (no burst batching of your tokens).

- **Qwen3.5 joins the batch lane.** Hybrid gated-DeltaNet (SSM) caches grew
  the dynamic-batching ops; the batched decode path is verified
  token-for-token identical against mlx-lm's B=2 batched oracle.
- **Sampler features batch too.** Repetition/presence/frequency penalties,
  `logit_bias`, `min_p`, and XTC now run per-row inside the batch instead
  of forcing requests onto the serial path. (Qwen3.5 ships a default
  repetition penalty — before this fix it silently serialized every
  request under `--batch N`.)

**SSD cold tier for the prompt cache** (`--ssd-cache <dir>`). Long-context
prefix KV now spills to disk on eviction, is snapshotted after requests
settle, and **survives server restarts**: re-attaching a 13.7k-token
coding-agent conversation went from a 12.1 s full re-prefill to a 0.24 s
zero-copy mmap restore in our measurements — with 0% steady-state decode
overhead (nothing runs on the token loop). Entries are keyed by model
fingerprint + KV scheme + tokenizer hash + adapter namespace; corrupt or
incompatible files self-quarantine; the tier is always safe to delete.
Companion flags: `--ssd-cache-max <GB>` (default 32), `--ssd-cache-verify`.

## Fixes

- `serve`/`benchmark` now honor `--model <path-or-query>` as an explicit
  override (it was previously accepted but ignored — auto-pick could
  silently load a different model). A directory containing `config.json`
  loads directly from that path.
- The server stays responsive during long serial generations: `/stats`,
  `/health`, and new connections previously stalled until the generation
  finished (measured 2.5 s on a 512-token run); they now answer in tens of
  milliseconds, with no measurable decode cost.

## Internals

- KV persistence format v2: all cache kinds round-trip (bf16, per-layer
  quantized, sliding-window, quantized sliding-window, SSM), with
  integrity hashes, invalidation metadata, and atomic writes.
- Golden `.bin` parity fixtures are no longer tracked in git (they are
  machine-specific and regenerable); JSON manifests remain.
- New design docs: `docs/design/omlx-adoption-map.md` (feature adoption
  scoreboard), `docs/design/batching-perf-path.md`,
  `docs/design/ssd-kv-cold-tier.md`.

Full details and measured numbers: STATUS.md and the design docs above.
Credit where due: the SSD-tier and batching comparisons were driven by
studying [oMLX](https://github.com/jundot/omlx) (Apache 2.0) — a strong
project whose ideas we benchmarked and adapted where they made mlx-bun
faster.
