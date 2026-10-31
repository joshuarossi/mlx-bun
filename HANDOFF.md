# Handoff: the route proof for Qwen3.8-27B-Trellis on M1 Max

Updated 2026-10-31 10:50 CST. Branch `proof/qwen38-m1max-trellis`, worktree
`/Users/joshrossi/Code/mlx-bun-proof-m1max`; snapshots are committed and pushed as work lands. Paths are under `proofs/` unless absolute. The Oct 24-26 detail (receipts,
per-module results) is in `~/proofdev/HANDOFF-archive-20261026.md`.

## 1. Goal

A Lean 4 machine-checked proof that the TypeScript inference program, running Qwen3.8-27B-Trellis on
M1 Max, emits the right tokens for any prompt: one model, one program, every prompt length, every token
budget, including the stop at the first EOS token.

We verify our program only. MLX, Bun and the Apple hardware are trusted and enter the theorem as
assumptions, never proven: the hardware contract `C : M1Max.Contract` (including the uninterpreted MMA
operations `simdMma*` and `narrowHalf`), MLX's built-ins `P : MlxPrefillContract C`, the GPU assumption
`G : Metal.Gpu C` with `Pg` and `B : SetBytes`, and the Neural Engine `NE` with `NE.Succeeds`. Bun is the
interpreter model in `host/ts`.

## 2. The end theorem

`route_main` (`host/route/Main.lean`). For every prompt π with 1 ≤ |π|, tokens < 248320, budget T ≥ 1
and |π| + T ≤ 262144, and every initial content `init` of the Neural Engine surfaces, the route boots,
runs and its outcome is `RouteOutcome`: the emitted tokens are the machine reference's (`refPrompt π`),
with the EOS stop path.

- **Premises:** the trust boundary above, the checkpoint facts `env`/`leaves`/`typed`, and one pending
  premise, `Gn : RouteGen …` (`host/route/Gen.lean`): the generated proofs of every stretch of the
  program's execution.
- **Machine-level reference.** Because the MMA operations and the Neural Engine are uninterpreted, the
  reference is the machine's own computation (the route's family graph at the kernel contract, the
  Neural Engine at `NE`), not the math model. The emitted tokens equal the reference evaluated at the same
  `init` as the run, for every `init`. A model-level refinement exists only for |π| ≤ 2.
- **Composition:** `route_main` → `route_gen` (`Gen.lean`) → `route_final_framed` (`FinalFramed.lean`), with
  `route_of_piecesFramedAt` (`compose/MainFramed.lean`). Prefill runs in `fullWorldXD NB`, decode in the pinned world
  `fullWorldFb b0 NB`. `Gn` is being built in `host/route/GenOf.lean`.
- `Final.lean`'s module doc states the trust boundary and the reference precisely.
- Not yet shown: that the trust-boundary assumptions are jointly satisfiable (one model of all of them).
  Optional; it would rule out a vacuous theorem.


## 3. Status

**Compiles from current sources** (`bun ~/proofdev/tools/build.ts`, build dir `~/proofdev/build`):
`route_gen`, `route_final_framed`, `route_of_piecesFramedAt`, `ldCut` setup entry, `decCutFirstFb_handoff`, all of
native/sim's 226 registered modules (`host/sim/full`, `native`, `dispatch`, `steps`, `footprint`, `conv`). `route_main`'s closure is 3,218 modules; 2,385 are reusable, and the 798-module
boot chain `host/load/boot/w/*` needs recompiling against the current core (11-16 h, not yet rerun).

**Proved, conditional only on the trust boundary:**
- One fixed one-token prompt, every budget, no-EOS case, at the model level: `source_tokens`.
- All 21 Metal kernels from source under the GPU assumption.
- Boot for any prompt and readback suffix: `route_boot`. Neural Engine programs: `aneNetLd_ok`. Prefill schedule
  typing for any length: `scheduleTyped`.
- The six decode cases: `Host.Ts.Sim.Compose.DEC_<k>.case` (`compose/a4b/Fill_DEC_<k>.lean`), for every pinned bridge.
  Budgets, EOS after token 1 and fixed frames: `host/route/DecodeBudgetSaved.lean`, `DecodeEosComplete.lean`, from an
  initialized decode cut.
