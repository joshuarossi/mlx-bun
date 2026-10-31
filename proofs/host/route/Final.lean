import host.simgraph.world.MachRoute
import host.simgraph.mach.Schedule
import host.sim.full.World
import host.sim.full.BridgeFrame
import host.sim.full.BridgeJs
import host.mlx.KernelGpuPrefill
import host.load.RoutePrompt
import host.load.run.tail.World
import host.load.nat.Core
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Mach (refPrompt prefillHolds_two RefTokens PrefillTyped prefillTyped_of_schedule scheduleTyped
  refPrompt_tokens_total AneNetOk)
open Host.Mlx.SimGraph.Ref (PrefillHolds refPromptModel)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW HaltSegW HaltStopSrc FinalOk ExitOk FinalEOk
  LastGStepW CutGStepW DecodeItersW DecodeInvW valL)
open Host.Ts.Sim.Prefill (RouteGoalW FirstEos NoEos PathW PrefInvsW PrefStepsPW ICut CutConv CutStep tokVals loopCutW
  source_tokens_prompt_allW)
open Host.Ts.Sim.Full (FF fullWorldXD fullWorldFb Quiet bridgeOf mlxOf)

/-! # The route of a prompt: the final theorem

**The claim** (`RouteOutcome`; `route_final_framed` from the generated artifacts, `route_main` in
`host.route.Main` from the generated pieces). For a prompt `π` (`1 ≤ |π|`, tokens below `248320`) and a
budget `1 ≤ T` with `|π| + T ≤ 262144`, the full-world run of the actual source, booted with `π`, halts
normally; it emits the reference's tokens `1 … T`, or at the first EOS `k` tokens `1 … k - 1` with
`finishReason = "stop"`; its graph holds the reference's forward results at the emitted tokens' times, the
memoized readbacks' values and, without EOS, the program's final caches at the reference's last handles.

**The trust boundary** (the premises): the operation contract `C : M1Max.Contract`; MLX's native and
prefill operations `P : MlxPrefillContract C`; the GPU `G : Metal.Gpu C` with its pipelines' limits `Pg`
and the `setBytes` alignment `B` (the kernel contract `routeKernel G B Pg lseSum lseNumerator`, with the
native logsumexp's choices); the Neural Engine `NE` and its success on the loaded programs (`NE.Succeeds net`:
at every bucket of 224–2048 rows each split program of the loaded model's Neural Engine side evaluates on its
declared inputs, as the GPU assumption's launches succeed); the environment and the checkpoint (`env`,
`leaves`, `typed`); for the model-level corollary, the checkpoint's parameter ranges.

