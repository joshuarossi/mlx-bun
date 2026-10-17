import models.qwen.NativeCopiedHighWater
import models.qwen.CheckpointNativeCopiedAdvanceGeometry

namespace Inference.Models.Qwen.CheckpointCopiedHighWaterState
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step NativeCopiedTokenConstruction.after
  NativeCopiedTokenRoute.final FinalProjectionSamplerSource.Execution.sampler

-- The next allocation receives the actual preceding heap, token and caches.
-- These fields contain geometry, not a completed next execution or plan.
structure State (p : Pipeline) (n : Nat) where
  memory : TokenAutoregressiveMemory.State p n
  parameters : TokenParameterMemory.Storage p memory.index.bytes
  frontier : Frontier
  tokenBound : Before frontier.cursor memory.index.base 4
  parametersBound : parameters.Protected (Before frontier.cursor)
  cachesBound : DecodePreservation.Protected (Before frontier.cursor) p.graph.stages memory.logical.cache memory.index.bytes memory.caches
  canonical : NativeCopiedHighWater.Canonical memory

variable {p : Pipeline} {n : Nat} (before : State p n)
  (room : before.frontier.cursor+NativeCopiedHighWater.bytes p n≤2^64)
  (dispatches : NativeCopiedHighWater.Dispatches p n)

def request : NativeCopiedHighWater.Request before.parameters before.frontier :=
  NativeCopiedHighWater.request room before.tokenBound before.parametersBound before.cachesBound before.canonical dispatches

variable (sampling : LogSumExpRanges.Platform)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

def plan : NativeCopiedTokenConstruction.Plan p sampling (RopeInputConstruction.inputs n) before.memory before.parameters :=
  NativeCopiedHighWater.plan (request before room dispatches) (RopeInputConstruction.inputs n) sampling lseLocal tileLocal finishLocal

theorem safe : NativeCopiedTokenConstruction.Safe (plan before room dispatches sampling lseLocal tileLocal finishLocal) :=
  NativeCopiedHighWater.safe (request before room dispatches) (RopeInputConstruction.inputs n) sampling lseLocal tileLocal finishLocal

variable (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling) (supported : n+1≤262144)

noncomputable def advance : State p (n+1) where
  memory := CheckpointNativeCopiedSequence.advance encoded binding selected other samplingPrimitive
    (plan before room dispatches sampling lseLocal tileLocal finishLocal) supported
  parameters := CheckpointNativeCopiedSequence.nextParameters encoded binding selected other samplingPrimitive
    (plan before room dispatches sampling lseLocal tileLocal finishLocal)
    (safe before room dispatches sampling lseLocal tileLocal finishLocal) supported
  frontier := NativeCopiedHighWater.next (request before room dispatches)
  tokenBound := CheckpointNativeCopiedAdvanceGeometry.token_bound encoded binding selected other samplingPrimitive
    (plan before room dispatches sampling lseLocal tileLocal finishLocal) supported _
    (NativeCopiedHighWater.token_bound (request before room dispatches) (RopeInputConstruction.inputs n) sampling lseLocal tileLocal finishLocal)
  parametersBound := CheckpointNativeCopiedAdvanceGeometry.parameters_geometry encoded binding selected other samplingPrimitive
    (plan before room dispatches sampling lseLocal tileLocal finishLocal) supported
    (safe before room dispatches sampling lseLocal tileLocal finishLocal) _
    (NativeCopiedHighWater.parameters_bound (request before room dispatches) (RopeInputConstruction.inputs n) sampling lseLocal tileLocal finishLocal)
  cachesBound := CheckpointNativeCopiedAdvanceGeometry.cache_geometry encoded binding selected other samplingPrimitive
    (plan before room dispatches sampling lseLocal tileLocal finishLocal) supported _
    (NativeCopiedHighWater.caches_bound (request before room dispatches) (RopeInputConstruction.inputs n) sampling lseLocal tileLocal finishLocal)
  canonical := True.intro

theorem advance_frontier :
    (advance before room dispatches sampling lseLocal tileLocal finishLocal encoded binding selected other samplingPrimitive supported).frontier.cursor=
      before.frontier.cursor+NativeCopiedHighWater.bytes p n :=
  NativeCopiedHighWater.next_eq (request before room dispatches)

theorem advance_parameters (property : Nat → Nat → Prop) :
    (advance before room dispatches sampling lseLocal tileLocal finishLocal encoded binding selected other samplingPrimitive supported).parameters.Protected property ↔
      before.parameters.Protected property :=
  NativeCopiedTokenConstruction.parameters_preserved (plan before room dispatches sampling lseLocal tileLocal finishLocal)
    (safe before room dispatches sampling lseLocal tileLocal finishLocal) property

theorem advance_frame (region : TokenParameterConstruction.Region before.parameters base size) (offset : Nat) (inside : offset<size) :
    (advance before room dispatches sampling lseLocal tileLocal finishLocal encoded binding selected other samplingPrimitive supported).memory.index.bytes (base+offset)=
      before.memory.index.bytes (base+offset) :=
  NativeCopiedTokenConstruction.frame (plan before room dispatches sampling lseLocal tileLocal finishLocal)
    (safe before room dispatches sampling lseLocal tileLocal finishLocal) region offset inside

end Inference.Models.Qwen.CheckpointCopiedHighWaterState
