import models.qwen.FinalProjectionSamplerAllocation
import models.qwen.InitialCopiedTokenConstruction
import models.qwen.CapacityCopiedTokenConstruction
import models.qwen.TokenWorkspaceConstruction

namespace Inference.Models.Qwen.CopiedTokenFinishAllocation
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling FinalProjectionSamplerAllocation
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage

namespace Initial
variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
  (body : InitialCopiedTokenConstruction.BodyPlan embedding angle) (request : Request body.finalStorage)

def graph : InitialCopiedTokenConstruction.GraphPlan embedding angle := ⟨body,allocation request⟩

def CacheBound : Prop := DecodePreservation.Protected (Before request.cursor) p.graph.stages
  (DecodeChain.run p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle).2
  (Qwen38InitialCopiedCache.hiddenBuffer (graph body request).forward).bytes
  (Qwen38InitialCopiedCache.hiddenCache (graph body request).forward)

theorem headSafe (caches : CacheBound body request) : Qwen38InitialCopiedCache.Safe (graph body request).forward :=
  TokenWorkspaceConstruction.cache_mono
    (fun _ _ below => ⟨normalization_safe request below,projection_safe request below⟩) _ _ _ _ caches

variable (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

def sampler : FinalProjectionSamplerSource.Execution (graph body request).forward.finalParameters
    (graph body request).forward.allocation sampling := execution request sampling lseLocal tileLocal finishLocal

theorem samplerSafe (caches : CacheBound body request) :
    InitialCopiedTokenCache.Safe ((graph body request).execution (sampler body request sampling lseLocal tileLocal finishLocal))
      (headSafe body request caches) := by
  unfold InitialCopiedTokenCache.Safe InitialCopiedTokenCache.before Qwen38InitialCopiedCache.after
  apply DecodePreservation.preserves_geometry
  exact TokenWorkspaceConstruction.cache_mono (fun _ _ below => sampler_safe request below) _ _ _ _ caches

def plan (caches : CacheBound body request) : InitialCopiedTokenConstruction.Plan original angle sampling where
  embedding := embedding
  graph := graph body request
  headSafe := headSafe body request caches
  sampler := sampler body request sampling lseLocal tileLocal finishLocal
  samplerSafe := samplerSafe body request sampling lseLocal tileLocal finishLocal caches

theorem token_address (caches : CacheBound body request) :
    (plan body request sampling lseLocal tileLocal finishLocal caches).sampler.sampler.selection.destination=request.cursor+508828 :=
  token_base request sampling lseLocal tileLocal finishLocal
end Initial

namespace Capacity
variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
  (body : CapacityCopiedTokenConstruction.BodyPlan embedding angle) (request : Request body.finalStorage)

def graph : CapacityCopiedTokenConstruction.GraphPlan embedding angle := ⟨body,allocation request⟩

def CacheBound : Prop := DecodePreservation.Protected (Before request.cursor) p.graph.stages
  (DecodeChain.run p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle).2
  (Qwen38CapacityAttentionCache.hiddenBuffer (graph body request).forward).bytes
  (Qwen38CapacityAttentionCache.hiddenCache (graph body request).forward)

theorem headSafe (caches : CacheBound body request) : Qwen38CapacityAttentionCache.Safe (graph body request).forward :=
  TokenWorkspaceConstruction.cache_mono
    (fun _ _ below => ⟨normalization_safe request below,projection_safe request below⟩) _ _ _ _ caches

variable (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

def sampler : FinalProjectionSamplerSource.Execution (graph body request).forward.finalParameters
    (graph body request).forward.allocation sampling := execution request sampling lseLocal tileLocal finishLocal

theorem samplerSafe (caches : CacheBound body request) :
    CapacityCopiedTokenCache.Safe ((graph body request).execution (sampler body request sampling lseLocal tileLocal finishLocal))
      (headSafe body request caches) := by
  unfold CapacityCopiedTokenCache.Safe CapacityCopiedTokenCache.before Qwen38CapacityAttentionCache.after
  apply DecodePreservation.preserves_geometry
  exact TokenWorkspaceConstruction.cache_mono (fun _ _ below => sampler_safe request below) _ _ _ _ caches

def plan (caches : CacheBound body request) : CapacityCopiedTokenConstruction.Plan original angle sampling where
  embedding := embedding
  graph := graph body request
  headSafe := headSafe body request caches
  sampler := sampler body request sampling lseLocal tileLocal finishLocal
  samplerSafe := samplerSafe body request sampling lseLocal tileLocal finishLocal caches

theorem token_address (caches : CacheBound body request) :
    (plan body request sampling lseLocal tileLocal finishLocal caches).sampler.sampler.selection.destination=request.cursor+508828 :=
  token_base request sampling lseLocal tileLocal finishLocal
end Capacity

end Inference.Models.Qwen.CopiedTokenFinishAllocation