**The machine-level reference** `refPrompt π` (`host.simgraph.mach.Ref`): what the machine computes, at
every table: the prefill of `π` through the route's kernels and Neural Engine calls at their contracts'
values, then the D1 decode step's trace, each token the argmax of the lm head's logits. No model and no range
certificate enter it, so its tokens are the machine's, not the model's; `RefTokens` states the sequence (each
token a D1 graph's argmax, a vocabulary index). The Neural Engine's evaluation (`NE.eval`) is uninterpreted
and nothing fixes the surfaces' contents when the bridge starts (`init`), so the reference may depend on them:
the emitted tokens are the machine reference's evaluated at the same initial surface contents `init` as the
run, for every such `init` (`route_main`).

**The model-level corollary** (only at `|π| ≤ 2`): where the prefill's caches lie within the model's ranges
(`PrefillHolds`, proved for one and two tokens, `prefillHolds_short`), the reference's tokens and forward
results are the model's greedy decode after prefilling `π` (`refPromptModel`). For longer prompts no range
analysis bounds the MMA kernels and the Neural Engine, and the theorem claims the machine's tokens only.

**Prefill and its halting paths** use `FullRXD` and `fullWorldXD NB`, allowing the Neural Engine bridge
to activate and compiled traces to raise the band. These paths do not use that world's restart.

**The decode loop runs in the pinned world** `fullWorldFb b0 NB` (A1): the target's bridge framed (inactive
or quiet) and fixed to `b0`, the bridge the prefill leaves at its exit. The decode cut holds some such `b0`
(`decCutFb`, A1's hand-off `full_handoffTb` in POST); the decode artifacts hold for every `b0` (`LoopDecFramed`), and
the route takes them at the cut's (`route_loopFb_framed`).

**What remains.** `route_final_framed` takes the Neural Engine side `net` with `hnet` (`AneNetOk`), the booted
state `s` with `hs`, the route's artifacts `Ar` and the boot's run `hboot` as hypotheses. `route_main`
(`host.route.Main`) discharges `net`, `hnet`, `s`, `hs` and `hboot`, and builds `Ar` from the pieces:
* `net` is the Neural Engine side the boot's end state holds (`netLd`): its buckets and bridge read off
  `ldStT` (`aneNetLd_state`), its arrays' values the loaded graph's contents (`contentsLd`, the state's own
  arrays at their nodes, `tensor_live`), its surfaces `init`: the surfaces' contents when the bridge starts,
  which the FFI model leaves unspecified and which the bridge's memory at `loadDone` holds (`aneNetSt_mem`);
  `route_main` holds for every `init`. `hnet` is `aneNetLd_ok`. `contentsLd` reads the loaded graph at the
  empty prompt and readbacks (`ldStT [] []`), the same graph as at every prompt and readback suffix
  (`contentsLd_eq`, the boot's `ldContents_any`), so the arrays' values are those of the route's own end state.
* `s`, `hs` and `hboot`'s run are the boot's (`route_boot`: the booted state `bootedSt`, its full-world
  run to `ldStT`).
* `hboot`'s invariant: the prefill starts from a fixed loadDone cut (`ldCut`, `host.route.Gen`; the pieces'
  `RouteGen.hI`): the boot's template state `ldStT [] []` with the load's table, related to the target by the
  full world's relation under the route's frames `W` (none on the prompt array) at the readbacks
  `machReads T tk`, the identity map, the valuation `machVal T tk` (template variables below `2 ^ 20`), the
  prompt array framed, the Neural Engine memory before any forward (`AneFresh`). It holds at the boot's end
  (`ldCut_inv`: `Ld.rel_full` widened to `W` (`RelB.widen`), `P.S2818_eq`, `ldBridge_final`).
Its one remaining premise is `Gn` (generation, Phase C/D, marked `-- pending`): the route's generated pieces
(`RouteGen`, A4b's `route_of_piecesFramedAt`), their prefill starting from `ldCut` at the load parameters `LdParams`.
With `hnet` and `NE.Succeeds` the prefill schedule keeps the handles typed (A5's `scheduleTyped`), so the
reference is defined along the route at every table (`route_refTokens`, `refPrompt_table`), the route's
tokens are its tokens (`machTok_def`) and vocabulary indices (`machTok_le`). -/

variable {C : M1Max.Contract}

/-! ## The route's constants -/

/-- **The route's kernel contract** from the GPU assumption. -/
abbrev routeKernel (G : Metal.Gpu C) (B : KernelGpu.SetBytes) (Pg : KernelGpu.RoutePipelines G) (lseSum : Bool)
    (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction) : RouteKernelContract C :=
  KernelGpu.ofGpuRoute G B Pg lseSum lseNumerator

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet)
  (env : FfiEval.Env InKey) (π : List Nat)

/-- **The machine reference's tokens** (at the empty table): token `j` is the reference's token at
`|π| + j - 1` (token `1` the first generated one). -/
noncomputable def machTok (j : Nat) : Nat :=
  ((refPrompt P KR NE KR.inPlace net env π [] (π.length + j - 1)).map Prod.fst).getD 0

/-- The machine reference reads the table only through the loaded weights, which do not depend on it
(`first_weights_table_eq`). -/
theorem refPrompt_table (tab : List F64) :
    refPrompt P KR NE KR.inPlace net env π tab = refPrompt P KR NE KR.inPlace net env π [] := by
  funext t
  unfold refPrompt Host.Mlx.SimGraph.Ref.prefillAt
  rw [first_weights_table_eq P.toMlxContract KR.toKernelContract env tab []]

/-- **The route's tokens are the reference's** at every table: token `j + 1` at `|π| + j`. -/
theorem machTok_def (hR : RefTokens P KR NE KR.inPlace net env π []) (hπ : 1 ≤ π.length) (tab : List F64)
    (j : Nat) : ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (machTok P KR NE net env π (j + 1), hs) := by
  obtain ⟨tok, hs, tok', hs', -, h1, -⟩ := hR.2 (π.length - 1 + j) (by omega)
  rw [show π.length - 1 + j + 1 = π.length + j by omega] at h1
  refine ⟨hs', ?_⟩
  unfold machTok
  rw [refPrompt_table P KR NE net env π tab, show π.length + (j + 1) - 1 = π.length + j by omega, h1]
  rfl

/-- **The route's tokens are vocabulary indices**: token `j ≥ 1` a step's argmax (`RefTokens`), token `0`
the prompt's last (`hlt`). -/
theorem machTok_le (hR : RefTokens P KR NE KR.inPlace net env π []) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320)
    (j : Nat) : machTok P KR NE net env π j ≤ 248319 := by
  unfold machTok
  rcases Nat.eq_zero_or_pos j with rfl | hj
  · have hm : π.getD (π.length - 1) 0 < 248320 :=
      hlt _ (by
        rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega : π.length - 1 < π.length), Option.getD_some]
        exact List.getElem_mem _)
    rw [Nat.add_zero, hR.1]
    rcases Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π [] with _ | s
    · simp
    · simp only [Option.map_some, Option.getD_some]
      omega
  · obtain ⟨tok, hs, tok', hs', -, h1, hlt', -⟩ := hR.2 (π.length - 1 + (j - 1)) (by omega)
    rw [show π.length + j - 1 = π.length - 1 + (j - 1) + 1 by omega, h1]
    simp only [Option.map_some, Option.getD_some]
    omega

