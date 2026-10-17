import models.qwen.TokenNextPlanConstruction

-- Reached-state geometry for constructing another token on the actual heap.
-- Frontier growth is explicit and does not assert bounded physical RAM use.
namespace Inference.Models.Qwen.TokenReadyMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenBoundaryHighWater (Before)
open DecodeHighWaterGeometry (After)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

structure Locals where
  lse : ByteMemory.Bytes
  tile : Fin 243 → ByteMemory.Bytes
  finish : ByteMemory.Bytes

structure Context (p : Pipeline) where
  parameters : TokenSequenceRanges.Parameters p
  primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph
  sampling : LogSumExpRanges.Platform
  samplingPrimitive : LogSumExpRanges.Primitives sampling
  angles : TokenAutoregressive.Angles
  locals : Nat → Locals

structure Ready (p : Pipeline) (time parameterCut : Nat) where
  state : TokenAutoregressiveMemory.State p time
  parameters : TokenParameterMemory.Storage p state.index.bytes
  frontier : ResidualDeltaHighWater.Frontier
  ordered : parameterCut≤frontier.cursor
  token : Before frontier.cursor state.index.base 4
  parametersBound : parameters.Protected (Before parameterCut)
  cachesBound : DecodePreservation.Protected (Before frontier.cursor) p.graph.stages state.logical.cache state.index.bytes state.caches
  cachesAbove : DecodePreservation.Protected (After parameterCut) p.graph.stages state.logical.cache state.index.bytes state.caches
  pairwise : DecodeCacheGeometry.Pairwise p.graph.stages state.logical.cache state.index.bytes state.caches

end Inference.Models.Qwen.TokenReadyMemory
