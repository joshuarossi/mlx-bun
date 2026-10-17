import models.qwen.NativeCopiedHighWater
namespace Inference.Models.Qwen.NativeCopiedHighWaterFrame
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  FinalProjectionSamplerSource.Execution.sampler
  CopiedAttentionOriginalTailChains.Initial.TokenBuilt CopiedAttentionOriginalTailChains.Capacity.TokenBuilt
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage
  InitialCopiedTokenConstruction.BodyPlan.hiddenBuffer CapacityCopiedTokenConstruction.BodyPlan.hiddenBuffer

section Embedding
variable {p : Pipeline} {time : Nat} {before : TokenAutoregressiveMemory.State p time}
  {original : TokenParameterMemory.Storage p before.index.bytes} {cursor base size : Nat}

theorem embedding_frame (aligned : cursor%16=0) (room : cursor+13120≤2^64)
    (token : TokenBoundaryHighWater.Before cursor before.index.base 4)
    (parameters : original.Protected (TokenBoundaryHighWater.Before cursor))
    (caches : DecodePreservation.Protected (TokenBoundaryHighWater.Before cursor) p.graph.stages before.logical.cache before.index.bytes before.caches)
    (below : Before cursor base size) (offset : Nat) (bound : offset<size) :
    (TokenBoundaryHighWater.embeddingPlan aligned room token parameters caches).entry.source.bytes (base+offset)=
      before.index.bytes (base+offset) :=
  (TokenBoundaryHighWater.embeddingPlan aligned room token parameters caches).entry.frame
    ((TokenBoundaryHighWater.embeddingWorkspace aligned room token parameters).live (Or.inr below)) offset bound
end Embedding

namespace Initial
section Generic
variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes} {angle : RopeAngles.Inputs}
  {sampling : LogSumExpRanges.Platform} {base size : Nat}

private theorem native_region (plan : InitialCopiedTokenConstruction.Plan original angle sampling)
    (tails : CopiedAttentionOriginalTailChains.Initial.TokenBuilt plan)
    (safe : InitialCopiedTokenParameterFrame.Safe plan.execution base size) :
    NativeCopiedTokenParameters.RegionSafe (NativeCopiedTokenConstruction.step (.initial plan tails)).execution base size := safe

private theorem allocation_region {embedding : TokenParameterConstruction.EmbeddingPlan original}
    (body : InitialCopiedTokenConstruction.BodyPlan embedding angle)
    (request : FinalProjectionSamplerAllocation.Request body.finalStorage)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (caches : CopiedTokenFinishAllocation.Initial.CacheBound body request)
    (entry : embedding.regions.Live base size)
    (chain : InitialCopiedTokenConstruction.ChainSafe embedding body.chain base size)
    (below : FinalProjectionSamplerAllocation.Before request.cursor base size) :
    InitialCopiedTokenParameterFrame.Safe (CopiedTokenFinishAllocation.Initial.plan body request sampling lseLocal tileLocal finishLocal caches).execution base size :=
  ⟨entry,chain,FinalProjectionSamplerAllocation.normalization_safe request below,
    FinalProjectionSamplerAllocation.projection_safe request below,FinalProjectionSamplerAllocation.sampler_safe request below⟩
end Generic

attribute [local irreducible] NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.final
variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes} {frontier : Frontier}
  (r : InitialCopiedTokenHighWater.Request original frontier) (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

theorem region_safe {base size : Nat} (below : Before frontier.cursor base size) :
    NativeCopiedTokenParameters.RegionSafe (NativeCopiedTokenConstruction.step
      (InitialCopiedTokenHighWater.nativePlan r angle sampling lseLocal tileLocal finishLocal)).execution base size := by
  have startBelow : Before (InitialCopiedTokenHighWater.start r).cursor base size := below.trans (Nat.le_add_right _ _)
  have finishBelow : FinalProjectionSamplerAllocation.Before (InitialCopiedTokenHighWater.request r angle).cursor base size := by
    change base+size≤frontier.cursor+13120+InitialCopiedWorkspace.bytes p.graph.stages
    dsimp [Before] at below
    omega
  have room : frontier.cursor+13120≤2^64 := by
    have room := r.room
    unfold InitialCopiedTokenHighWater.bytes at room
    omega
  have entry : (InitialCopiedTokenHighWater.embedding r).regions.Live base size :=
    (TokenBoundaryHighWater.embeddingWorkspace frontier.aligned room r.token r.parameters).live (Or.inr below)
  have chain := (InitialCopiedTokenHighWater.chainResult r angle).safeBefore base size startBelow
  have all := allocation_region (sampling:=sampling) (InitialCopiedTokenHighWater.body r angle) (InitialCopiedTokenHighWater.request r angle) lseLocal tileLocal finishLocal
    (by exact (InitialCopiedTokenHighWater.chainResult r angle).cachesBound) entry chain finishBelow
  exact native_region (InitialCopiedTokenHighWater.plan r angle sampling lseLocal tileLocal finishLocal)
    (InitialCopiedTokenHighWater.tails r angle sampling lseLocal tileLocal finishLocal) all
end Initial

namespace Capacity
section Generic
variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes} {angle : RopeAngles.Inputs}
  {sampling : LogSumExpRanges.Platform} {base size : Nat}

