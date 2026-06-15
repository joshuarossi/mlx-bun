# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); this file is the
transient front door that stays current. Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

## Current state (2026-06-14)

- **Active: Phase 18 — concurrent / batched serving (slots)** `[~]`.
  Latest commit landed batched-decode foundations + the mlx-lm B=N parity
  oracle (S1b). Batch parity gate = bit-exact vs mlx-lm B=N at the same
  setting (not vs our own B=1). See PLAN.md Phase 18 + parity oracle
  notes, and `docs/design/parallel-slots.md`.
- **Just completed: docs/repo reorganization** — benchmark provenance
  consolidated into [benchmarks/RESULTS.md](benchmarks/RESULTS.md)
  (3 sections: parity / performance / quality), planning docs moved under
  `docs/planning/`, root decluttered, AGENTS.md de-duplicated. Plan and
  rationale: [docs/design/docs-reorg-plan.md](docs/design/docs-reorg-plan.md).
- **Phase 19 — expert offload (single-user MoE residency): spike complete,
  E1 in progress** `[~]`. Mechanism FULLY de-risked (probes all green: GPU
  `gather_qmm` over a page-aligned mmap is bit-exact + row-local; clean
  read-only file-mmap expert pages cost ~0 `phys_footprint` AND Metal does
  NOT wire them on GPU access → the ~14 GB pool becomes reclaimable cache,
  Apple's outcome without retraining). E0 measured + PASSED (routing
  concentrates ~90% on ~40–47% of experts, tasks specialise). **E1a done**:
  `scripts/convert-offload-experts.ts` produces a page-aligned offload-ready
  expert file, verified byte-identical on the real 26B. **E1b + E1c DONE
  2026-06-14 — IT WORKS ON THE REAL 26B**: env-gated `--expert-offload`
  (`src/expert-offload.ts` + one-line hook in `QuantizedSwitchLinear.load`)
  serves expert weights from a page-aligned file mmap →
  **phys_footprint 17.1 GB → 4.2 GB (−12.9 GB), BIT-EXACT, decode unregressed
  (38.9 → 41.5 tok/s)**. The 26B runs with the memory pressure of a ~4B model.
  **E1d (CLI flag) DONE 2026-06-14**: `mlx-bun serve <model> --expert-offload`
  builds `<model>/.mlx-bun-offload` on first use + activates (bit-exact runtime
  from E1c); split into runtime `src/expert-offload.ts` + build
  `src/expert-offload-build.ts`, wired in `cli.ts` serve. Verified (build /
  help / converter / reuse); `serve --expert-offload` smoke test is Josh's
  (starts a server). **Resume at E1e**: cleared-machine tok/s + optional
  hot-expert pinning + offload scales/biases (last ~6%). Design + all findings:
  PLAN Phase 19 +
  [docs/investigations/expert-offload-single-user-moe.md](docs/investigations/expert-offload-single-user-moe.md).
  Probes/tooling: `scripts/probe-{expert-residency,mmap-gather,madvise-eviction,footprint,metal-wire}.ts`,
  `scripts/run-expert-trace.ts`, `scripts/analyze-expert-trace.ts`, `src/expert-trace.ts`.

## Next action

Finish Phase 18 (the slots executor + batched serving exit criteria),
then the Josh-gated benchmark + roadmap items below.

## Open / Josh-gated

These need Josh physically (hardware, downloads, reboots):

1. **Clean-machine `./benchmark.sh --redo`** after a reboot (+ `sudo purge`
   for purge-cold rows) — quotable rows for the post-decode-fix engine and
   the perf-kernel default decision. Promote results into
   `benchmarks/RESULTS.md`.
2. **M1 Max rerun** — `git pull` then `./benchmark.sh --redo` (its last
   matrix predates the rope-fix).
3. **Phase 14 — Qwen 3.x bring-up** (was targeted ~2026-06-15): pick +
   download the first Qwen quant; also the MTP home and a consumer of the
   default-off fused-decode flag.
4. **Phase 13 — TurboQuant** (promoted research direction).
5. **Phase 12 — SigLIP vision** (on hold; only if needed).
6. **`MLX_BUN_PERF_KERNEL` default flip** — gated on the clean-machine pass.

## Archived handoffs

Older dated handoff blocks (2026-06-10 / 06-11) live in PLAN.md under the
"NEXT UP" / "NEXT SESSION PICKUP" / "SESSION SWEEP" headings, marked as
superseded. They're kept for history; this file is the current state.
