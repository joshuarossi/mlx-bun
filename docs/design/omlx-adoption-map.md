# oMLX adoption map — every feature, where it slots, status

Status: LIVING (started 2026-07-02). oMLX (github.com/jundot/omlx, Apache
2.0) is the systematic port source: read its actual implementation before
building (full source ships locally in
`/Applications/oMLX.app/Contents/Resources/omlx/`), port the IDEA into our
architecture, and keep it only if OUR benchmarks improve (the burst-decode
refutation below is the cautionary tale). Attribution: note derived code in
THIRD_PARTY_LICENSES.md; idea ports get a source comment.

## Where oMLX sits in the fidelity-tier model

It doesn't slot at L1 or L2 — it decomposes. The tiers are NUMERICS
contracts (parity-tier-dag.md); oMLX is a Python appliance ON mlx-lm:

- Its stock forwards are mlx-lm's numerics = our existing **L1 oracle**
  (no new oracle value; mlx-lm itself stays the reference).
- Its own numeric inventions (oQ, custom kernels, DFlash, MTP) are
  oracle-less = **L3-class** here, and get our L3 gating (KL/eval/envelope
  + kill switch) that they don't have upstream.
- Its product surface (SSD cache, EnginePool, menu bar, MCP, grammar) is
  **tier-agnostic serving layer** — keyed by the effective tier/scheme,
  never part of the decode-numerics DAG.

## Scoreboard

### Ported, kept (benchmarked wins)
| Feature | Theirs | Ours | Result |
| --- | --- | --- | --- |
| Continuous batching parity | scheduler on mlx-lm BatchGenerator | `--batch N` lane + P5 SSM port + per-row logits processors (2026-07-02) | cpm5 345 vs 339 (win), e4b −3%, Qwen3.5 −1%, TTFT 2–3× better (batching-perf-path.md) |
| SSD KV cold tier | `cache/paged_ssd_cache.py` (content-hashed blocks) | `src/ssd-cache.ts` + kv-store v2 (whole-entry spill, zero-copy mmap) | restart TTFT 12.1s→0.24s vs their 1–3s; 0% decode overhead vs their ~20% (ssd-kv-cold-tier.md) |

### Ported, refuted (do not re-add without new evidence)
| Feature | Why it doesn't transfer |
| --- | --- |
| Adaptive burst decode (`engine_core.py _step_burst`) | Amortizes Python GIL/asyncio ping-pong (~1ms/token). Bun has no GIL; faithful port REGRESSED cpm5 B=4 345→289 + TTFT +100ms. Reverted with breadcrumb (batching-perf-path.md P4). |

### Queue (roughly by leverage; ★ = Josh explicitly wants)
1. **Structured output / JSON-schema constrained decoding** (`api/grammar.py`)
   — serving layer. The biggest API-surface hole vs both oMLX and agent
   frameworks. We own the sampler loop; a token-mask grammar engine slots
   beside the existing sampler extensions. Serial lane first, batch lane
   via the per-row processor fold (already built).
2. **★ Menu bar app** (`apps/omlx-mac/`, native SwiftUI + Sparkle) — product
   layer. Their repo is the structural reference; our signed/notarized
   single binary is the sidecar. Supersedes tauri-desktop-app.md's Electron
   ambivalence: native SwiftUI is the received-well shape.
3. **Multi-model serving / EnginePool** (`engine_pool.py`: LRU + pinning +
   load/unload API) — serving layer. Fits our single-USER framing as model
   SWITCHING (one active, LRU-evict the rest), not concurrent tenants.
4. **oQ-style sensitivity-driven quantization** (`oq.py`,
   docs/oQ_Quantization.md) — L3-class, lands in `convert` beside
   `--target-bpw`: calibration-measured per-layer sensitivity, boosts on
   non-expert tensors only, batched expert GPTQ. Gate: perplexity + 6-task
   eval vs our knapsack at equal bpw. (arXiv-lens candidate.)
5. **DFlash serving wiring** (`engine/dflash.py` + their published -DFlash
   drafts) — L3-class; unblocks DSpark (docs/design/dspark-speculative-decoding.md).
   Their integration pattern: separate engine class, ctx-length fallback
   routing, tape-replay cache rollback.
6. **Vision feature cache** (`cache/vision_feature_cache.py`) — serving
   layer; encoder features for repeated-image agent turns. Natural sibling
   of the SSD tier (same keying discipline).
7. **MCP tool execution in serve** (`--mcp-config`, `mcp_routes.py`) —
   serving layer. Note overlap: Pi already owns tool orchestration for our
   UIs — scope this to bare-API consumers; don't duplicate Pi.
8. **Prefill progress observability** (`prefill_progress.py`) — /stats +
   web UI surfacing for long prompts. Pairs with the serial-lane hop fix.
9. **Rerank endpoint** (`/v1/rerank`) — needs a reranker model family
   first; park until a Qwen3-Reranker-class port is wanted.
10. **Document ingestion (MarkItDown)** — product layer; ours would go
    through the chat UI / Pi attachments, not the server.
11. **Admin one-click benchmark with prefix-cache-hit testing** — fold into
    bench-serving-load.ts as a `--cache-hit-ratio` mode instead of a UI.

### Explicitly not porting
- **Audio (STT/TTS/STS)** — audio tower deferred (project scope).
- **Their SSE burst streaming** — side effect of the GIL workaround;
  per-token streaming is strictly better UX at zero cost for us.
- **Python-side scheduler details** (GIL executors, collector reaping) —
  runtime-specific.

## Porting discipline (learned this week)
1. Read their real source first (local app bundle) — the README lies less
   than the code.
2. Port the idea into OUR architecture; never transliterate Python.
3. Benchmark before/after on THIS machine; keep only wins (burst decode
   died here). Wall-clock metrics only — their own logs over-report.
4. Numeric features get L3 gates + kill switches; serving features get
   the effective-scheme keying; nothing touches L1/L2 contracts.
5. Verify the served model id (/v1/models) before trusting any bench.
