import host.load.run.full.cached.Shapes
import host.load.run.full.cached.expected2.Join
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
theorem populated_stage_layout (contents : Nat → Nat → Nat) :
    chainLayout (stageWeights (weights (headerValues contents))) (populatedLayoutHandles 256) = Expected2.stages := by rfl
theorem populated_head_layout (contents : Nat → Nat → Nat) :
    linLayout .affineRow (weights (headerValues contents)).head = Expected2.head := by rfl

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (G : Nat → Option (RNode Int InKey))
theorem populated_step_graph (contents : Nat → Nat → Nat) (cs : List Cache) (hs : List Handles)
    (values : CacheValues M K env G cs hs)
    (compatible : List.Forall₂ CacheCompatible (stageWeights (weights (headerValues contents))) hs)
    (classes : List.Forall₂ CacheClassMatches (stageWeights (weights (headerValues contents))) cs)
    (shapes : ∀ c ∈ cs, c.operation = chars!"KVCache" →
      ∀ t, c.first = some t ∨ c.second = some t →
      ∀ v, evalR M K env G t.node = some v → v.shape = [1,4,256,256]) (time : Nat) :
    stepGraphOf (weights (headerValues contents)) hs time = stepGraph Expected2.stages Expected2.head time := by
  change stepGraph (chainLayout (stageWeights (weights (headerValues contents))) hs)
    (linLayout .affineRow (weights (headerValues contents)).head) time = _
  rw [cached_stage_layout M K env G contents cs hs 256 values compatible classes shapes,
    populated_stage_layout, populated_head_layout]
end Host.Load.Run.Full.Cached
