# Handoff: the route proof for Qwen3.8-27B-Trellis on M1 Max

Updated 2026-10-31 18:00 CST. Branch `proof/qwen38-m1max-trellis`, worktree
`/Users/joshrossi/Code/mlx-bun-proof-m1max`; snapshots are committed and pushed as work lands. Paths are under `proofs/` unless absolute. The Oct 24-26 detail (receipts,
per-module results) is in `~/proofdev/HANDOFF-archive-20261026.md`.

## 1. Goal

A Lean 4 machine-checked proof that the TypeScript inference program, running Qwen3.8-27B-Trellis on
M1 Max, emits the right tokens for any prompt: one model, one program, every prompt length, every token
budget, including the stop at the first EOS token.

**Current scope (Josh, 31 Oct): the Neural Engine is out for now.** The target is the same conclusion for prompts
that never run a Neural Engine forward (about |π| ≤ 224; measured L = 224 inactive, L = 225 active; route is
confirming the bound and reachable rows). Longer prompts are not covered by this theorem. All Neural Engine work
stays in the tree, parked, to be added back later as a layer without redoing it.

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
- **Current target: `route_main_gpu` (`host/route/MainGpu.lean`), beside `route_main`, which is unedited.** Same conclusion and trust boundary, plus `hL : π.length ≤ 224`, with `RouteGenGpu` (differs only in `Pp : PiecesR`, `H : RoutePiecesR`) instead of `RouteGen`. `route_gen_gpu` (`host/route/Gpu.lean`) is the same theorem with the boot's facts as hypotheses; it compiles (31 Oct), standard axioms per route, along with `ClassStepsR.toPrefSteps`, `casesOfFour` and the POST graph side (`route/PostGraph.lean`). `RouteGenGpu` also takes the boot's end state `tL`, and `hI` enters from `ldPromptCutAt`; the cold stretch uses `ColdG`, not `DrainG`. Open: links' `Pp`, `H`, `I`; generator's forward chains (including `fwd_D1_dcold_DFit`) and per-class POST chains; route's per-row graph certificates (`hfwd`), not started and the largest unknown on its side. `routeGenOfGpu` (`GenOfGpu.lean`) leaves `I`, `Pp`, `loadEntry`, `postPieces`, `shortPaths`, `postHandoff` and five graph certificates. Row set: `compose/rows-gpu.json`, generated for L = 1..224: 34 of 298 rows, 24 of 130 forwards (17 VW), 4 of 6 decode cases (`clearFill_not`, `clearGrow_not`, by `omega`, for every T). Restricted bundle: `BundleR`, `ClassR`, `RouteBundleR`, `RouteStepsR`. L in 87382..262143 also avoids the Neural Engine but needs 102 rows and all six decode cases; left for a later layer.


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

**In progress (31 Oct):**
- VW step `template/a4pre_first_tail_x15_r0` plus `_body`: prefix, setup chunks, `g0b` and suffix compile; the 192-site body restarts on the slimmer imports; the row count is kept as body variable 10.
- POST for any prompt length: `PRE_pl_entry/head/selector/call/common` compile with standard axioms; `PRE_pl_tail` and the T=1 tails are running.

