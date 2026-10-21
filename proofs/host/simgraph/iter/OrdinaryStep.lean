import host.simgraph.iter.OrdinaryFwd
import host.simgraph.iter.BaseTpl
import host.sim.template.ordinary.Case
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl
open Inference.Models.Qwen

/-! The ORDINARY loop case's graph step: `gstep_of` with the case's forward result and the
template's restart map, readback slot and token facts. -/

kernel_rfl ORDINARY.read_σ : ORDINARY.σ.node 20157 = 22538
kernel_rfl ORDINARY.fed_σ : ORDINARY.σ.node 22538 = certAt Ordinary.choice.cert Tpl.Ordinary.tokenNode
kernel_rfl ORDINARY.caches_σ :
  tplCaches.map (fun p => (p.1.map ORDINARY.σ.node, p.2.map ORDINARY.σ.node)) = Ordinary.choice.outputs
kernel_rfl ORDINARY.s1_read : (ORDINARY.s150.ffi : LSt).mlx.items.get 20157 = some (.ref 79)
kernel_rfl ORDINARY.s1_pread : ((ORDINARY.s150.ffi : LSt).mlx.nodes.get 20157).isSome = true
kernel_rfl ORDINARY.s1_tok : (ORDINARY.s150.ffi : LSt).mlx.tokens = []
kernel_rfl ORDINARY.s1_pout :
  ((ORDINARY.s150.ffi : LSt).mlx.nodes.get (certAt Ordinary.choice.cert Tpl.Ordinary.tokenNode)).isSome = true
kernel_rfl ORDINARY.s1_pouts : PresentB (ORDINARY.s150.ffi : LSt).mlx Ordinary.choice.outputs = true

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The ORDINARY case's graph step** at iteration `i`. -/
theorem ORDINARY.gstep (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (i : Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hi : i + 3 ≤ 262144) (h253 : i % 256 ≠ 253) (h254 : i % 256 ≠ 254) :
    Sim.LoopGStep (Gx M K env leaves typed parameters tplInputs) ORDINARY.loopCase ρ T tk toks i :=
  gstep_of M K env leaves typed parameters (P := Sim.loadP0) rfl rfl (by decide) ORDINARY.loopCase ρ T tk toks i tplInputs _ _ htk hi
    (Ordinary.caseFwd M K env leaves typed parameters i hi (by unfold capOf; omega))
    ORDINARY.read_σ ORDINARY.fed_σ ORDINARY.caches_σ base_s0_read base_s0_pread ORDINARY.s1_read ORDINARY.s1_pread
    base_s0_tok ORDINARY.s1_tok base_h79 ORDINARY.s1_pout (present_of_B _ _ ORDINARY.s1_pouts)

end Host.Mlx.SimGraph.Iter
