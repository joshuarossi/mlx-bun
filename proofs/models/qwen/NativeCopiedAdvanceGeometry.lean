import models.qwen.NativeCopiedTokenState

namespace Inference.Models.Qwen.NativeCopiedAdvanceGeometry
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n} {angle : RopeAngles.Inputs}
  (step : NativeCopiedTokenState.Step p sampling before angle)
  (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)
  (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
  (baseNonnegative : 0≤aim.base)

theorem token_bound (cursor : Nat)
    (bound : (NativeCopiedTokenRoute.final step.execution).sampler.selection.destination+4≤cursor) :
    (NativeCopiedTokenState.advance step parameters primitive samplingPrimitive angleBound supported
      aim angleError angleAccuracy baseNonnegative).index.base+4≤cursor := by
  rw [NativeCopiedTokenState.advance_address]
  exact bound

theorem cache_geometry (property : Nat → Nat → Prop)
    (bound : DecodePreservation.Protected property p.graph.stages
      (p.run before.logical.cache before.logical.token angle).2
      (NativeCopiedTokenRoute.final step.execution).sampler.memory
      (NativeCopiedTokenMemory.after step.execution step.safe)) :
    let actual := NativeCopiedTokenState.advance step parameters primitive samplingPrimitive angleBound supported
      aim angleError angleAccuracy baseNonnegative
    DecodePreservation.Protected property p.graph.stages actual.logical.cache actual.index.bytes actual.caches := bound

end Inference.Models.Qwen.NativeCopiedAdvanceGeometry
