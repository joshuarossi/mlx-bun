# STATUS — live handoff

The one "what's the state, what's next" doc (≤150 lines, gate-enforced).
Open work with exit criteria: [PLAN.md](PLAN.md). Rules: [CONTRIBUTING.md](CONTRIBUTING.md).
Docs map: [docs/README.md](docs/README.md). Superseded entries are deleted,
not relocated — history is `git log -- STATUS.md`.

**Fidelity contract:** L1 = mlx-lm bit-exact numerics (the naked default;
behavior-policy defaults are ours — server-config.md "Reproducing
mlx_lm.server" lists the compat flags) · L2 =
mlx-optiq bit-exact (mixed-KV) · Lab = no external oracle, gated by KL/eval
and a paired A/B win before any default
([unified-engine-frontier-plan](docs/design/unified-engine-frontier-plan.md)).

## Released: mlx-bun v0.2.0 (2026-08-24)

Complete Qwen3.8 serving path (text, images, video, thinking controls, tool
calls, native MTP), the serving-architecture consolidation (one
`CompletionExecutor`, immutable placement, declared model profiles), the Qwen
wired-memory fix, SSD-cache durability, rotation-folded quantization
(`convert --rotate-weights`), and the admission clamp on every model.
Published on GitHub, npm, and the Homebrew tap; signed/notarized arm64
archive SHA-256 `4a204fd53d32be1c1edec22737397adf1f7abec295a7db06d217e405c44d086b`.
The first notarization was rejected (ad-hoc-signed `mlx-bun-frame-extract`
helper); `scripts/release-binary.sh` now signs helper executables and fails
on any non-Accepted status. Requires Bun ≥ 1.4.0; npm/bunx use native pack
v0.3.0. Notes: docs/archive/planning/release-notes-v0.2.0.md.

## Performance position (measured 2026-08-23/24, M1 Max 32 GB, loaded box)

Same kernels as mlx-lm (chunk-level prompt-forward within 1–2% on every
model); mlx-bun wins on fixed per-request overhead (~150–165 ms less) and
token-0 (~2× faster), so short-context TTFT is 20–44% better and long
context converges to a tie; decode +6% (27B) to +33% (1B). Bit parity holds
on every arm. Quiet-machine numbers are still owed before these enter
[benchmarks.md](docs/reference/benchmarks.md) as canonical rows. Detail:
[decode-speed-program](docs/design/decode-speed-program.md).

## Threads (one row each; the PLAN.md heading is the source of truth)

| thread | state | next action | branch |
|---|---|---|---|
| Qwen3.8-27B inference performance | Trellis and joint TurboQuant K/V optimizations have native and serving diagnostic wins; defaults remain gated. The working tree uses the verified MLX 0.32.2 native-pack candidate and matching reference; it is not published. Active models now use byte-verified internal SSD copies. Persistent state is keyed by runtime/GPU numerical identity, with exact RTN4 restart/isolation checks. Same-version RTN4 logits/state pass, including actual 4K/8K prompt checks. The new Trellis small-prefill path passes full-model identity and six actual HTTP pairs per lane. Runtime-only decode timing is flat. The per-layer compiled graph and constant-table decode screens retain no speed candidate. Both R6/RTN4 inverse-KV model and integrated HTTP gates pass; every decode pair improves, with complete-time benefit established only on R6. MiniCPM and Gemma deferred-KV serving passes all twelve pairs with complete-request gains. The consolidated model-free suite, typechecks and hygiene pass; final-source Qwen identity passes all 52 forward/state cases and six Trellis generations. | The fresh Pi Luke Kanban task now completes and the untouched app passes functional browser checks on the required 12 GB artifact. The published profile, prompt and source stay fixed. The isolated candidate combines target KV4, MTP and paired RAM prefixes; ownership fixes and a bounded range cache pass exact sustained native replay. The completed task includes Pi context compaction; derived reports correct the older helper's event-name mismatch while preserving raw evidence. The KV4/MTP/paired-prefix integration and its regression tests are now included in the PR #47 feature branch, with production source matching the tested candidate. The benchmark accepts explicit serial draft/KV/cache arguments without a local preload. A matched successful original/final task-time comparison and the composed path's remaining gates are still open. Complete native and serving acceptance at the final source revision. Resolve parser-proven structural appends and early-first-token cache-boundary shape differences. Complete broader/combined pressure and quiet acceptance for retained Trellis, KV, MTP and scheduling candidates. Continue the project kernel ledger, model-owned Llama submission tuning and fixed-kernel refactor controls. Finish with the held-out Luke kanban task and a Bun benchmark with portable HTML reporting. Remaining acceptance is on the M4 Pro only. Details and individual pending gates are in PLAN.md and decode-speed-program §7. | feature/perf/qwen-27b-inference |
| Repo taming (docs/files/agent instructions/seams) | Docs map, repository gates, request pipeline and shared prefill extraction landed; the engine refactor is merged. | D6 retention decisions still need workload measurements. True B-wide prefill remains Phase 18 S1a. | main |
| TurboQuant weights — Q campaign (sub-4 bpw) | **Q3 PASSED** (KL 0.1553 @ 3.55 bpw; flagship 0.1646 @ 4.80; MMLU 88 / tGSM 48 / rawGSM 44). **Q2b packed format LANDED 2026-09-02**: 12.14 GiB artifact, decode bit-identical to the fake-quant, KL 0.1550 through our engine, coherent generation; M1 Max decode **9.3 tok/s vs 18.9** flagship after three kernel rounds. **down_proj axis settled — KEEP THE ROTATED AXIS**: `--down-axis in` is 11.3 vs 9.3 tok/s at identical KL/MMLU/tGSM but rawGSM **29/50 vs 44/50**, strictly nested (15 regressions, 0 gains), failure = immediate EOS — incoherence processing must reach the CODED axis (third instance of "KL is the screen, not the verdict"). Carry-forward: `…-k300-packed` (12.14 GiB, 9.3 tok/s) | Q5 2.75-budget arm; q2a/q2b task columns; rawGSM EOS-cliff root cause (now with two arms exhibiting it) | chore/tame-jungle |
| Resumable long-agent generation | The merged path passes seven saved boundaries in both serial and continuous serving, with identical responses and durable final SSD flushes. The longest prompt has 14,465 tokens and generates 512. Earlier Pi stopped on an unparsed tool call and did not complete its app task. | Repeat pressure/reliability coverage as graph barriers or kernels change; investigate the separate affine transient-allocation control. Evidence: turn-8 repro and decode-speed-program §7. | main |
| K3 token fast-forwarding (fill) | Parser guards and model-owned appends are integrated. Both Qwen quants preserve logits, state and continuation at MLX attention boundaries. Model-free/typecheck, cancellation and final internal-SSD serving gates pass. All twelve paired comparisons retain request-time gains with 96 exact responses and no failures. | Extend held-out/combined/pressure coverage. Quantized-KV and speculative combinations stay gated pending validation. See speculative-decoding §7.4. | main |
| Serving architecture consolidation | S0–S3 merged in v0.2.0 | S4: real-conversation smoke on merged main, then close the PLAN block | main |
| Interface-based engine refactor | R1–R9 and R10 code migration merged in `673b43f`, PR #46. Model-owned execution, shared prefill/sessions, policy capture and state ownership landed. Current checkpoint: typechecks and model-free suite pass. The earlier M4 delta-golden discrepancy was reproduced in the pinned oracle and explicitly regenerated on unchanged inputs. | Share target and quiet M4 Pro acceptance with Phase 6 R0. Upstream loaded-machine repeats establish no 27B speed win. See engine architecture §12.13 and decode-speed-program §7.1. | main |
| Memory / the Dreaming | write path + nightly synthesis built; ingest is NOT wired into the nightly run; `memory synthesize --since/--model` parsed but unapplied | wire ingest into `runPipeline`; decide the embeddings-as-instruments question; promote wiki-full to a real vault | main |
| Audio input (Gemma-4) | A0–A4 served | A5 bench cells + 12B sidecar coverage | main |

## Standing hazards (verified today)

- The completed M4 Pro default suite has MiniCPM/Qwen output mismatches,
  and Qwen 4/8-bit prefill memory failures. The SSD flush ordering fix passes
  all four affected serving repeats, and the packed Trellis/KV4/MTP suite
  passes every phase. Other acceptance remains open; see benchmarks.md and
  Phase 6 in PLAN.md.
- The kv-quant RSS check in `bench-serve` misfires on large models with
  `--ssd-cache` (RSS accounting, not silent bf16) — confirm quantization via
  decode@ctx and restart-restore size instead.
- `WIRE_THRESHOLD` (generate.ts) is a host-relative fraction; the 12B sits
  near the boundary on a 24 GB machine.
- Two dev machines (M1 Max 32 GB, M4 Pro 24 GB); neither is canonical — every
  number carries host/chip/RAM ([environment.md](docs/reference/environment.md)).
