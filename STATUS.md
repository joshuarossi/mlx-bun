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

## Released: mlx-bun v0.3.0 (2026-09-08)

PR #47 is merged. The release includes Qwen Trellis and TurboQuant kernel
work, opt-in KV4/MTP with paired RAM prefixes, sustained-generation ownership
fixes, structural token appends, SSD flush ordering and benchmark controls.
Published from the M1 Max through the standard release scripts to GitHub,
npm and the Homebrew tap. Apple notarization **Accepted**, submission
`2c199d44-1125-40f8-8d37-3ca8122349bd`. Signed arm64 archive SHA-256:
`46f5698267d8de8b5763b1b224271bcaba73bb79a09fea185c36524055c60921`.
Requires Bun ≥ 1.4.0 for npm; native pack v0.4.0 bundles MLX 0.32.2.
Downloaded bundle checksum/signature and CLI smokes pass on the M1 Max.
The published native pack installs and loads; npm's launcher reports v0.3.0.
Notes: [release-notes-v0.3.0.md](docs/archive/planning/release-notes-v0.3.0.md).
Measured results and limits: [benchmarks.md](docs/reference/benchmarks.md).
There is no matched successful original/final Kanban task-time comparison.

## Threads (one row each; the PLAN.md heading is the source of truth)

| thread | state | next action | branch |
|---|---|---|---|
| Qwen3.8-27B inference performance | PR #47 merged and released in v0.3.0. Packed Trellis/KV4/MTP with paired target/draft RAM prefixes completes the fresh Luke Kanban task on the required 12 GB artifact; the untouched app passes functional checks. The configured serving suite and all four SSD durability repeats pass. Native pack 0.4.0 bundles MLX 0.32.2 with matching references; runtime/GPU identity isolates persistent state. | Complete a matched successful original/final task-time comparison and the composed path's remaining acceptance gates. Resolve standard-suite reference differences and Qwen 4/8-bit prefill failures. Continue combined/pressure acceptance for retained kernel, KV, MTP and scheduling changes, structural-append combinations, the project kernel ledger and fixed-kernel refactor controls. Finish the Bun benchmark with portable HTML reporting. Acceptance remains on the M4 Pro. PLAN.md and decode-speed-program §7 own the individual gates. | main |
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