- Load-completion cut `ldCut`/`ldCut_inv`; setup from it for L <= 8: `compose/a4b/SetupChunkStage.lean` (`ldCut_chunk`).
- Singleton route, L = 1, T = 1, every token id: `host/route/LoadedCut.lean`, `SingletonReference*.lean`,
  `compose/a4b/SetupD1*`, the D1 64-layer forward (`a4pre_d1_*`), POST, EOS and non-EOS ends.
- Machinery: full-world relation, restarts, compactions, bridge frame, hand-off (`full_handoffTb`), Neural Engine memory
  invariant (`AneCut`), symbolic-shape replay (`full/ReplayV.lean`).

**Not proved: `Gn : RouteGen` (`host/route/Gen.lean`), the one premise of `route_main`.** It needs:
| Piece | State |
|---|---|
| `Pieces` (`compose/Bundle.lean`): 133 forward, 81 stage, 27 glue | Links compiled: `compose/PreCall.lean`, `PreFill.stageP/fwdP`, own-map `Pieces.lean`, regenerated `Bundle`/`Class*`. First fills in `compose/a4b/FillSetupEarly.lean`. VW chain regenerating (`first_tail_x15`); no Neural Engine chain yet. |
| POST (`hpostPieces`), hand-off (`postHandoff`), short paths and graphs (`shortPaths`, `graphA/B2/B0/C1/C0`) | The current blocker: generator hasn't reached a common POST boundary. Hand-off theorem `decCutFirstFb_handoff` compiled; needs its shift and `withLo` obligations (`full/HandleBand.lean`) checked at POST. L = 1 exists from the singleton. |
| Decode `D`, `Dg`, constants, counter bounds | Written concretely in `host/route/GenOf.lean`. Rebuild from current sources: four of six `DEC_<k>.case` compile with standard axioms (ord, clear, grow, fill), clearFill and clearGrow remaining; `decode_counter_bounds` compiled. GenOf not compiled yet. |

**In progress (31 Oct):** VW step `template/a4pre_first_tail_x15_r0` plus `_body`: prefix, setup chunks, `g0b` and suffix compile; the 192-site body is compiling, memory-capped stages being split; the row count is kept as body variable 10. One-token route from `ldCut` to the forward's return compiles (`singleton_forward`, 1,544,195 steps). Per-class drain budgets in `world/Offset`.

**Discarded:** rounds R1-R113 and the VW17 "source-only" bundles in `~/proofdev/devout-sol-general-prefill-*` (Oct 27-30)
were hand-written interpreter steps that were never compiled, reviewed only byte-wise, stopped by a resource-sampler
failure in private tooling. They earn no credit and are not the plan.

## 4. How the proof is built

**Symbolic simulation.** The proof is a symbolic simulation of a Lean model of the interpreter
(`host/ts`) running the pinned repository source. Native "choosers" compute candidate states; the
kernel checks every state. A *chain* is a checked trace of one stretch of the program (a forward call, a
decode step, glue between calls), proved once with the row count symbolic so it covers every prompt that
takes that code path. Stream data (the boundary states) lives outside the repo.

**Why there are several traces.** The program branches on the prompt: chunk sizes and row counts select
different GPU kernel sets (V23, V4, V58, VW for 9–223 rows) and the Neural Engine (224 rows and up); decode
takes one of six cache branches (ordinary, grow, fill, clear, clear-fill, clear-grow). Each code path is
traced once, symbolically.

**Seams (the composition rule).**
- Every piece is proven against an interface, never another piece's internals.
- Added behaviour is a layer over an unchanged base, with a projection lemma and, where the layer is
  less stuck, an agreement lemma; old proofs transfer by a lifting theorem.
- An in-place edit is allowed only when behaviour-preserving on everything previously defined.
- Stage contracts (load, schedule, forward, cache, sample, generate), each with its live set before and
  after, compose; what a stage does not touch is framed.
