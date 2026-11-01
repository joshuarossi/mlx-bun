import host.route.PostGraph
import host.route.FinalV
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Host.Mlx.SimGraph.Mach (Vals refPrompt)
open Host.Mlx.SimGraph.Ref (RSt)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF)
open Host.Ts.Sim.Compose (NTrack)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The bookkeeping the restricted pieces carry

The prompts with no Neural Engine forward read the route's values (`routeVs`, nothing recorded) and carry no Neural
Engine component. The pieces are generic in `Mem : Nat → SegInst FF → Prop` (`host.sim.compose.NTrack`), at every
length, so each predicate is guarded by `L = π.length`: the reference is the actual prompt's.

* `memCold`: from the load cut to the first forward's return, and at `L = 1` to POST's sampled cut.
* `memPre`: from the first tail's return to POST's sampled cut.
* `memExit`: the cuts both can reach (`ps`).
* `memPost`: from POST's sampled cut on.

Each keeps across a stretch (`*_keep`, the fills' `hMem`). `memCold` holds at any witness of the same target and server
(`memCold_wit`, the fills' `hWit`). -/

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (kind : Nat → Option Compiled)

/-- The route's values at every reference state. -/
noncomputable abbrev gV : RSt → Vals := fun _ => routeVs P KR env kind

/-- No Neural Engine component. -/
abbrev gAn : RSt → St FF.S → Prop := fun _ _ => True

/-- Before the first forward. -/
def memCold (L : Nat) (x : SegInst FF) : Prop :=
  L = π.length → ColdG P KR net env (gV P KR env kind) gAn x

/-- After the first tail, at the length's carriers. -/
def memPre (Cr : Nat → List (Option Nat × Option Nat)) (L : Nat) (x : SegInst FF) : Prop :=
  L = π.length → PreG P KR NE net env π (gV P KR env kind) gAn (Cr L) x

/-- At the prefill's exit, cold or after the first tail. -/
def memExit (Cr : Nat → List (Option Nat × Option Nat)) (L : Nat) (x : SegInst FF) : Prop :=
  L = π.length → (L = 1 → ColdG P KR net env (gV P KR env kind) gAn x) ∧
    (2 ≤ L → PreG P KR NE net env π (gV P KR env kind) gAn (Cr L) x)

/-- POST, the reference held through time `L + j`, at the length's carriers. -/
def memPost (j : Nat) (toks : Nat → Nat → Nat) (Cr : Nat → List (Option Nat × Option Nat)) (L : Nat)
    (x : SegInst FF) : Prop :=
  L = π.length → PostG P.toMlxContract KR.toKernelContract env (routeVs P KR env kind)
    (refPrompt P KR NE KR.inPlace net env π) L j (toks L) (Cr L) x

variable {P KR NE net env π kind}

private theorem glueOk {x y : SegInst FF} (h : NTrack x y) : GlueOk gAn x y :=
  GlueOk.of_track h fun _ _ => trivial

theorem memCold_keep (L : Nat) (x y : SegInst FF) (h : NTrack x y) (hm : memCold P KR net env π kind L x) :
    memCold P KR net env π kind L y := fun hL => (hm hL).glue (glueOk h)

theorem memCold_wit (L : Nat) (x y : SegInst FF) (ht : y.t = x.t) (hC : y.C = x.C)
    (hm : memCold P KR net env π kind L x) : memCold P KR net env π kind L y :=
  fun hL => (hm hL).of_eq ht hC

theorem memPre_keep {Cr : Nat → List (Option Nat × Option Nat)} (L : Nat) (x y : SegInst FF) (h : NTrack x y)
    (hm : memPre P KR NE net env π kind Cr L x) : memPre P KR NE net env π kind Cr L y :=
  fun hL => (hm hL).glue (glueOk h)

theorem memExit_keep {Cr : Nat → List (Option Nat × Option Nat)} (L : Nat) (x y : SegInst FF) (h : NTrack x y)
    (hm : memExit P KR NE net env π kind Cr L x) : memExit P KR NE net env π kind Cr L y :=
  fun hL => ⟨fun h1 => ((hm hL).1 h1).glue (glueOk h), fun h2 => ((hm hL).2 h2).glue (glueOk h)⟩

theorem memPost_keep {j : Nat} {toks : Nat → Nat → Nat} {Cr : Nat → List (Option Nat × Option Nat)} (L : Nat)
    (x y : SegInst FF) (h : NTrack x y) (hm : memPost P KR NE net env π kind j toks Cr L x) :
    memPost P KR NE net env π kind j toks Cr L y :=
  fun hL => (hm hL).glue h

/-- The cold stretch reaches the exit at one token. -/
theorem memExit_of_cold {Cr : Nat → List (Option Nat × Option Nat)} {L : Nat} {x : SegInst FF} (hL1 : L = 1)
    (hm : memCold P KR net env π kind L x) : memExit P KR NE net env π kind Cr L x :=
  fun hL => ⟨fun _ => hm hL, fun h2 => absurd h2 (by omega)⟩

/-- The pre-final stretch reaches the exit from two tokens. -/
theorem memExit_of_pre {Cr : Nat → List (Option Nat × Option Nat)} {L : Nat} {x : SegInst FF} (hL2 : 2 ≤ L)
    (hm : memPre P KR NE net env π kind Cr L x) : memExit P KR NE net env π kind Cr L x :=
  fun hL => ⟨fun h1 => absurd h1 (by omega), fun _ => hm hL⟩

end Host.Route.PrefGraph