private theorem native_region (plan : CapacityCopiedTokenConstruction.Plan original angle sampling)
    (tails : CopiedAttentionOriginalTailChains.Capacity.TokenBuilt plan)
    (safe : CapacityCopiedTokenParameterFrame.Safe plan.execution base size) :
    NativeCopiedTokenParameters.RegionSafe (NativeCopiedTokenConstruction.step (.positive plan tails)).execution base size := safe

private theorem allocation_region {embedding : TokenParameterConstruction.EmbeddingPlan original}
    (body : CapacityCopiedTokenConstruction.BodyPlan embedding angle)
    (request : FinalProjectionSamplerAllocation.Request body.finalStorage)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (caches : CopiedTokenFinishAllocation.Capacity.CacheBound body request)
    (entry : embedding.regions.Live base size)
    (chain : CapacityCopiedTokenConstruction.ChainSafe embedding body.chain base size)
    (below : FinalProjectionSamplerAllocation.Before request.cursor base size) :
    CapacityCopiedTokenParameterFrame.Safe (CopiedTokenFinishAllocation.Capacity.plan body request sampling lseLocal tileLocal finishLocal caches).execution base size :=
  ⟨entry,chain,FinalProjectionSamplerAllocation.normalization_safe request below,
    FinalProjectionSamplerAllocation.projection_safe request below,FinalProjectionSamplerAllocation.sampler_safe request below⟩
end Generic

attribute [local irreducible] NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.final
variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes} {frontier : Frontier}
  (r : CapacityCopiedTokenHighWater.Request original frontier) (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

theorem region_safe {base size : Nat} (below : Before frontier.cursor base size) :
    NativeCopiedTokenParameters.RegionSafe (NativeCopiedTokenConstruction.step
      (CapacityCopiedTokenHighWater.nativePlan r angle sampling lseLocal tileLocal finishLocal)).execution base size := by
  have startBelow : Before (CapacityCopiedTokenHighWater.start r).cursor base size := below.trans (Nat.le_add_right _ _)
  have finishBelow : FinalProjectionSamplerAllocation.Before (CapacityCopiedTokenHighWater.request r angle).cursor base size := by
    change base+size≤frontier.cursor+13120+CapacityCopiedWorkspace.bytes (n+1) p.graph.stages
    dsimp [Before] at below
    omega
  have room : frontier.cursor+13120≤2^64 := by
    have room := r.room
    unfold CapacityCopiedTokenHighWater.bytes at room
    omega
  have entry : (CapacityCopiedTokenHighWater.embedding r).regions.Live base size :=
    (TokenBoundaryHighWater.embeddingWorkspace frontier.aligned room r.token r.parameters).live (Or.inr below)
  have chain := (CapacityCopiedTokenHighWater.chainResult r angle).safeBefore base size startBelow
  have all := allocation_region (sampling:=sampling) (CapacityCopiedTokenHighWater.body r angle) (CapacityCopiedTokenHighWater.request r angle) lseLocal tileLocal finishLocal
    (by exact (CapacityCopiedTokenHighWater.chainResult r angle).cachesBound) entry chain finishBelow
  exact native_region (CapacityCopiedTokenHighWater.plan r angle sampling lseLocal tileLocal finishLocal)
    (CapacityCopiedTokenHighWater.tails r angle sampling lseLocal tileLocal finishLocal) all
end Capacity

attribute [local irreducible] NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.final
variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p n}
  {original : TokenParameterMemory.Storage p before.index.bytes} {frontier : Frontier}
  (r : NativeCopiedHighWater.Request original frontier)
  (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

theorem region_safe {base size : Nat} (below : Before frontier.cursor base size) :
    NativeCopiedTokenParameters.RegionSafe (NativeCopiedTokenConstruction.step
      (NativeCopiedHighWater.plan r angle sampling lseLocal tileLocal finishLocal)).execution base size := by
  cases n with
  | zero => exact Initial.region_safe r angle sampling lseLocal tileLocal finishLocal below
  | succ n => exact Capacity.region_safe r angle sampling lseLocal tileLocal finishLocal below

-- Every span below the starting frontier survives the actual sampler heap.
-- No membership in the original parameter bundle is required.
theorem frame {base size : Nat} (below : Before frontier.cursor base size) (offset : Nat) (bound : offset<size) :
    (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step
      (NativeCopiedHighWater.plan r angle sampling lseLocal tileLocal finishLocal)).execution).sampler.memory (base+offset)=
      before.index.bytes (base+offset) :=
  NativeCopiedTokenParameters.step_frame _ (region_safe r angle sampling lseLocal tileLocal finishLocal below) offset bound
end Inference.Models.Qwen.NativeCopiedHighWaterFrame
