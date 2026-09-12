# Project status

mlx-bun provides local MLX inference for Apple Silicon applications, a
TypeScript/Bun library, and a signed server executable. This page tracks
released work and remaining engineering tasks. Start with
[CONTRIBUTING.md](CONTRIBUTING.md) to participate; [PLAN.md](PLAN.md) defines
open milestones and [the docs index](docs/README.md) maps the references.

Numerical contracts and measured results live in
[benchmarks.md](docs/reference/benchmarks.md). Supported artifact and cache
combinations live in [models.md](docs/reference/models.md) and
[server-config.md](docs/reference/server-config.md).

## Released: mlx-bun v0.4.0 (2026-09-11)

PR #48 is merged and published through `scripts/publish-release.sh` to GitHub,
npm and the Homebrew tap. The release includes shared batched methods and
sampling, affine/TurboQuant row state, generated RAM/SSD reuse, queued
persistence, ordinary/adapter resume and GLM native MTP state. Default serving
remains cap eight with B1 execution for a lone eligible request; explicit serial
remains available. Final GLM artifact testing and remaining program work stay open.

Built from `a54f819` with Bun 1.4.2 and native pack 0.4.0 / MLX 0.32.2.
Apple notarization **Accepted**, submission
`92840689-ebc3-4ba8-bfa6-8d5923aabe39`. Signed arm64 archive SHA-256:
`dd362be989c96964cbfe1c149c47a330c814ddf4d8412b21b8d75747aae21ede`.
The downloaded release matches the GitHub asset and Homebrew formula hashes;
npm reports 0.4.0. Notes: [release-notes-v0.4.0.md](docs/archive/planning/release-notes-v0.4.0.md).
Measured results and limits: [benchmarks.md](docs/reference/benchmarks.md).
There is no matched successful original/final Kanban task-time comparison.

The post-release M4 standard matrix and packed-Qwen KV4/TQ follow-up are
complete. Both quantized packed-model profiles pass context and SSD restart;
the older registry Qwen retains its capacity failures. Explicit serial TQ
runs ordinary decode despite requested MTP; shared TQ uses MTP. Configuration,
response comparisons and timings are recorded in benchmarks.md.
The subsequent h2h omits forced serial entirely for the three stock-reference
models. Request telemetry confirms default batched execution, including lone
requests. The packed Qwen measurements remain separate because stock reference
servers cannot load that artifact.

