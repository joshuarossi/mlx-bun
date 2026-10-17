import models.qwen.CopiedTokenFinishAllocation
import models.qwen.NativeCopiedTokenConstruction
import models.qwen.DecodeParameterCombine

namespace Inference.Models.Qwen.CopiedTokenFinishSafety
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling FinalProjectionSamplerAllocation
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  CopiedAttentionOriginalTailChains.Initial.TokenBuilt CopiedAttentionOriginalTailChains.Capacity.TokenBuilt
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage

private theorem combine {p : Pipeline} {memory : ByteMemory.Bytes} {first second third : Nat → Nat → Prop}
    (join : ∀ base size, first base size → second base size → third base size)
    (storage : TokenParameterMemory.Storage p memory)
    (a : storage.Protected first) (b : storage.Protected second) : storage.Protected third :=
  ⟨join _ _ a.1 b.1,join _ _ a.2.1 b.2.1,join _ _ a.2.2.1 b.2.2.1,
    DecodeParameterCombine.all join p.graph.stages storage.graph.stages a.2.2.2.1 b.2.2.2.1,
    join _ _ a.2.2.2.2.1 b.2.2.2.2.1,
    DecodeParameterCombine.affine join p.graph.output storage.graph.output a.2.2.2.2.2 b.2.2.2.2.2⟩

namespace Initial
open CopiedTokenFinishAllocation.Initial
variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
  (body : InitialCopiedTokenConstruction.BodyPlan embedding angle) (request : Request body.finalStorage)
  (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
  (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
  (caches : CacheBound body request)

private theorem region_safe
    (entry : embedding.regions.Live base size) (chain : InitialCopiedTokenConstruction.ChainSafe embedding body.chain base size)
    (below : Before request.cursor base size) :
    InitialCopiedTokenParameterFrame.Safe (plan body request sampling lseLocal tileLocal finishLocal caches).execution base size :=
  ⟨entry,chain,normalization_safe request below,projection_safe request below,sampler_safe request below⟩

variable (tails : CopiedAttentionOriginalTailChains.Initial.TokenBuilt
  (plan body request sampling lseLocal tileLocal finishLocal caches))

def nativePlan : NativeCopiedTokenConstruction.Plan p sampling angle before original :=
  .initial (plan body request sampling lseLocal tileLocal finishLocal caches) tails

theorem safe (parameters : original.Protected (Before request.cursor)) :
    NativeCopiedTokenConstruction.Safe (nativePlan body request sampling lseLocal tileLocal finishLocal caches tails) := by
  have kept : original.Protected (fun base size => embedding.regions.Live base size ∧
      InitialCopiedTokenConstruction.ChainSafe embedding body.chain base size) :=
    combine (fun _ _ first second => ⟨first,second⟩) original embedding.parameters
      ((embedding.afterEmbedding_protected _).mp body.parameters)
  exact combine (fun base size (live : embedding.regions.Live base size ∧
      InitialCopiedTokenConstruction.ChainSafe embedding body.chain base size) below =>
    region_safe body request sampling lseLocal tileLocal finishLocal caches live.1 live.2 below) original kept parameters
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

private theorem region_safe
    (entry : embedding.regions.Live base size) (chain : CapacityCopiedTokenConstruction.ChainSafe embedding body.chain base size)
    (below : Before request.cursor base size) :
    CapacityCopiedTokenParameterFrame.Safe (plan body request sampling lseLocal tileLocal finishLocal caches).execution base size :=
  ⟨entry,chain,normalization_safe request below,projection_safe request below,sampler_safe request below⟩

variable (tails : CopiedAttentionOriginalTailChains.Capacity.TokenBuilt
  (plan body request sampling lseLocal tileLocal finishLocal caches))

def nativePlan : NativeCopiedTokenConstruction.Plan p sampling angle before original :=
  .positive (plan body request sampling lseLocal tileLocal finishLocal caches) tails

theorem safe (parameters : original.Protected (Before request.cursor)) :
    NativeCopiedTokenConstruction.Safe (nativePlan body request sampling lseLocal tileLocal finishLocal caches tails) := by
  have kept : original.Protected (fun base size => embedding.regions.Live base size ∧
      CapacityCopiedTokenConstruction.ChainSafe embedding body.chain base size) :=
    combine (fun _ _ first second => ⟨first,second⟩) original embedding.parameters
      ((embedding.afterEmbedding_protected _).mp body.parameters)
  exact combine (fun base size (live : embedding.regions.Live base size ∧
      CapacityCopiedTokenConstruction.ChainSafe embedding body.chain base size) below =>
    region_safe body request sampling lseLocal tileLocal finishLocal caches live.1 live.2 below) original kept parameters
end Capacity

end Inference.Models.Qwen.CopiedTokenFinishSafety