/-- The decode loop's graph invariant at the machine reference over the full world. -/
abbrev machGx (NB : Nat) (Itpl : Iter.TplInputs) : Nat → Sim.Map → St (fullWorldXD NB).F.S → CSrv → Prop :=
  liftG (fullWorldXD NB) (GxM P.toMlxContract KR.toKernelContract env Itpl (refPrompt P KR NE KR.inPlace net env π)
    π.length)

/-- The halted target's machine-level goal at `k` tokens over the full world. -/
abbrev goalM (NB k : Nat) : St (fullWorldXD NB).F.S → CSrv → Prop :=
  machGoal P KR NE KR.inPlace net env π (Wd := fullWorldXD NB) k

/-- **The halted target's goal without EOS** at `T` tokens: `goalM` and the program's final caches (the
`cache` binding's tensors) hold the reference's handles at time `|π| + T - 1` (`GFC` at the machine
reference). -/
abbrev goalC (NB T : Nat) (je : Host.Ts.Env) : St (fullWorldXD NB).F.S → CSrv → Prop := fun tF CF =>
  goalM P KR NE net env π NB T tF CF ∧ ∃ cs out, Sim.ExtractSim.cachesT (tF.reFfi (Layers.toLoad tF.ffi)) je = some cs ∧
    Mach.ForwardAtM P.toMlxContract KR.toKernelContract env (refPrompt P KR NE KR.inPlace net env π) CF.tab
      (π.length + T - 1) cs out (Iter.Gr CF.tab ((fullWorldXD NB).toMlx tF.ffi))

end

/-- The table's valuation: the budget `T` and the route's tokens. -/
def machVal (T : Nat) (tk : Nat → Nat) : Nat → F64 := fun j => if j = 0 then F64.ofNat T else F64.ofNat (tk j)

/-- The native readbacks after the first two (read through the table's symbols): tokens `3 … T`. -/
def machReads (T : Nat) (tk : Nat → Nat) : List NumV := (List.range (T - 2)).map fun j => .lit (F64.ofNat (tk (j + 3)))

/-- **The route's native world**: `Decode.world` with the route's readbacks. -/
def routeWorld (T : Nat) (tk : Nat → Nat) : LSt := Host.Load.Run.Tail.worldTail (machReads T tk)

/-- **The route's server**: the load's table at the budget and tokens. -/
def routeServer (T : Nat) (tk : Nat → Nat) : CSrv := ⟨Decode.tab.map (SymE.eval (machVal T tk))⟩

/-- **The full-world start** of a booted state: the layers' initial states. -/
def bootStart (s : St LSt) : St FF.S := s.reFfi (Layers.start ⟨s.ffi, FfiAne.St.empty⟩)

/-! ## The generated artifacts -/

/-- A conversion preserves the target invariant while changing its symbolic witness. -/
theorem cutConv_inv {I J : ICut FF} (h : CutConv I J) {t : St FF.S} {C : CSrv}
    (hi : I.Inv t C) : J.Inv t C := by
  obtain ⟨x, ht, hC, hr, hb⟩ := hi
  obtain ⟨y, hyt, hyC, hyr, hyb⟩ := h x hr hb
  exact ⟨y, hyt.trans ht, hyC.trans hC, hyr, hyb⟩

/-- **The decode cut over the pinned worlds**: `loopCutW`'s start, table and bookkeeping, its relation at
some pinned bridge `b0`, inactive or quiet, of the full world with the target's bridge framed and pinned
(`fullWorldFb b0 NB`). The bridge is the prefill's at its exit (A1's `full_handoffTb`); decode keeps it. -/
def decCutFb (NB : Nat) (A : Addr) (Gx : Nat → Sim.Map → St FF.S → CSrv → Prop) (W : Nat → Option WFrame)
    (Pd : Sim.LoadP) (Fr : LoopFramesA A) (s0 : St FF.S) (tab0 : List SymE) (fixA : List Nat) (V : Sim.LoopVals)
    (tk : Nat → Nat) (toks : List NumV) (E0 : List Val) (B : LoopBase) : Host.Ts.Sim.Prefill.ICut FF where
  s0 := s0
  tab0 := tab0
  R := fun x s S => ∃ b0 : Host.Mlx.FfiAne.St,
    (b0.active = false ∨ Quiet x.M (mlxOf s.ffi) (mlxOf x.t.ffi) b0) ∧
      (loopCutW (fullWorldFb b0 NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).R x s S
  B := (loopCutW (fullWorldXD NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).B

/-- At the decode cut, some pinned bridge's cut invariant. -/
theorem decCutFb_inv {NB : Nat} {A : Addr} {Gx : Nat → Sim.Map → St FF.S → CSrv → Prop} {W : Nat → Option WFrame}
    {Pd : Sim.LoadP} {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {V : Sim.LoopVals}
    {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {t : St FF.S} {C : CSrv}
    (h : (decCutFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).Inv t C) :
    ∃ b0, (loopCutW (fullWorldFb b0 NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).Inv t C :=
  let ⟨x, ht, hC, ⟨b0, _, hR⟩, hB⟩ := h
  ⟨b0, x, ht, hC, hR, hB⟩

/-- **The decode loop's generated artifacts at a budget `T ≥ 3`, independent of the pinned bridge**
(pending: generation, Phase C/D; assembled by A4b's `route_of_piecesFramedAt`): the regenerated decode template's
constants, POST to the decode cut over the pinned worlds (`decCutFb`, at the decode load parameters `Pd`)
and its prefix token, the token-1 EOS path from the prefill's exit (over `fullWorldXD NB`). -/
structure LoopCut (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)
    (NB : Nat) (Pw Pd : Sim.LoadP) (A : Addr) (W : Nat → Option WFrame) (fixA : List Nat)
    (I : PrefInvsW (fullWorldXD NB).F) where
  -- the regenerated decode template
  Fr : LoopFramesA A
  s0 : St FF.S
  tab0 : List SymE
  Itpl : Iter.TplInputs
  ρ : Nat → F64
  toks : List NumV
  E0 : List Val
  B : LoopBase
  ΔJ : Nat
  ΔH : Nat
  ΔN : Nat
  -- POST and the decode cut
  nP : Nat
  hpost : tk 1 ≠ 248044 → CutStep (I.ps π.length) (I.dec π.length) nP
  hdec : CutConv (I.dec π.length) (decCutFb NB A (machGx P KR NE net env π NB Itpl) W Pd Fr s0 tab0 fixA
    (valL ρ T tk π.length) tk toks E0 B)
  e1 : NumV
  hE0 : E0 = [.num e1]
  he1 : ∀ t C, (I.dec π.length).Inv t C → C.val e1 = some (F64.ofNat (tk 1))
  hA : A.nxt = 17
  hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true
  hwe : W A.emit = none
  -- the token-1 EOS path from the prefill's exit
  P1 : tk 1 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) []
  s1H : ∀ h, HaltStopSrc (P1 h).hs
  hG1 : ∀ h, (P1 h).Goal (goalM P KR NE net env π NB 1)

/-! ## The model-level premise at `|π| ≤ 2` -/

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet)
  (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

/-- **At one token the premise holds** for every token: the prefill is empty, the empty caches hold the
initial state. -/
theorem prefillHolds_single (a : Nat) : PrefillHolds P KR NE KR.inPlace net env leaves typed [a] :=
  fun _ => ⟨TokenAutoregressive.initial _ promptToken, ⟨initialHandles, net.surfaces, []⟩, rfl, initialChainHolds _⟩

/-- **The model-level premise at `|π| ≤ 2`** (`prefillHolds_single`, `prefillHolds_two`). -/
theorem prefillHolds_short (parameters : TokenSequenceRanges.Parameters
      (firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed)) {π : List Nat} (hπ : 1 ≤ π.length) (hL : π.length ≤ 2) (hlt : ∀ t ∈ π, t < 248320) :
    PrefillHolds P KR NE KR.inPlace net env leaves typed π := by
  match π, hπ, hL with
  | [a], _, _ => exact prefillHolds_single P KR NE net env leaves typed a
  | [a, b], _, _ => exact prefillHolds_two P KR NE KR.inPlace net env leaves typed parameters a b (hlt a (by simp))
  | [], h, _ => exact absurd h (by simp)
  | _ :: _ :: _ :: _, _, h => exact absurd h (by simp)

end

/-! ## The machine reference along the route -/

/-- **The machine reference's token sequence** at every table (A5's `refPrompt_tokens_total` under the GPU
assumption): the prefill is typed from the schedule's multi-row steps (`prefillTyped_of_schedule`, A5's
`scheduleTyped` under the Neural Engine's success and the loaded model's Neural Engine side). -/
theorem route_refTokens (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) {π : List Nat} (hπ : 1 ≤ π.length)
    (hL : π.length ≤ 349525) (hlt : ∀ t ∈ π, t < 248320) (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G B Pg lseSum lseNumerator).toKernelContract env tab)))) (tab : List F64) :
    RefTokens P (routeKernel G B Pg lseSum lseNumerator) NE (routeKernel G B Pg lseSum lseNumerator).inPlace net env π
      tab := by
  have hpre : PrefillTyped P (routeKernel G B Pg lseSum lseNumerator) NE (routeKernel G B Pg lseSum lseNumerator).inPlace
      net env π :=
    prefillTyped_of_schedule P _ NE _ net env π Pg rfl leaves typed hπ hL
      (scheduleTyped P _ NE net env π leaves typed hL hlt hNE hnet)
  exact refPrompt_tokens_total P _ NE _ net env π Pg rfl leaves typed hpre tab

