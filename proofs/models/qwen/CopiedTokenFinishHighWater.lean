import models.qwen.CopiedTokenFinishRequest
import models.qwen.NativeCopiedPlanGeometry

namespace Inference.Models.Qwen.CopiedTokenFinishHighWater
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling FinalProjectionSamplerAllocation
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  FinalProjectionSamplerSource.Execution.sampler
  NativeCopiedTokenConstruction.step NativeCopiedTokenConstruction.after
  NativeCopiedTokenRoute.final
  CopiedAttentionOriginalTailChains.Initial.TokenBuilt CopiedAttentionOriginalTailChains.Capacity.TokenBuilt
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage

namespace Initial
open CopiedTokenFinishAllocation.Initial
variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
  (body : InitialCopiedTokenConstruction.BodyPlan embedding angle) (request : Request body.finalStorage)
  (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
  (caches : CacheBound body request)
  (tails : CopiedAttentionOriginalTailChains.Initial.TokenBuilt
    (plan body request sampling lseLocal tileLocal finishLocal caches))

theorem token_bound :
    Before (request.cursor+bytes)
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step
        (CopiedTokenFinishSafety.Initial.nativePlan body request sampling lseLocal tileLocal finishLocal caches tails)).execution).sampler.selection.destination 4 :=
  NativeCopiedPlanGeometry.Initial.token_bound
    (plan body request sampling lseLocal tileLocal finishLocal caches) tails (request.cursor+bytes)
    (FinalProjectionSamplerAllocation.token_bound request sampling lseLocal tileLocal finishLocal)

theorem caches_bound :
    let step := NativeCopiedTokenConstruction.step
      (CopiedTokenFinishSafety.Initial.nativePlan body request sampling lseLocal tileLocal finishLocal caches tails)
    DecodePreservation.Protected (Before (request.cursor+bytes)) p.graph.stages
      (p.run before.logical.cache before.logical.token angle).2
      (NativeCopiedTokenRoute.final step.execution).sampler.memory
      (NativeCopiedTokenMemory.after step.execution step.safe) :=
  NativeCopiedPlanGeometry.Initial.cache_geometry
    (plan body request sampling lseLocal tileLocal finishLocal caches) tails (Before (request.cursor+bytes))
    (TokenWorkspaceConstruction.cache_mono
      (fun _ _ below => below.trans (Nat.le_add_right request.cursor bytes)) _ _ _ _ caches)

theorem parameters_bound (parameters : original.Protected (Before request.cursor)) :
    (NativeCopiedTokenConstruction.after
      (CopiedTokenFinishSafety.Initial.nativePlan body request sampling lseLocal tileLocal finishLocal caches tails)
      (CopiedTokenFinishSafety.Initial.safe body request sampling lseLocal tileLocal finishLocal caches tails parameters)).Protected
      (Before (request.cursor+bytes)) :=
  (NativeCopiedTokenConstruction.parameters_preserved _ _ _).mpr
    (original.protected_mono (fun _ _ below => below.trans (Nat.le_add_right request.cursor bytes)) parameters)
end Initial

namespace Capacity
open CopiedTokenFinishAllocation.Capacity
variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
  (body : CapacityCopiedTokenConstruction.BodyPlan embedding angle) (request : Request body.finalStorage)
  (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
  (caches : CacheBound body request)
  (tails : CopiedAttentionOriginalTailChains.Capacity.TokenBuilt
    (plan body request sampling lseLocal tileLocal finishLocal caches))

theorem token_bound :
    Before (request.cursor+bytes)
      (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step
        (CopiedTokenFinishSafety.Capacity.nativePlan body request sampling lseLocal tileLocal finishLocal caches tails)).execution).sampler.selection.destination 4 :=
  NativeCopiedPlanGeometry.Capacity.token_bound
    (plan body request sampling lseLocal tileLocal finishLocal caches) tails (request.cursor+bytes)
    (FinalProjectionSamplerAllocation.token_bound request sampling lseLocal tileLocal finishLocal)

theorem caches_bound :
    let step := NativeCopiedTokenConstruction.step
      (CopiedTokenFinishSafety.Capacity.nativePlan body request sampling lseLocal tileLocal finishLocal caches tails)
    DecodePreservation.Protected (Before (request.cursor+bytes)) p.graph.stages
      (p.run before.logical.cache before.logical.token angle).2
      (NativeCopiedTokenRoute.final step.execution).sampler.memory
      (NativeCopiedTokenMemory.after step.execution step.safe) :=
  NativeCopiedPlanGeometry.Capacity.cache_geometry
    (plan body request sampling lseLocal tileLocal finishLocal caches) tails (Before (request.cursor+bytes))
    (TokenWorkspaceConstruction.cache_mono
      (fun _ _ below => below.trans (Nat.le_add_right request.cursor bytes)) _ _ _ _ caches)

theorem parameters_bound (parameters : original.Protected (Before request.cursor)) :
    (NativeCopiedTokenConstruction.after
      (CopiedTokenFinishSafety.Capacity.nativePlan body request sampling lseLocal tileLocal finishLocal caches tails)
      (CopiedTokenFinishSafety.Capacity.safe body request sampling lseLocal tileLocal finishLocal caches tails parameters)).Protected
      (Before (request.cursor+bytes)) :=
  (NativeCopiedTokenConstruction.parameters_preserved _ _ _).mpr
    (original.protected_mono (fun _ _ below => below.trans (Nat.le_add_right request.cursor bytes)) parameters)
end Capacity

end Inference.Models.Qwen.CopiedTokenFinishHighWater
