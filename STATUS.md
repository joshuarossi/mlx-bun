# STATUS — live handoff

**Governing product objective:** Josh's "The absolute BEST local AI experience on a mac". This covers simple installation, direct application integration, JavaScript/TypeScript development, everyday usability and inference quality/performance. The [product principle](docs/planning/PRODUCT_ROADMAP.md#product-north-star) governs every workstream.

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

## Threads (one row each; the PLAN.md heading is the source of truth)

| thread | state | next action | branch |
|---|---|---|---|
| Qwen3.8-27B inference performance | Phase 6/18 remain open; the accepted PR #48 work is released as v0.4.0. | **Current milestone, revised by Josh:** keep shared batching as the default with effectively equal measured B1 performance. Serving already defaults to cap eight and uses B1 for a lone eligible request. Explicit `--batch 1` retains serial; removal and complete feature parity are deferred follow-ups, not blockers for this default. **Integrated:** shared ordinary and speculative methods, sampling/lifecycle ports, generated RAM snapshots and queued SSD persistence, affine/TurboQuant row layouts including delayed precision, paged storage, adapters with lookup, and independent greedy verification sampling. Main suites, typechecks and full hygiene pass. **Current:** shared ordinary interrupted-generation resume is integrated, including queued persistence and affine/TurboQuant layouts. Both-machine native/HTTP compiled, uncompiled, delayed-precision and mixed-grammar controls, complete suites/SSD/types and the matched M4 timing comparisons are complete. The source-only timing comparison preserves every response/usage record with effectively flat performance. The packed-model HTTP fixture now gives each fresh model its own weight handles. Adapter resume and tiny/oracle-tested GLM shared MTP are also integrated from the remaining campaign checkouts. [PR #48](https://github.com/joshuarossi/mlx-bun/pull/48) contains the accumulated implementation, tests and evidence. All 80 secondary Git worktrees and 99 campaign source copies are archived and removed; both primary checkouts remain. Local typechecks, hygiene and focused integration checks pass; The implementation CI passed and v0.4.0 is published; remaining work follows the revised milestone. Retain serial as requested. **Remaining:** close specific unsupported media/fill/grammar-jump and adapter-resume combinations, resolve recorded B1/prefill/cache regressions, consolidate defaults/configuration, complete remaining kernel and long-task work. Serial removal is deferred. Existing provider/KV/paging correctness evidence remains accepted; umbrella L2/Lab entries need reconciliation with that evidence. Final GLM artifact testing is deferred by Josh. No DSpark/DFlash checkpoint has been trained yet; only seeded execution fixtures exist. Feature evidence: PLAN Phase 6/18 and batching.md; performance: benchmarks.md. | feature/perf/qwen-27b-closeout |
| Repo taming (docs/files/agent instructions/seams) | Docs map, repository gates, request pipeline and shared prefill extraction landed; the engine refactor is merged. | D6 retention decisions still need workload measurements. True B-wide prefill remains Phase 18 S1a. | main |
| TurboQuant weights — Q campaign (sub-4 bpw) | **Q3 PASSED** (KL 0.1553 @ 3.55 bpw; flagship 0.1646 @ 4.80; MMLU 88 / tGSM 48 / rawGSM 44). **Q2b packed format LANDED 2026-09-02**: 12.14 GiB artifact, decode bit-identical to the fake-quant, KL 0.1550 through our engine, coherent generation; M1 Max decode **9.3 tok/s vs 18.9** flagship after three kernel rounds. **down_proj axis settled — KEEP THE ROTATED AXIS**: `--down-axis in` is 11.3 vs 9.3 tok/s at identical KL/MMLU/tGSM but rawGSM **29/50 vs 44/50**, strictly nested (15 regressions, 0 gains), failure = immediate EOS — incoherence processing must reach the CODED axis (third instance of "KL is the screen, not the verdict"). Carry-forward: `…-k300-packed` (12.14 GiB, 9.3 tok/s) | Q5 2.75-budget arm; q2a/q2b task columns; rawGSM EOS-cliff root cause (now with two arms exhibiting it) | chore/tame-jungle |
| Resumable long-agent generation | The merged path passes seven saved boundaries in both serial and continuous serving, with identical responses and durable final SSD flushes. The longest prompt has 14,465 tokens and generates 512. Earlier Pi stopped on an unparsed tool call and did not complete its app task. | Repeat pressure/reliability coverage as graph barriers or kernels change; investigate the separate affine transient-allocation control. Evidence: turn-8 repro and decode-speed-program §7. | main |
| K3 token fast-forwarding (fill) | Parser guards and model-owned appends are integrated. Both Qwen quants preserve logits, state and continuation at MLX attention boundaries. Model-free/typecheck, cancellation and final internal-SSD serving gates pass. All twelve paired comparisons retain request-time gains with 96 exact responses and no failures. | Extend held-out/combined/pressure coverage. Quantized-KV and speculative combinations stay gated pending validation. See speculative-decoding §7.4. | main |
| Serving architecture consolidation | S0–S3 merged in v0.2.0 | S4 real-conversation smoke remains. Phase 6/18 now also require shared execution at B=1/B>1, method/cache/scheduler interfaces and configuration cleanup; those are open implementation work. | main |
| Interface-based engine refactor | R1–R9 and R10 code migration merged in `673b43f`, PR #46. Model-owned execution, shared prefill/sessions, policy capture and state ownership landed. Current checkpoint: typechecks and model-free suite pass. The earlier M4 delta-golden discrepancy was reproduced in the pinned oracle and explicitly regenerated on unchanged inputs. | Share target and quiet M4 Pro acceptance with Phase 6 R0. Upstream loaded-machine repeats establish no 27B speed win. See engine architecture §12.13 and decode-speed-program §7.1. | main |
| Memory / the Dreaming | write path + nightly synthesis built; ingest is NOT wired into the nightly run; `memory synthesize --since/--model` parsed but unapplied | wire ingest into `runPipeline`; decide the embeddings-as-instruments question; promote wiki-full to a real vault | main |
| Audio input (Gemma-4) | A0–A4 served | A5 bench cells + 12B sidecar coverage | main |

## Standing hazards (verified today)

- M4 Pro CPU allowance is explicit: Josh permits the busy audio daemon while
  memory and GPU availability are preserved. The M4 reboot cleared swap and
  the matched comparison completed using diagnostic mode after swap returned. Default fit estimates are now
  advisory by Josh's instruction; only explicit limits and fixed cache layouts
  restrict requests. Reservation prototypes are superseded, not acceptance.
  Native allocation failures remain possible. Twelve Qwen oracle cases are exact.
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
