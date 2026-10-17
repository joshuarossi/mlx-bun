import models.qwen.InitialCopiedTokenCache
import models.qwen.CapacityCopiedTokenCache

namespace Inference.Models.Qwen.CopiedTokenCacheGeometry
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  FinalProjectionSamplerSource.Execution.sampler

theorem initial {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache 0}
    {token : Fin 248320} {angle : RopeAngles.Inputs}
    (run : InitialCopiedTokenSource.Execution p sampling cache token angle)
    (head : Qwen38InitialCopiedCache.Safe run.forward)
    (sampler : InitialCopiedTokenCache.Safe run head)
    (property : Nat → Nat → Prop)
    (bound : DecodePreservation.Protected property p.graph.stages
      (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2
      (Qwen38InitialCopiedCache.hiddenBuffer run.forward).bytes
      (Qwen38InitialCopiedCache.hiddenCache run.forward)) :
    DecodePreservation.Protected property p.graph.stages
      (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2 run.final.sampler.memory
      (InitialCopiedTokenCache.after run head sampler) := by
  unfold InitialCopiedTokenCache.after InitialCopiedTokenCache.before Qwen38InitialCopiedCache.after
  apply DecodePreservation.preserves_geometry
  apply DecodePreservation.preserves_geometry
  exact bound

theorem positive {p : Pipeline} {sampling : LogSumExpRanges.Platform} {n : Nat} {cache : p.graph.Cache n}
    {token : Fin 248320} {angle : RopeAngles.Inputs}
    (run : CapacityCopiedTokenSource.Execution p sampling cache token angle)
    (head : Qwen38CapacityAttentionCache.Safe run.forward)
    (sampler : CapacityCopiedTokenCache.Safe run head)
    (property : Nat → Nat → Prop)
    (bound : DecodePreservation.Protected property p.graph.stages
      (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2
      (Qwen38CapacityAttentionCache.hiddenBuffer run.forward).bytes
      (Qwen38CapacityAttentionCache.hiddenCache run.forward)) :
    DecodePreservation.Protected property p.graph.stages
      (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2 run.final.sampler.memory
      (CapacityCopiedTokenCache.after run head sampler) := by
  unfold CapacityCopiedTokenCache.after CapacityCopiedTokenCache.before Qwen38CapacityAttentionCache.after
  apply DecodePreservation.preserves_geometry
  apply DecodePreservation.preserves_geometry
  exact bound

end Inference.Models.Qwen.CopiedTokenCacheGeometry