The failed `6e918e2` Kanban task exposed BPE resegmentation of generated text
and RAM snapshot pressure. The follow-up preserves original generated IDs
through RAM/SSD history and reclaims optional snapshots through the cache port.
The saved failure sequence is reproduced on main and passes with the fix,
including identical CSS output and usage. M1 native RAM/SSD HTTP checks,
the complete local suite, typechecks and docs checks pass. The first tool turn
now reuses its generated history. [PR #50](https://github.com/joshuarossi/mlx-bun/pull/50)
merged as `8c5ddbc` on September 12 UTC. The fresh M4 task on `a40588e` has an identical
initial request and no inference failures; every follow-up hits the cache.
Its untouched app fails two browser acceptance categories, and pressure
evicts older unwritten snapshots despite successful latest-state persistence.
App quality and older-history retention remain open. Reports and app:
`reports/kanban-cache-fixed-fresh/`; the failed run and snapshots are preserved.
Evidence and measured limits: [benchmarks.md](docs/reference/benchmarks.md#saved-kanban-cache-failure-replay--m4-pro-24-gb-2026-09-12-utc).
The seeded M4 repeat completes in 78m31s with 72,289 tokens and 26/26 follow-up
cache hits. Its first response matches exactly; directory timestamps change
the next input. Browser acceptance remains 16/18 with the same two defects.
Evidence: `reports/kanban-cache-fixed-repeat-r1/`; previous runs are preserved.

Cache persistence correction is merged through PR #51.
One cache owns RAM residency and SSD persistence. A CPU worker writes immutable
state without the generation lock; eviction retains unwritten victims until
SSD completion. All 2,249 model-free tests pass, with 14 fixture skips; focused tests pass
after the final residency callback change. Native codec bytes match the existing
writer; compiled-worker and M4 shared-MTP RAM/SSD checks pass. A paired M4
storage diagnostic keeps decode effectively unchanged while persisting during
generation. The subsequent full Kanban retention comparison is complete; see the session-cache result below. [Design and serving-cache comparison](docs/design/kv-cache.md#54-background-persistence-and-ram-residency).

Cache expansion C1–C5 is implemented and measured: shared SSD blocks,
asynchronous restore, interchangeable RAM retention and bounded packing,
plus direct paged attention for bf16/affine shared rows. The M4 standard
matrix preserves all responses. Space/copy and overlap benefits are recorded
alongside slower block writes, policy losses and paged bf16 regressions;
optional arms are not promoted by those results. Whole-file storage and LRU
remain selected; async restore moves reads off the owner thread. The complete
model-free suite, typechecks and native RAM/SSD, MTP/TurboQuant and paged HTTP
checks pass. This closes the bounded cache expansion, not the remaining
Phase 6/18 work. Full Kanban retention results follow below. [Measurements](docs/reference/benchmarks.md#cache-expansion-c1c5-storage-restore-retention-and-paged-attention).

Session-aware cache selection (C6) is implemented and measured. Pi/HTTP session
metadata selects an immutable checkpoint through the cache's own index and
supplies soft RAM affinity. Native tests cover ordinary, MTP/TurboQuant and
paged RAM/SSD reuse. Fixed-input M4 serving preserves outputs and is effectively
flat; lookup work and restores decrease in their targeted comparisons.
The full M4 Kanban run on `3ea8079` is complete with unchanged source and
inference settings. All follow-ups use the session cache, and final SSD flush
is durable with no missing snapshots. The untouched app has the same two
browser defects as before; task time and output length increase. Reports:
`reports/kanban-session-cache-r2/`; r1 preserves a runner directory mismatch.
[Full comparison](docs/reference/benchmarks.md#full-kanban-with-session-cache-and-queued-persistence).


Prefill observation and mixed token work are complete on
`perf/prefill-observation` for Gemma/Qwen and grouped speculative methods.
The scheduler owns token budgets; methods own candidate demand and hidden taps;
models retain attention/recurrent state per group. Same-geometry oracles,
affine/TQ MTP and lookup lifecycle/generated-cache checks pass. M4 comparisons
keep mixed work off by default: Gemma buys lower first-output latency with a
throughput cost; Qwen MTP reduces its worst pause but loses first-output latency
and throughput. R17 generated RAM/SSD cache acceptance is also complete, based
on the already-finished Kanban retention/durability run. Remaining Phase 6/18
work is the specific feature/configuration and performance work listed in PLAN.


Shared grammar proposals are implemented and measured. The request's grammar supplies
candidates to the existing verifier; sampling, cache state and scheduling retain
their interfaces. MiniCPM and packed-Qwen/TurboQuant native checks pass, including
independent cancellation and logprobs. HTTP results are mixed across machines/models;
the option remains off by default. Next: remove avoidable transaction work on
verification steps with no candidates, then measure the effect.

## Threads (one row each; the PLAN.md heading is the source of truth)

| thread | state | next action | branch |
|---|---|---|---|
| Public readiness | PR #49 presentation revisions are ready: benchmarks lead with parity and the latest h2h, public entry points use project language, and the GPTQ defects reproduce on CPU against pinned upstream source. Both GPTQ indexing defects are reported in [mlx-lm #1878](https://github.com/ml-explore/mlx-lm/issues/1878); the fix and regression test are open as [mlx-lm PR #1880](https://github.com/ml-explore/mlx-lm/pull/1880). The pinned oracle setup and clean-start MiniCPM comparison pass on M1 Max with 100 exact vectors and tokens. | Work [the handoff](docs/planning/public-readiness-handoff.md) for remaining upstream follow-up, roster evidence, package map, candidate verification and outreach drafts. [Acceptance](docs/planning/public-readiness.md). | chore/public-readiness |
| Qwen3.8-27B inference performance | Phase 6/18 remain open; the accepted PR #48 work is released as v0.4.0. | **Current milestone:** keep shared batching as the default with effectively equal measured B1 performance. Serving already defaults to cap eight and uses B1 for a lone eligible request. Explicit `--batch 1` retains serial; removal and complete feature parity are deferred follow-ups, not blockers for this default. **Integrated:** shared ordinary and speculative methods, sampling/lifecycle ports, generated RAM snapshots and queued SSD persistence, affine/TurboQuant row layouts including delayed precision, paged storage, adapters with lookup, and independent greedy verification sampling. Main suites, typechecks and full hygiene pass. **Current:** shared ordinary interrupted-generation resume is integrated, including queued persistence and affine/TurboQuant layouts. Both-machine native/HTTP compiled, uncompiled, delayed-precision and mixed-grammar controls, complete suites/SSD/types and the matched M4 timing comparisons are complete. The source-only timing comparison preserves every response/usage record with effectively flat performance. The packed-model HTTP fixture now gives each fresh model its own weight handles. Adapter resume and tiny/oracle-tested GLM shared MTP are also integrated from the remaining campaign checkouts. [PR #48](https://github.com/joshuarossi/mlx-bun/pull/48) contains the accumulated implementation, tests and evidence. All 80 secondary Git worktrees and 99 campaign source copies are archived and removed; both primary checkouts remain. Local typechecks, hygiene and focused integration checks pass; The implementation CI passed and v0.4.0 is published; remaining work follows the revised milestone. Explicit serial remains supported. **Remaining:** close specific unsupported media/fill/grammar-jump and adapter-resume combinations, resolve recorded B1/prefill/cache regressions, consolidate defaults/configuration, complete remaining kernel and long-task work. Serial removal is deferred. Existing provider/KV/paging correctness evidence remains accepted; umbrella L2/Lab entries need reconciliation with that evidence. Final GLM artifact testing remains deferred. No DSpark/DFlash checkpoint has been trained yet; only seeded execution fixtures exist. Feature evidence: PLAN Phase 6/18 and batching.md; performance: benchmarks.md. | feature/perf/qwen-27b-closeout |
| Repo taming (docs/files/agent instructions/seams) | Docs map, repository gates, request pipeline and shared prefill extraction landed; the engine refactor is merged. | D6 retention decisions still need workload measurements. True B-wide prefill remains Phase 18 S1a. | main |
| TurboQuant weights — Q campaign (sub-4 bpw) | **Q3 PASSED** (KL 0.1553 @ 3.55 bpw; flagship 0.1646 @ 4.80; MMLU 88 / tGSM 48 / rawGSM 44). **Q2b packed format LANDED 2026-09-02**: 12.14 GiB artifact, decode bit-identical to the fake-quant, KL 0.1550 through our engine, coherent generation; M1 Max decode **9.3 tok/s vs 18.9** flagship after three kernel rounds. **down_proj axis settled — KEEP THE ROTATED AXIS**: `--down-axis in` is 11.3 vs 9.3 tok/s at identical KL/MMLU/tGSM but rawGSM **29/50 vs 44/50**, strictly nested (15 regressions, 0 gains), failure = immediate EOS — incoherence processing must reach the CODED axis (third instance of "KL is the screen, not the verdict"). Carry-forward: `…-k300-packed` (12.14 GiB, 9.3 tok/s) | Q5 2.75-budget arm; q2a/q2b task columns; rawGSM EOS-cliff root cause (now with two arms exhibiting it) | chore/tame-jungle |
| Resumable long-agent generation | The merged path passes seven saved boundaries in both serial and continuous serving, with identical responses and durable final SSD flushes. The longest prompt has 14,465 tokens and generates 512. Earlier Pi stopped on an unparsed tool call and did not complete its app task. | Repeat pressure/reliability coverage as graph barriers or kernels change; investigate the separate affine transient-allocation control. Evidence: turn-8 repro and decode-speed-program §7. | main |
| K3 token fast-forwarding (fill) | Parser guards and model-owned appends are integrated. Both Qwen quants preserve logits, state and continuation at MLX attention boundaries. Model-free/typecheck, cancellation and final internal-SSD serving gates pass. All twelve paired comparisons retain request-time gains with 96 exact responses and no failures. | Extend held-out/combined/pressure coverage. Quantized-KV and speculative combinations stay gated pending validation. See speculative-decoding §7.4. | main |
| Serving architecture consolidation | S0–S3 merged in v0.2.0 | S4 real-conversation smoke remains. Phase 6/18 now also require shared execution at B=1/B>1, method/cache/scheduler interfaces and configuration cleanup; those are open implementation work. | main |
| Interface-based engine refactor | R1–R9 and R10 code migration merged in `673b43f`, PR #46. Model-owned execution, shared prefill/sessions, policy capture and state ownership landed. Current checkpoint: typechecks and model-free suite pass. The earlier M4 delta-golden discrepancy was reproduced in the pinned oracle and explicitly regenerated on unchanged inputs. | Share target and quiet M4 Pro acceptance with Phase 6 R0. Upstream loaded-machine repeats establish no 27B speed win. See engine architecture §12.13 and decode-speed-program §7.1. | main |
| Memory / the Dreaming | write path + nightly synthesis built; ingest is NOT wired into the nightly run; `memory synthesize --since/--model` parsed but unapplied | wire ingest into `runPipeline`; decide the embeddings-as-instruments question; promote wiki-full to a real vault | main |
| Audio input (Gemma-4) | A0–A4 served | A5 bench cells + 12B sidecar coverage | main |

## Known limitations and measurement conditions

- Recent M4 comparisons used an exclusively allocated GPU with background CPU
  activity and retained swap recorded in the reports. Diagnostic runs retain
  that classification. Default fit estimates are advisory; explicit limits
  and fixed cache layouts still constrain requests. Native allocation
  failures remain possible. Twelve Qwen oracle cases are exact.
- The old M1 Gemma solo-KL failure is explained by exact same-B oracle
  results. A separate mid-stream-join mismatch required porting mlx-lm's
  full-cache padding removal after eviction. The new protocol gate passes
  48 exact vectors each on MiniCPM and Gemma. Serving, KV-budget, containment,
  grammar, rotating-join and quantized-cache native checks also pass.
- The kv-quant RSS check in `bench-serve` misfires on large models with
  `--ssd-cache` (RSS accounting, not silent bf16) — confirm quantization via
  decode@ctx and restart-restore size instead.
- `WIRE_THRESHOLD` (generate.ts) is a host-relative fraction; the 12B sits
  near the boundary on a 24 GB machine.
- Two dev machines (M1 Max 32 GB, M4 Pro 24 GB); neither is canonical — every
  number carries host/chip/RAM ([environment.md](docs/reference/environment.md)).
