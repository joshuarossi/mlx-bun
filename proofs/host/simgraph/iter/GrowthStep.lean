import host.simgraph.iter.GrowthFwd
import host.simgraph.iter.BaseTpl
import host.sim.template.growth.Case
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl
open Inference.Models.Qwen

/-! The GROWTH loop case's graph step: `gstep_of` with the case's forward result and the
template's restart map, readback slot and token facts. -/

kernel_rfl GROWTH.read_σ : GROWTH.σ.node 20157 = 22538
kernel_rfl GROWTH.fed_σ : GROWTH.σ.node 22538 = certAt Growth.choice.cert Tpl.Growth.tokenNode
kernel_rfl GROWTH.caches_σ :
  tplCaches.map (fun p => (p.1.map GROWTH.σ.node, p.2.map GROWTH.σ.node)) = Growth.choice.outputs
kernel_rfl GROWTH.s1_read : (GROWTH.s153.ffi : LSt).mlx.items.get 20157 = some (.ref 79)
kernel_rfl GROWTH.s1_pread : ((GROWTH.s153.ffi : LSt).mlx.nodes.get 20157).isSome = true
kernel_rfl GROWTH.s1_tok : (GROWTH.s153.ffi : LSt).mlx.tokens = []
kernel_rfl GROWTH.s1_pout :
  ((GROWTH.s153.ffi : LSt).mlx.nodes.get (certAt Growth.choice.cert Tpl.Growth.tokenNode)).isSome = true
kernel_rfl GROWTH.s1_pouts : PresentB (GROWTH.s153.ffi : LSt).mlx Growth.choice.outputs = true

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The GROWTH case's graph step** at iteration `i`. -/
theorem GROWTH.gstep (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (i : Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hi : i + 3 ≤ 262144) (h254 : i % 256 = 254) :
    Sim.LoopGStep (Gx M K env leaves typed parameters tplInputs) GROWTH.loopCase ρ T tk toks i :=
  gstep_of M K env leaves typed parameters (P := Sim.loadP0) rfl rfl (by decide) GROWTH.loopCase ρ T tk toks i tplInputs _ _ htk hi
    (Growth.caseFwd M K env leaves typed parameters i hi (by unfold capOf; omega))
    GROWTH.read_σ GROWTH.fed_σ GROWTH.caches_σ base_s0_read base_s0_pread GROWTH.s1_read GROWTH.s1_pread
    base_s0_tok GROWTH.s1_tok base_h79 GROWTH.s1_pout (present_of_B _ _ GROWTH.s1_pouts)

end Host.Mlx.SimGraph.Iter
