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
| Repo taming (docs/files/agent instructions/seams) | Phases 0–3 landed on this branch: −50k lines, one canonical doc per topic, generated doc map, gates for every rule (`bun scripts/check-hygiene.ts`, `tests/docs-surface.test.ts`) | Phase 4 remaining: unify the two prefill loops; D6 darlings (quarantined, not killed). Landed: the request pipeline (`ChatRequest → ChatStage → InferenceRequest → InferenceStage → InferenceResult → wire`, `src/serve/{chat-request,chat-stage,text-completion-stage,inference-request,http,openai-wire,model-host,request-prep,token-streams}.ts`; server.ts 3,690→1,541), `src/lab/` quarantine + import lint, required `Cache.signature()`, real batch-lane timing, tests in `tests/{unit,serve,using,parity,research}` with CI by directory | chore/tame-jungle |
| TurboQuant weights — Q campaign (sub-4 bpw) | **Q3 PASSED** (KL 0.1553 @ 3.55 bpw; flagship 0.1646 @ 4.80; MMLU 88 / tGSM 48 / rawGSM 44). **Q2b packed format LANDED 2026-09-02**: 12.14 GiB artifact, decode bit-identical to the fake-quant, KL 0.1550 through our engine, coherent generation; M1 Max decode **9.3 tok/s vs 18.9** flagship after three kernel rounds. **down_proj axis settled — KEEP THE ROTATED AXIS**: `--down-axis in` is 11.3 vs 9.3 tok/s at identical KL/MMLU/tGSM but rawGSM **29/50 vs 44/50**, strictly nested (15 regressions, 0 gains), failure = immediate EOS — incoherence processing must reach the CODED axis (third instance of "KL is the screen, not the verdict"). Carry-forward: `…-k300-packed` (12.14 GiB, 9.3 tok/s) | Q5 2.75-budget arm; q2a/q2b task columns; rawGSM EOS-cliff root cause (now with two arms exhibiting it) | chore/tame-jungle |
| Resumable long-agent generation | In-flight serial KV checkpoints implemented: cache-covered emitted prefix + pending next token, atomic SSD persistence, exact-request replay/resume, including Qwen recurrent caches. Model-loop and SSD restart tests pass. | Run the 27B Pi Kanban eval with `--generation-checkpoint 4096`; measure checkpoint stall/size and validate one real process restart. | chore/tame-jungle |
| K3 token fast-forwarding (fill) | Live A/Bs on the 27B 2026-09-02 (serial arms, 32 paired turns; speculative-decoding.md §7.3): **echo** injects 7.4% but wall clock ×1.00 (76% verify rejection) — FAILS, stays Lab; **strict** (rows fixed twice today: primer newline merge, then a `</think>`-triggered scaffold that asserted a tool call the model would have answered in prose 2/5 — now triggers on the model's own `<tool_call>`) injects 5.3% with 100% acceptance, identical calls, median wall ×0.99. Proposal trace `MLX_BUN_FILL_TRACE=<file>` + `fill trace` list every proposal vs the model's own token. Batch lane never fills. Crash repro: turn 8 of `2026-08-18T04-34-36` (MLX C++ exception, 5/5) | Strict tier: gate is token identity (`tests/parity/fill-strict.test.ts`) on the 27B before any default; echo: policy levers (anchor K, span cap ≈ accepted length, assert corroborated spans); a multi-turn showcase fixture (the single-prompt one fills 0%); crash ISOLATED to prompt-cache prefix reuse on the qwen3_5 hybrid graph (`lab/repro/serve-crash-turn8`: `--prompt-cache 0` serves the session; default cache dies on turn 8, 6/6) — root cause owed | chore/tame-jungle |
| Serving architecture consolidation | S0–S3 merged in v0.2.0 | S4: real-conversation smoke on merged main, then close the PLAN block | main |
| Interface-based engine refactor | R1 complete; R2 bindings and shared R5 prefill pass native replacement/batch gates. Pi/web protocol types share a portable module. | Complete method bindings and feature-composition gates, then state ownership/identity migration. Use available fixtures/models for compatibility; target validation follows separately. Qwen replay reports Metal OOM; reconcile Josh’s other-machine fix. Quiet baseline remains open. See engine architecture §12. | refactor/interface-engine-v2 |
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
