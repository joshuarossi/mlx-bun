import host.simgraph.iter.Ordinary
import host.simgraph.iter.InputsAt
import host.simgraph.iter.GStep
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter.Ordinary
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl (ORDINARY.s150 ORDINARY.S150)
open Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (CaseFwd tplInputs tplCaches InputsOk inputs_at loadedAt tensorAt cachesAt
  cachesAt_nodes capOf hpOf)

/-! The ORDINARY iteration's `forward_iter` as its `CaseFwd`: the iteration's inputs at the
images of the template start's carriers (`inputs_ok`: the template's input table is the
identity build of `tplCaches` and the token `22539`). -/

kernel_rfl inputs_ok : InputsOk choice.inputs tplCaches 22539 = true

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

theorem caseFwd (i : Nat) (hb : i + 3 ≤ 262144) (hbr : i + 3 < capOf i) :
    CaseFwd M K env leaves typed parameters tplInputs ORDINARY.s150.ffi ORDINARY.S150.tab
      (certAt choice.cert Tpl.Ordinary.tokenNode) choice.outputs i hb := by
  intro tab P Mp n y ν hR hNL hN0 hν hnum hrope hs hchain hcaps hcv hprev hpar
  have hfix : ∀ j, j < 20000 → Mp.node j = j := fun j hj => hR.mlx.nid j (by rw [hNL]; exact hj)
  obtain ⟨next, ht, hh, hc, hcap⟩ := forward_iter M K env tab leaves typed
    (hpOf M K env leaves typed parameters tab) (i + 2) (by omega) P Mp n y hR (by rw [hNL]; decide)
    (by rw [hN0]; decide) ν hν hnum hrope (loadedAt Mp.node tplCaches) (tensorAt (Mp.node 22539)) hs
    (cachesAt Mp.node choice.outputs) (capOf i) hcaps (by omega)
    (inputs_at choice.inputs tplCaches 22539 inputs_ok Mp.node hfix) (cachesAt_nodes _ _) rfl hpar hchain hcv hprev
  refine ⟨next, ht, hh, hc, ?_⟩
  have e : capOf i = capOf (i + 1) := by have := hbr; unfold capOf at this ⊢; omega
  rw [← e]
  exact hcap

end Host.Mlx.SimGraph.Iter.Ordinary
