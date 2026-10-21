import host.simgraph.iter.FillFwd
import host.simgraph.iter.BaseTpl
import host.sim.template.fill.Case
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl
open Inference.Models.Qwen

/-! The FILL loop case's graph step: `gstep_of` with the case's forward result and the
template's restart map, readback slot and token facts. -/

kernel_rfl FILL.read_σ : FILL.σ.node 20157 = 22538
kernel_rfl FILL.fed_σ : FILL.σ.node 22538 = certAt Fill.choice.cert Tpl.Fill.tokenNode
kernel_rfl FILL.caches_σ :
  tplCaches.map (fun p => (p.1.map FILL.σ.node, p.2.map FILL.σ.node)) = Fill.choice.outputs
kernel_rfl FILL.s1_read : (FILL.s150.ffi : LSt).mlx.items.get 20157 = some (.ref 79)
kernel_rfl FILL.s1_pread : ((FILL.s150.ffi : LSt).mlx.nodes.get 20157).isSome = true
kernel_rfl FILL.s1_tok : (FILL.s150.ffi : LSt).mlx.tokens = []
kernel_rfl FILL.s1_pout :
  ((FILL.s150.ffi : LSt).mlx.nodes.get (certAt Fill.choice.cert Tpl.Fill.tokenNode)).isSome = true
kernel_rfl FILL.s1_pouts : PresentB (FILL.s150.ffi : LSt).mlx Fill.choice.outputs = true

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The FILL case's graph step** at iteration `i`. -/
theorem FILL.gstep (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (i : Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hi : i + 3 ≤ 262144) (h253 : i % 256 = 253) :
    Sim.LoopGStep (Gx M K env leaves typed parameters tplInputs) FILL.loopCase ρ T tk toks i :=
  gstep_of M K env leaves typed parameters (P := Sim.loadP0) rfl rfl (by decide) FILL.loopCase ρ T tk toks i tplInputs _ _ htk hi
    (Fill.caseFwd M K env leaves typed parameters i hi (by unfold capOf; omega))
    FILL.read_σ FILL.fed_σ FILL.caches_σ base_s0_read base_s0_pread FILL.s1_read FILL.s1_pread
    base_s0_tok FILL.s1_tok base_h79 FILL.s1_pout (present_of_B _ _ FILL.s1_pouts)

end Host.Mlx.SimGraph.Iter
