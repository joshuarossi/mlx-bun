import host.route.cert.Row.R2.Cert
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Tpl
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Mach (RefTokens)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Route.PrefGraph

/-! # POST's rows at the shared tail's carriers

The tail is numbered once, whatever the class, so the two rows' certificates serve every prompt length. `rowToks`, `rowCr`: the
sampled token of POST's time `L + j` and the handles there. `hfw0`, `hfw1`: `FillPost.Hooks`' row hooks. -/

/-- The sampled token's carrier at POST's time `L + j`. -/
def rowToks (_ j : Nat) : Nat :=
  match j with
  | 0 => 17776
  | 1 => certAt R1.choice.cert Tpl.Ordinary.tokenNode
  | _ => certAt R2.choice.cert Tpl.Ordinary.tokenNode

/-- The handles' carriers at POST's time `L + j`. -/
def rowCr (j _ : Nat) : List (Option Nat × Option Nat) :=
  match j with
  | 0 => R1.ps
  | 1 => R1.choice.outputs
  | _ => R2.choice.outputs

variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat}

/-- **The first row's hook.** -/
theorem hfw0 (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, RefTokens P KR NE KR.inPlace net env π tab) {NB T cap nI : Nat} {tk : Nat → Nat} (hNB : 15235 ≤ NB)
    (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 224) (L : Nat) (x y : SegInst FF)
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_r1.s448 PRE_pl_r1.S448).R y PRE_pl_r1.s448
      ⟨PRE_pl_r1.S448.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node)
    (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens)
    (hm : memPost P KR NE net env π 0 rowToks (rowCr 0) L x) : memPost P KR NE net env π 1 rowToks (rowCr 1) L y :=
  hfw leaves typed hRT (sE := PRE_pl_r1.s448) (SE := PRE_pl_r1.S448) R1.cert (by decide) R1.outN R1.outsN hNB hL1 hL2
    rowToks (rowCr 0) (rowCr 1) rfl rfl rfl rfl L x y hy hle hnode hg ht hm

/-- **The second row's hook.** -/
theorem hfw1 (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, RefTokens P KR NE KR.inPlace net env π tab) {NB T cap nI : Nat} {tk : Nat → Nat} (hNB : 15235 ≤ NB)
    (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 224) (L : Nat) (x y : SegInst FF)
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_r2.s448 PRE_pl_r2.S448).R y PRE_pl_r2.s448
      ⟨PRE_pl_r2.S448.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node)
    (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens)
    (hm : memPost P KR NE net env π 1 rowToks (rowCr 1) L x) : memPost P KR NE net env π 2 rowToks (rowCr 2) L y :=
  hfw leaves typed hRT (sE := PRE_pl_r2.s448) (SE := PRE_pl_r2.S448) R2.cert (by decide) R2.outN R2.outsN hNB hL1 hL2
    rowToks (rowCr 1) (rowCr 2) rfl rfl rfl rfl L x y hy hle hnode hg ht hm

end Host.Route.Cert.Row