- Seams: hardware (`C`, `NE`); MLX (`P`); GPU (`G`, kernel contract from each kernel's source); FFI model
  (base + layers: Neural Engine bridge, liveness, kernel recording, symbolic shapes); interpreter; stage
  contracts; graph obligations against the row-family builders.

**Key mechanisms (where they live).**
- Full world `Layers.full` (`host/load/Layers.lean`), relation `FullR` (`host/sim/full/Rel.lean`), with
  fields for pending traces (`pend`), freed sets and kernel records.
- Per-site stage instances (each call site re-checked, caller-only entries kept as template entries);
  isolate/merge (`conv/Iso*`, `Merge`, `SiteMerge`); compaction with the native footprint lemma
  (`conv/NShiftFoot.lean`, `NClean.lean`): only written and result handles are checked.
- Recorded closure traces: relations that record are band-free (NL = N0) and the full layer raises the
  band (`FullRD`, `host/sim/full/Raise.lean`).
- Decode runs on the banded relation P = ⟨25000, 131072, 2^40, 20000, 22539⟩, with the Neural Engine bridge
  framed and pinned at its hand-off value (`BridgeFb`, `host/sim/full/BridgeFrame*.lean`).
- Acceptance layers (`host/sim/dispatch`): `okJS` (base, unchanged), `okJSK` (callback continuations and
  extra builtins), `okJSJ` (JS-pointer bigints). Decode uses `okJS`; band-free prefill uses `okJSK`/`okJSJ`
  at `okCallFSD`.
- Restart and compaction are generic over the bridge relation (`full_restart_dropB`,
  `full_compactQB`); the inactive, active and pinned cases are instances.
- Oracle (LinGood) checks per piece over parameter boxes (`host/sim/lin/*`).

**Fixed interfaces for generation.**
- Chains start from `ldCut` (`RouteGen.hI`). Template variables 0–8 are reserved for `machVal` (T, the
  readback tokens); chain quantities sit at 9 and up.
- Prefill ends hand off to decode by `full_handoffTb` into `fullWorldFb b0`; the decode cut invariant is
  `∃ b0, (inactive ∨ Quiet) ∧ pinned relation` (`decCutFb`, `Final.lean`).
- Every cut from loadDone on carries `AneCut … V D σ m`.


## 5. Plan

1. **Links** (`compose/*`): stage and forward call links over the prefill relation (`Disp.FRJ (FullRXD ...)`, wide frame
   `wideP`, prompt framed at 2665), `compose/gen.ts` prefill mode, fill bundle fields from chains.
2. **Generator** (`template/*`): prefill chains from `ldStT [] []` with `Decode.tab`, cut at `compose/chains.json`'s calls;
   chain quantities at variable 9 and up; compaction at the band raised to the call state's node counter (`full_compactQD`).
   First: one complete step through a VW forward (`first_tail_x15`), then one Neural Engine forward with the bridge active.
3. **Native/sim**: fix what those chains reject.
4. **Route** (`host/route/*`): POST, short paths, hand-off into `decCutFb`, counter bounds, `RouteGen` assembled.
5. **Bulk generation**, once 1-4 work end to end on one row of each family.
6. **Final:** consistent build of everything, full `check.ts`, then `route_main` without `Gn`.

**Size and speed (31 Oct, measured).** One VW forward: 1.5M glue steps, native run 51 slot-min, 6,578 small modules as first generated. Almost all of that is imports. One import edge (`host.sim.extract.Grow → host.simgraph.Grow`) puts 8,625 Mathlib modules under every generated module, while a chunk check uses constants from about 530 modules. Being fixed in one batch:
- cut that edge (about 3x less import CPU);
- drop 1,739 modules with no consumer;
- merge the remaining 4,837 into 33 bundles (`template/genMerge.ts`);
- 3,333-step stage boundaries, avoiding 90 native reruns.
Estimate after these: about 3 CPU-h per VW forward. x9 and x15 VW bodies match so far, and `plan` has 3 answer patterns across 17 bands, so VW may drop from 58 pieces to 13 (133 to 88 in total), about 260 CPU-h.

**Machine lessons (31 Oct).**
- RSS overstates Lean: most of it is shared mmapped oleans. Use footprint.
- APFS clones share disk blocks, not the page cache. Compiled files are hardlinked through `~/proofdev/cas`; the builder reuses any agent's compile (index in `cas/index`) and has early cutoff (dev only; the final full build rechecks everything).
- `memory_pressure`'s free % counts the file cache as free. The gate admits by compressor size instead: 5 slots, or 2 while the compressor holds 9 GB or more. Throughput went from about 1.4 to about 18 modules/min once it stopped thrashing.
- Docker Desktop's VM holds about 14.5 GB of the 32 GB when running; closing it would let the gate stay open.

**Biggest blockers:** (1) bulk cost, above; (2) the Neural Engine path, worker building the first chain now; (3) POST for any prompt length, offset and capacity as variables, generator and route; (4) the graph evaluator change to `evalRR`, route; (5) feeding generated counters into the growth recurrence (`world/Recurrence.lean`), route; (6) disk: 168 GiB free, floor 110.

**Rules for the machine reference:** for |π| >= 3 the reference is the machine's own computation, because MMA and the
Neural Engine are uninterpreted; the model-level statement stays limited to |π| <= 2.

## 6. Decisions (dated, with reason)

- 22 Oct: per-site re-check of stage instances instead of an interpreter frame theorem (2–3 weeks).
- 23 Oct: native footprint lemma for compaction (33 chunk modules per site would have meant ≈ 137k
  modules).
- 23 Oct: recorded traces via a band raise (`FullRD`), not by relaxing `G.MRw` (under every module) and
  not by hiding traces in a new field (a hand-proved sweep over ≈ 40 model cases).
- 23 Oct: reshape with `-1` over symbolic dims: prefix cancellation first, then the server equality test,
  old order-free cancellation last. Results differ from before only in one corner no proof or stream uses.
- 23 Oct: JS-pointer bigints as a separate law (`BigJs`) with its own acceptance, not a field of `RelB`.
- 23 Oct: decode on the banded relation; Neural Engine bridge framed and pinned in decode, so the six
  decode traces serve short and Neural Engine prompts.
- 23 Oct: readback-queue tail moved into the relation's parameters (`dropTokens`), restart unchanged.
- 23 Oct: compaction-introduced variables replaced by their defining terms at the chain end
  (`cut_decanon`), so the loop shift stays `loopTheta`.
- 23 Oct: `AneNet.inputs` indexed by row count (the old form made the Neural Engine premise unsatisfiable).

- 31 Oct: the end theorem's graph goals (`GFM`, `ForwardAtM`, `goalM`, `goalC`, `machGx`) move from `evalR` on the decode-kernel graph to
  `evalRR` on `ffiGraphR`, as a layer: `evalR` has no value for prefill kernels, so the old statement fails after a multi-row step.
  The reference was already `evalRR`; the trust boundary doesn't change.
- 31 Oct: `BridgeA.dense` starts at node 1, fixed in place: as written it could never hold, so every active-bridge theorem was vacuous. Lands with a compiled witness of the active relation.
- 30 Oct: stop source-only work; everything is compiled as it is written, generated rather than hand-stepped; no
  receipts, admissions or review packets. Acceptance is the kernel plus `#print axioms`.

## 7. Working rules

`~/proofdev/proof-brief.md` has the rules and the build commands for agents.

- Commit and push snapshots of the proof sources as we go (Josh, 31 Oct): sources, tools and their data, registered
  generated modules and each chain's `States.lean`; not stream data, `node_modules`, or unregistered generated modules.
- The boot chain `host/load/boot/w/*` waits for the final build (Josh, 31 Oct): finish everything else first.
- Machine: 32 GB, 10 cores, 3 compile slots via `~/leanslot.sh`; 8 GB cap, 24 GB exclusive retry, enforced on footprint.
  Keep `/System/Volumes/Data` above 110 GiB free.
- Builder: `~/proofdev/tools/build.ts` compiles an import closure from the worktree, reusing a compiled file when its source
  and its dependencies' compiled files are byte-identical.
