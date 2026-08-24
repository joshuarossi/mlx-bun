# STATUS — live handoff

The one "what's the state, what's next" doc (≤150 lines, gate-enforced).
Open work with exit criteria: [PLAN.md](PLAN.md). Rules: [CONTRIBUTING.md](CONTRIBUTING.md).
Docs map: [docs/README.md](docs/README.md). Superseded entries are deleted,
not relocated — history is `git log -- STATUS.md`.

**Fidelity contract:** L1 = mlx-lm bit-exact (the naked default) · L2 =
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
| Repo taming (docs/files/agent instructions/seams) | Phases 0–3 landed on this branch: −50k lines, one canonical doc per topic, generated doc map, gates for every rule (`bun scripts/check-hygiene.ts`, `tests/docs-surface.test.ts`) | Phase 4: unify the two prefill loops, extract `handleChat`/model-host from server.ts, tests into `tests/{unit,serve,using,parity,research}` with CI by directory, `src/lab/` quarantine + import lint; darlings are quarantined, not killed (D6) | chore/tame-jungle |
| TurboQuant weights | W1–W4 done; W5 GPTQ-on-rotated, W6 release, W6.5 dogfood gate, W7 frontier open | Josh's go on the W6 single-repo release; frozen 6-task eval cells; quiet-box tps | feature/turboquant-weights |
| Serving architecture consolidation | S0–S3 merged in v0.2.0 | S4: real-conversation smoke on merged main, then close the PLAN block | main |
| Memory / the Dreaming | write path + nightly synthesis built; ingest is NOT wired into the nightly run; `memory synthesize --since/--model` parsed but unapplied | wire ingest into `runPipeline`; decide the embeddings-as-instruments question; promote wiki-full to a real vault | main |
| Audio input (Gemma-4) | A0–A4 served | A5 bench cells + 12B sidecar coverage | main |

## Standing hazards (verified today)

- The kv-quant RSS check in `bench-serve` misfires on large models with
  `--ssd-cache` (RSS accounting, not silent bf16) — confirm quantization via
  decode@ctx and restart-restore size instead.
- `WIRE_THRESHOLD` (generate.ts) is a host-relative fraction; the 12B sits
  near the boundary on a 24 GB machine.
- Two dev machines (M1 Max 32 GB, M4 Pro 24 GB); neither is canonical — every
  number carries host/chip/RAM ([environment.md](docs/reference/environment.md)).
