import host.route.Final
import host.simgraph.world.MachRouteV
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Mach (refPrompt RefTokens routeVals Vals ForwardAtV)
open Host.Mlx.SimGraph.Ref (PrefillHolds refPromptModel)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase)
open Host.Ts.Sim.Prefill (RouteGoalW PathW PrefInvsW ICut CutConv CutStep)
open Host.Ts.Sim.Full (FF fullWorldXD)

/-! # The route's goals at the machine reference's values

The reference `refPrompt π` is defined with the route's kernels, so the agreed claim reads the graph **under the
route's kernels**: `routeVs` is `evalRR` on `ffiGraphR` (`routeVals_empty`), the decode-kernel evaluation of the
decode-only theorem having no value at a node depending on a prefill kernel. The trust boundary is unchanged. No
recorded values enter yet: a node reading a Neural Engine surface has none, so these goals cannot be met for a prompt
with a Neural Engine forward until the recorded values, tied to the run's bridge memory, are added.

`kind` names the compiled closures. A closure's value is read only where its body matches, so `kind` selects no value.

`machGxV`, `goalMV`, `goalCV`, `LoopCutV`, `RouteOutcomeV`: `machGx`, `goalM`, `goalC`, `LoopCut`, `RouteOutcome`
(`host.route.Final`) at these values. -/

variable {C : M1Max.Contract}

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet)
  (env : FfiEval.Env InKey) (π : List Nat) (kind : Nat → Option Compiled)

/-- **The route's values**: `evalRR` on `ffiGraphR`. -/
noncomputable abbrev routeVs : Vals := routeVals P KR env kind fun _ _ => none

/-- The decode loop's graph invariant at the machine reference, at the route's values. -/
abbrev machGxV (NB : Nat) (Itpl : Iter.TplInputs) : Nat → Sim.Map → St (fullWorldXD NB).F.S → CSrv → Prop :=
  liftG (fullWorldXD NB) (GxV P.toMlxContract KR.toKernelContract env (routeVs P KR env kind) Itpl
    (refPrompt P KR NE KR.inPlace net env π) π.length)

/-- The halted target's machine-level goal at `k` tokens, at the route's values. -/
abbrev goalMV (NB k : Nat) : St (fullWorldXD NB).F.S → CSrv → Prop :=
  machGoalV P KR NE KR.inPlace net env π (routeVs P KR env kind) (Wd := fullWorldXD NB) k

/-- **The halted target's goal without EOS** at `T` tokens: `goalMV` and the program's final caches hold the
reference's handles at time `|π| + T - 1`, at the route's values. -/
abbrev goalCV (NB T : Nat) (je : Host.Ts.Env) : St (fullWorldXD NB).F.S → CSrv → Prop := fun tF CF =>
  goalMV P KR NE net env π kind NB T tF CF ∧ ∃ cs out,
    Sim.ExtractSim.cachesT (tF.reFfi (Layers.toLoad tF.ffi)) je = some cs ∧
    ForwardAtV ((routeVs P KR env kind).val CF.tab ((fullWorldXD NB).toMlx tF.ffi))
      (refPrompt P KR NE KR.inPlace net env π) CF.tab (π.length + T - 1) cs out

end

/-- `LoopCut` at the route's values. -/
structure LoopCutV (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (kind : Nat → Option Compiled)
    (T : Nat) (tk : Nat → Nat) (NB : Nat) (Pw Pd : Sim.LoadP) (A : Addr) (W : Nat → Option WFrame) (fixA : List Nat)
    (I : PrefInvsW (fullWorldXD NB).F) where
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
  nP : Nat
  hpost : tk 1 ≠ 248044 → CutStep (I.ps π.length) (I.dec π.length) nP
  hdec : CutConv (I.dec π.length) (decCutFb NB A (machGxV P KR NE net env π kind NB Itpl) W Pd Fr s0 tab0 fixA
    (Sim.valL ρ T tk π.length) tk toks E0 B)
  e1 : NumV
  hE0 : E0 = [.num e1]
  he1 : ∀ t C, (I.dec π.length).Inv t C → C.val e1 = some (F64.ofNat (tk 1))
  hA : A.nxt = 17
  hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true
  hwe : W A.emit = none
  P1 : tk 1 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) []
  s1H : ∀ h, Sim.HaltStopSrc (P1 h).hs
  hG1 : ∀ h, (P1 h).Goal (goalMV P KR NE net env π kind NB 1)

/-- **The route's outcome** at the route's values: the target halts normally and emits the reference's tokens `1 … T`
with the program's final caches at the reference (`goalCV`), or at the first EOS `k` tokens `1 … k - 1` with `"stop"`
(`goalMV`); the reference's token sequence at every table; at `|π| ≤ 2` the tokens and forward results are the model's,
read at the same values. -/
def RouteOutcomeV (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights) (π : List Nat) (kind : Nat → Option Compiled) (T : Nat) (s : St LSt)
    (NB : Nat) : Prop :=
  RouteGoalW (bootStart s) (routeServer T (machTok P KR NE net env π)) (entryEnv s) chars!"emitted" T
      (machTok P KR NE net env π) (goalCV P KR NE net env π kind NB T (entryEnv s))
      (fun k => goalMV P KR NE net env π kind NB k) ∧
    (∀ tab, RefTokens P KR NE KR.inPlace net env π tab) ∧
    (π.length ≤ 2 → ∀ parameters : TokenSequenceRanges.Parameters
        (firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed),
      ∃ h : PrefillHolds P KR NE KR.inPlace net env leaves typed π,
        RouteGoalW (bootStart s) (routeServer T (machTok P KR NE net env π)) (entryEnv s) chars!"emitted" T
            (machTok P KR NE net env π)
            (fun tF CF => GFRV P.toMlxContract KR.toKernelContract env leaves typed (routeVs P KR env kind)
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h) π.length T CF.tab
              ((fullWorldXD NB).toMlx tF.ffi))
            (fun k tF CF => GFRV P.toMlxContract KR.toKernelContract env leaves typed (routeVs P KR env kind)
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h) π.length k CF.tab
              ((fullWorldXD NB).toMlx tF.ffi)) ∧
          ∀ tab j (_ : j < T) (hb : π.length + j ≤ 262144),
            machTok P KR NE net env π (j + 1) =
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h tab (π.length + j) hb).token.val)

end Host.Route
