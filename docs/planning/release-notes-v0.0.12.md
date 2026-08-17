# v0.0.12 release notes

mlx-bun 0.0.12 completes the native Colibri/GLM-5.2 program: a Python-free,
direct-container runtime that can serve the approximately 357 GiB artifact on
a 32 GiB Apple Silicon Mac by keeping a bounded working set in memory and
streaming routed experts from fast storage.

## GLM-5.2 direct-container serving

- Loads `mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp` directly. No converted
  copy and no Python process are involved in the serving path.
- Preserves checkpoint precision and true top-8 routing. The port is gated
  against pinned Colibri at tiny, production-component, real-model, MTP, cache,
  and first-sparse DSA boundaries.
- Native int8 MTP is enabled by default and uses the serial speculative lane.
  It produced a measured 1.306x warm end-to-end win over MTP-off on the 32 GiB
  reference machine while preserving all target tokens.
- Compressed MLA/DSA/MTP cache persistence, restart restore, compressed-byte
  admission, ordinary continuous batching, mixed-length join/leave/cancel, and
  cross-row expert union are included. Per-row batched MTP remains a later
  feature; MTP requests truthfully report `serial+spec`.
- Chat completions, text completions, Anthropic Messages, OpenAI Responses,
  SSE, tools, structured output, stops, sampling, usage, and serial logprobs
  are supported. Embeddings, vision/audio, LoRA, and training are explicitly
  reported unsupported for this model instead of being emulated.

## Memory and acquisition contract

- `mlx-bun get` now computes the exact remaining payload before the first
  payload request, credits verified shared blobs and resumable prefixes, and
  refuses an acquisition that cannot leave a fixed 1 GiB safety reserve.
- The GLM header-only preflight runs before resident weights or expert slabs
  open. With the stock DSA overlay installed, 4,096 context / 128 generation
  tokens and MTP on produce a 19.89 GiB plan under a 25 GiB process ceiling,
  leaving 5.11 GiB of process/macOS headroom on a 32 GiB machine.
- `fit`, `/fit`, `/stats`, and the status page now distinguish the complete
  artifact on disk from resident weights, main/MTP slabs, compressed KV, and
  reserves. They also expose main/MTP residency, hit rate, SSD bytes, policy
  telemetry, and repin events.

## Performance: measured, not predicted

- Warm quality-preserving throughput on the M1 Max 32 GiB reference machine is
  0.1577 decode tok/s / 0.1487 end-to-end tok/s with MTP on. The same-machine
  direct-Colibri control is approximately 0.27 tok/s.
- The 2 tok/s figure remains an aspiration, not a release gate or `fit`
  prediction. The measured warm end-to-end result is 13.45x below it.
- Replicated telemetry measured 1,974,949,363,712 logical expert bytes per
  128-token warm turn (15.429 decimal GB/token) and a 1.66% cache hit rate.
  Startup auto-pin, live LFRU, PILOT hints, two-step prediction, and coupling
  did not improve paired end-to-end performance and remain off by default.
- The checkpoint's 21-full/57-shared DSA schedule is implemented and exact.
  Paired 2K/8K tests did not establish an MTP-on product-speed win, so this
  release makes no DSA speed claim. The public Colibri artifact does not ship
  the stock DSA indexer overlay; without it the runtime follows the artifact's
  available attention path.

## Distribution and operator experience

- First-run native pack v0.2.0 adds the bounded native expert-I/O helper. The
  npm/bunx fresh-cache path downloads, verifies, and extracts all five runtime
  files; the signed/Homebrew bundle includes the same helper beside the binary.
- The pinned 32 GiB quickstart, volume selection, interrupted-download recovery,
  model lineage, licenses, resource plan, measured performance, and limitations
  are documented in README and the reference guides.
- The interactive Atlas report reproduces Colibri's expert topic-affinity
  result: 29/30 leave-one-prompt-out classifications (96.7%) and 1,065 strong
  specialists among 13,236 replicated experts.

## Stability fixes since v0.0.11

- Closed pre-Colibri correctness and lifecycle findings, including expert-slab
  post-close and lazy-graph reuse hazards, with forced native/MLX churn gates.
- Fixed selected-logprob readback stalling and revalidated the audio splice
  boundary against the oracle.
- Corrected current Hugging Face LFS checksum-field handling and retained the
  older spelling for compatibility.

Full provenance and exact numbers are in `benchmarks/RESULTS.md`, `STATUS.md`,
and `docs/design/colibri-glm52-port.md`.
