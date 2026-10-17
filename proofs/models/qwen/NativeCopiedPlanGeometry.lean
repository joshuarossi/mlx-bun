import models.qwen.CopiedTokenCacheGeometry
import models.qwen.NativeCopiedTokenConstruction

namespace Inference.Models.Qwen.NativeCopiedPlanGeometry
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  FinalProjectionSamplerSource.Execution.sampler
  CopiedAttentionOriginalTailChains.Initial.TokenBuilt CopiedAttentionOriginalTailChains.Capacity.TokenBuilt

namespace Initial
variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {angle : RopeAngles.Inputs} {sampling : LogSumExpRanges.Platform}
  (plan : InitialCopiedTokenConstruction.Plan original angle sampling)
  (tails : CopiedAttentionOriginalTailChains.Initial.TokenBuilt plan)

theorem token_bound (cursor : Nat) (bound : plan.sampler.sampler.selection.destination+4≤cursor) :
    (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step
      (.initial plan tails)).execution).sampler.selection.destination+4≤cursor := bound

theorem cache_geometry (property : Nat → Nat → Prop)
    (bound : DecodePreservation.Protected property p.graph.stages
      (DecodeChain.run p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle).2
      (Qwen38InitialCopiedCache.hiddenBuffer plan.graph.forward).bytes
      (Qwen38InitialCopiedCache.hiddenCache plan.graph.forward)) :
    let step := NativeCopiedTokenConstruction.step (.initial plan tails)
    DecodePreservation.Protected property p.graph.stages
      (p.run before.logical.cache before.logical.token angle).2
      (NativeCopiedTokenRoute.final step.execution).sampler.memory
      (NativeCopiedTokenMemory.after step.execution step.safe) :=
  CopiedTokenCacheGeometry.initial plan.execution plan.headSafe plan.samplerSafe property bound
end Initial

namespace Capacity
variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {angle : RopeAngles.Inputs} {sampling : LogSumExpRanges.Platform}
  (plan : CapacityCopiedTokenConstruction.Plan original angle sampling)
  (tails : CopiedAttentionOriginalTailChains.Capacity.TokenBuilt plan)

theorem token_bound (cursor : Nat) (bound : plan.sampler.sampler.selection.destination+4≤cursor) :
    (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step
      (.positive plan tails)).execution).sampler.selection.destination+4≤cursor := bound

theorem cache_geometry (property : Nat → Nat → Prop)
    (bound : DecodePreservation.Protected property p.graph.stages
      (DecodeChain.run p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle).2
      (Qwen38CapacityAttentionCache.hiddenBuffer plan.graph.forward).bytes
      (Qwen38CapacityAttentionCache.hiddenCache plan.graph.forward)) :
    let step := NativeCopiedTokenConstruction.step (.positive plan tails)
    DecodePreservation.Protected property p.graph.stages
      (p.run before.logical.cache before.logical.token angle).2
      (NativeCopiedTokenRoute.final step.execution).sampler.memory
      (NativeCopiedTokenMemory.after step.execution step.safe) :=
  CopiedTokenCacheGeometry.positive plan.execution plan.headSafe plan.samplerSafe property bound
end Capacity

end Inference.Models.Qwen.NativeCopiedPlanGeometry