**Parked: the Neural Engine (31 Oct, out of current scope). Nothing below is needed for the current target.**
- **Landed and registered:** bridge frame `full/LogFrame`, `LogBase`, `LogRel` (relation `FRL L FR`, `fullStepSimXLBNL`, `fullStepSimXLBXDJSL`), witness `tests/ActiveRelationLog`; `full/SizeNE`; `conv/HandOffL`; `full/LogGrow`. No chain has run at `L ≠ []`.
- **x22 row** (`first_tail_x22.r0`, L=226, flat body: 2,479,926 steps, 579 chunks, 128 size bridges; state in `~/proofdev/build-ne`, stream in its `.host-stream`, outside git). On the current base through the kernel: `s0_tok`, `K3`, `K232`, `K246`, `Steps0-13`. On the base before the core rebuild, so needing a rebuild to count: 142 of 323 K modules (all in K0-K231), `Bridge0-15`, `Ends0-8`, the suffix including `eval`, `SiteZ0`, `SiteB0`/`cshiftX0` (first active compaction, not axiom-audited), `Good`. No K rejection anywhere, only memory. Not done: K233-K322 except K246; run theorem s0 → s579; `Cross` (size crossings); `Steps14-15`; the row-end memory conversion; later rows. Cost per K rises along the chain, 2.6 → 5.5 GB by K240.
- **Resume x22** from `proofs/host/sim/template`, with `LEAN_DYNLIB=~/proofdev/devout-sol-native43/.native43-current/libloadproof-full.dylib HOST_STREAM_DIR=~/proofdev/build-ne/.host-stream`. Generated modules are on disk; only if generators change: `bun genChain.ts a4pre_first_tail_x22_r0 PRE_first_tail_x22_r0 --world full --boot-bridge --inactive-bridge "(Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)"`, `bun genBoundary.ts a4pre_first_tail_x22_r0 PRE_first_tail_x22_r0`, `bun genNeFlat.ts a4pre_first_tail_x22_r0_body PRE_first_tail_x22_r0_body --group 1 --rows first_tail_x22.r0 --cross 1,64,128 --ok host.sim.template.a4pre_first_tail_x22_r0.Accept PRE_first_tail_x22_r0.neOk --source PRE_first_tail_x22_r0.s41 PRE_first_tail_x22_r0.S41 host.sim.template.a4pre_first_tail_x22_r0.H1 1087`, `bun genChain.ts a4pre_first_tail_x22_r0_suffix PRE_first_tail_x22_r0_suffix --world full --active-bridge --non-arrays 2673472,2673473`. Build with `bun timeBuild.ts --out ~/proofdev/build-ne --keep-going --jobs 3 <files>`. Later rows use `FRL L (FullRXD P NB)`, templates starting at `log = []`, with `running` keeping one deferred node; x22 ends with `running [20085]`, `outLocked [42]`, log length 256. Drain rows: the slice length is a literal and plan `lens` takes only vars; use var 10, untested. After an NE forward, `mlx_closure_apply` was rejected in an earlier scan and not re-examined at this acceptance.
- **Hand-off gap, Neural Engine prompts only:** `decCutFb` can't be instantiated as stated. `Quiet.running` fails: one running node at the hand-off on all 16 lengths run (L = 225 to 10923), an `astype` reading surface 4, unchanged through decode up to T = 6; only the final `mlx_synchronize` clears it. `Quiet.img` is unmeasured. Josh's choice when this resumes: fix B first (leave the decode proofs untouched), fix A only if B is impractical. Native's parked state is in `~/proofdev/tools/ne-parked/` (resume steps there; `/tmp/nativefield` is scratch): closure threads along any target `runC` with no prefill invariant (`closure/Run.lean`, `Closed.lean`, compiled in scratch); `GC` at boot not proved. B: `FfiNat.runC_sim` is the lift, but it needs a simulation at every call, and by reading, `mbane_eval_async` on a program using surface 4 is accepted with `running = []` and stuck with `running = [d]`, so B also needs "decode makes no bridge call" exported from the decode cases, or a restricted world. A: `optionA/`, stopped at a compile error; rebuild cost unmeasured.
- **Field scan** (`ne-parked/results`, `frame.txt`): surfaces, stripped programs and handles match at all 155 later boundaries; each later row start has 0 unscheduled and 1 running. Only about half the pairs of later row starts admit a node map (683 of 1,406): wrap sets depend on which buckets ran, so whether one template per class works is open. The second clear (`clearFill`, `clearGrow`) wasn't reached.
- **Before any full `check.ts`:** it throws on any unregistered `.lean` under `proofs/`. The 673 x22 files and `template/ActiveShift.lean` aren't registered. They're regenerable or parked: move them out of `proofs/` before the final build (the same applies to any other unregistered generated module).

**Cost driver found (31 Oct):** `SSrv.tab` is a plain list, so kernel cost per numeric op grows with table length. Measured: the same chunk goes from 6.4 s to about 20 s with 8,000 extra entries; the x15 table reaches 8,218 by site 191. Cost is prototyping a table-reset conversion at layer boundaries, to adopt before bulk generation.