/-! ## The final theorem -/

/-- **The route's outcome** at the full world `fullWorldXD NB` from the booted state `s`: the target halts
normally and emits the reference's tokens `1 … T` with the program's final caches at the reference
(`goalC`), or at the first EOS `k` tokens `1 … k - 1` with `"stop"` (`goalM`); the reference's token
sequence at every table (`RefTokens`); at `|π| ≤ 2` the tokens and forward results are the model's. -/
def RouteOutcome (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights) (π : List Nat) (T : Nat) (s : St LSt) (NB : Nat) : Prop :=
  RouteGoalW (bootStart s) (routeServer T (machTok P KR NE net env π)) (entryEnv s) chars!"emitted" T
      (machTok P KR NE net env π) (goalC P KR NE net env π NB T (entryEnv s))
      (fun k => goalM P KR NE net env π NB k) ∧
    (∀ tab, RefTokens P KR NE KR.inPlace net env π tab) ∧
    (π.length ≤ 2 → ∀ parameters : TokenSequenceRanges.Parameters
        (firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed),
      ∃ h : PrefillHolds P KR NE KR.inPlace net env leaves typed π,
        RouteGoalW (bootStart s) (routeServer T (machTok P KR NE net env π)) (entryEnv s) chars!"emitted" T
            (machTok P KR NE net env π)
            (fun tF CF => GFR P.toMlxContract KR.toKernelContract env leaves typed
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h) π.length T CF.tab
              ((fullWorldXD NB).toMlx tF.ffi))
            (fun k tF CF => GFR P.toMlxContract KR.toKernelContract env leaves typed
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h) π.length k CF.tab
              ((fullWorldXD NB).toMlx tF.ffi)) ∧
          ∀ tab j (_ : j < T) (hb : π.length + j ≤ 262144),
            machTok P KR NE net env π (j + 1) =
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h tab (π.length + j) hb).token.val)

end Host.Route