**Trust boundary satisfiable (31 Oct):** `Host.Route.Sat.route_trust_satisfiable : Nonempty RouteTrust` (`host/route/sat/Main.lean`) compiles at the actual `code` graph, independent of prompt and budget, standard axioms per the worker's `#print axioms`. The model is degenerate on purpose: it rules out contradictory premises, not that real hardware meets them. `route_gen_trust` checks the fields against `route_gen`'s types. Still to do at the final build, when `host/route/Main.lean` compiles: the same application to `route_main`. `Gn` is outside the witness, so an unconditional instance needs `RouteGen` discharged for every trust boundary. Open question for Josh: `NE.Succeeds` covers every input surface, not only reached ones, so it would be false on real hardware if the Neural Engine can reject a program because of input bytes.

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

**Size and speed (31 Oct, measured).** One VW forward: 1.5M glue steps, native run 51 slot-min, 6,578 small modules as first generated. Almost all of that is imports. One import edge (`host.sim.extract.Grow → host.simgraph.Grow`) puts 8,625 Mathlib modules under every generated module, while a chunk check uses constants from about 530 modules. Fixes:
- that edge cut, landed 31 Oct 12:51 (`extract/GrowGraph`, `template/SetupP`, `compose/a4b/VWFramesDefs`). Its validation was weaker than first reported: early cutoff reused modules whose direct dependencies came out byte-identical, so they still held compiled files from when Mathlib was in their closure (`boot_rfl` crashed on `BootEq`). Rebuilt under `cas/epochs.json` (31 Oct 15:23): the 1,170-module core closure compiles from current sources with no source failure, and `BootEq` no longer names Mathlib. Generated chains and `load/boot` are still to come; `load/boot/ld/NC` hit the 8 GB cap twice and goes to the exclusive retry;
- 3,333-step stage boundaries (`"chunk": 3333` in chain plans), avoiding 90 native reruns;
- not yet applied: drop 1,739 modules with no consumer; merge the remaining 4,837 into 33 bundles (`template/genMerge.ts`).
Estimate after these, not yet measured: about 3 CPU-h per VW forward. x9 and x15 VW bodies match so far, and `plan` has 3 answer patterns across 17 bands, so VW may drop from 58 pieces to 13 (133 to 88 in total), about 260 CPU-h.

**Machine lessons (31 Oct).**
- RSS overstates Lean: most of it is shared mmapped oleans. Use footprint.
- APFS clones share disk blocks, not the page cache. Compiled files are hardlinked through `~/proofdev/cas`; the builder reuses any agent's compile (index in `cas/index`) and has early cutoff (dev only; the final full build rechecks everything).
- `memory_pressure`'s free % counts the file cache as free. The gate admits by compressor size instead: 5 slots (3 during the Neural Engine K modules), or 1 while the compressor holds 11 GB or more (8 left half the CPU idle once K modules were gone). Throughput peaked around 18 modules/min without thrashing, against about 1.4 while thrashing.
- Admission can't foresee a compile's growth: six x22 K modules at about 6 GB footprint each held the machine at 16 GB compressed for 50 minutes. Fixed by size: one 10k-step chunk per K module (`--group 1`), about 3.2 GB median footprint and 23 slot-s. Don't SIGSTOP compiles: once a child has stopped, the gate's zsh `wait` returns 145 however it ended, which reads as a failure with an empty log (a pausing governor tried on 31 Oct did this, and was removed).
- Each `States.lean` compile stamps a unique nonce into its compiled file (`IO.monoNanosNow`), so separate compiles of it share nothing downstream. `~/proofdev/leanwrap/bin/lean` now runs one compile per (module, source, direct dependencies' compiled files, native library): a second builder waits and takes the file, the output and the chain's stream directories (`tools/streamclone.zsh`). Shares are logged in `leanwrap/shared.log`; `LEAN_NODEDUP=1` turns it off for one compile. Installed 31 Oct. Stream reuse confirmed on a real chain: a fresh build dir reused x15's `States`, cloned its streams, and compiled `H0` and `st0/H0` from them.
- A killed builder leaves its compiles behind with parent 1. Until 31 Oct the gate's `trap cleanup TERM` removed the ticket without exiting, so those waited forever, and could hold a compile lock that live builders waited on (generator, links and NE lost about an hour to this). The gate now exits on TERM, and a lock waiter takes over from a holder whose builder has gone. Kill the whole process tree anyway, and tell its owner. Test gate edits on a private queue before installing.
- A compiled file doesn't change when something further down its closure changes, so a direct-dependency key can't see a removed import. `~/proofdev/cas/epochs.json` lists `{root, time}`: a module whose closure contains `root` won't reuse a file compiled before `time`. Add an entry whenever a change removes imports low in the graph. The final full build rechecks everything regardless.
- A reused `States` module needs its stream: `build.ts` finds it by the nonce in the compiled file, across `~/proofdev/*/.host-stream*`.
- Many thousands of log files overflow the argument limit, and `2>/dev/null` hides that: a `grep` over a `.log/*.log` glob can report zero matches falsely. Use `find ... | xargs`.
- Docker Desktop's VM holds up to about 14.5 GB of the 32 GB when running; closing it would let the gate stay open.

**Biggest blockers (current scope):** (1) compile `route_gen_gpu` and its bounded layer, route; (2) bulk cost of the GPU forwards, cost: x15 body measured at 2.60 slot-h for 31 of 36 modules before the fast check. Decided 31 Oct: no table reset (about 2x at best, and it changes cuts); fast check `runOkS` instead, with statements unchanged and no cut change, B13 744 s to 225 s; landed for x15: the 13 glue bundles went from 1.60 to 0.69 slot-h and no longer grow along the chain. The 17 VW forwards reduce to 3 bodies (checked on x6, x8, x15). The D1 body still has 1,445 modules, 564 of them memory splits; cost is testing whether the fast check makes those unnecessary; (3) POST for bounded prompts, generator and route; (4) links: `I π`, VW body pieces, fills; (5) feeding generated counters into the growth recurrence (`world/Recurrence.lean`), route; (6) disk: 172 GiB free, floor 110.

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
- 31 Oct (Josh): Neural Engine out of scope for now, to get a complete theorem for shorter prompts. 78 of 298 chain rows and 53 of 130 forward stages use it directly, and more rows are reachable only after it. Done as a layer, so it can be added back.
- 31 Oct: bridge frame for rows after the first active forward: `b'.log = b.log.map M.effect ++ L`, `L` fixed along a chain, and the target's `programs` equal the template's modulo `inLocked`/`outLocked`. Row templates start at `log = []`; boundary memory is stated on the target. As written, one row template can't relate to a target whose log and lock flags depend on earlier rows. Only the memory semantics read the log, and nothing reads the flags. Stated against a stripped target in new modules, so `BRel`, `BridgeX`, `FullRX` and the 8,132 modules above `full/BridgeA` don't change. Field check measured on one path only (L = 5000, native, up to the first readback).
- 30 Oct: stop source-only work; everything is compiled as it is written, generated rather than hand-stepped; no
  receipts, admissions or review packets. Acceptance is the kernel plus `#print axioms`.

## 7. Working rules

`~/proofdev/proof-brief.md` has the rules and the build commands for agents.

- Commit and push snapshots of the proof sources as we go (Josh, 31 Oct): sources, tools and their data, registered
  generated modules and each chain's `States.lean`; not stream data, `node_modules`, or unregistered generated modules.
- The boot chain `host/load/boot/w/*` waits for the final build (Josh, 31 Oct): finish everything else first.
- Machine: 32 GB, 10 cores, 5 compile slots via `~/leanslot.sh` (1 while the compressor holds 11 GB or more; 3 was too many only with 6 GB Neural Engine K modules); 8 GB cap, 24 GB exclusive retry, enforced on footprint.
  Keep `/System/Volumes/Data` above 110 GiB free.
- Builder: `~/proofdev/tools/build.ts` compiles an import closure from the worktree, reusing a compiled file when its source
  and its dependencies' compiled files are byte-identical.
