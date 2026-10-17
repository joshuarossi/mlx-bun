import models.qwen.TokenParameterConstruction
import layers.QuantizedEmbeddingAllocation
import kernels.sampling.NormalizedArgmaxAllocation
import models.qwen.FinalProjectionAllocation

namespace Inference.Models.Qwen.TokenWorkspaceConstruction
open Contracts.Mlx Layers TokenInference Kernels.Sampling
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Lift a workspace's one separation contract to the retained cache tuple.
theorem cache_mono {first second : Nat → Nat → Prop}
    (implies : ∀ base size, first base size → second base size)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages time)
    (memory : ByteMemory.Bytes) (storage : DecodeFrame.Storage stages cache memory)
    (safe : DecodePreservation.Protected first stages cache memory storage) :
    DecodePreservation.Protected second stages cache memory storage := by
  induction stages with
  | nil => trivial
  | cons stage rest ih =>
    refine ⟨?_,ih cache.2 storage.2 safe.2⟩
    cases stage <;> exact ⟨implies _ _ safe.1.1,implies _ _ safe.1.2⟩

variable {p : Pipeline} {time : Nat} {before : TokenAutoregressiveMemory.State p time}
  {original : TokenParameterMemory.Storage p before.index.bytes}

def embeddingPlan (w : QuantizedEmbeddingAllocation.Workspace original.embedding before.index)
    (caches : DecodePreservation.Protected (MemoryRegions.Disjoint w.base QuantizedEmbeddingAllocation.bytes)
      p.graph.stages before.logical.cache before.index.bytes before.caches)
    (parameters : original.Protected (MemoryRegions.Disjoint w.base QuantizedEmbeddingAllocation.bytes)) :
    TokenParameterConstruction.EmbeddingPlan original where
  regions := w.regions
  allocation := w.allocation
  caches := cache_mono (fun _ _ region => w.live region) _ _ _ _ caches
  parameters := original.protected_mono (fun _ _ region => w.live region) parameters

variable {logits : Fin 248320 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer logits}

def samplerPlan (w : NormalizedArgmaxAllocation.Workspace source)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    TokenAutoregressiveMemoryConstruction.SamplerPlan source where
  normalizer := w.base
  normalizerAligned := by have := w.aligned; omega
  normalizerBounded := by have := w.bounded; dsimp [NormalizedArgmaxAllocation.bytes] at this; omega
  normalizerSafe := w.normalizer_source
  lseLocal := lseLocal
  partials := w.partials
  tileLocal := tileLocal
  finishLocal := finishLocal
  logitsSafe := w.partials_source
  lseSafe := w.partials_normalizer
  token := w.base+1948
  tokenAligned := by have := w.aligned; omega
  tokenBounded := by have := w.bounded; dsimp [NormalizedArgmaxAllocation.bytes] at this; omega
  tokenScores := Or.inr (by dsimp [NormalizedArgmaxAllocation.Workspace.partials]; omega)
  tokenIds := Or.inr (by dsimp [NormalizedArgmaxAllocation.Workspace.partials]; omega)
  tokenLogits := w.token_source
  tokenLse := Or.inr (by omega)

theorem sampler_pipeline (w : NormalizedArgmaxAllocation.Workspace source) (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    (samplerPlan w lseLocal tileLocal finishLocal).build sampling=w.pipeline sampling lseLocal tileLocal finishLocal := rfl

theorem sampler_protect (w : NormalizedArgmaxAllocation.Workspace source) (sampling : LogSumExpRanges.Platform)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (safe : MemoryRegions.Disjoint w.base NormalizedArgmaxAllocation.bytes base size) :
    (samplerPlan w lseLocal tileLocal finishLocal).Region base size := by
  exact w.protect sampling lseLocal tileLocal finishLocal safe

variable {angle : Kernels.Attention.RopeAngles.Inputs}
  {embedding : TokenParameterConstruction.EmbeddingPlan original}

def graphPlan (body : TokenParameterConstruction.BodyPlan embedding angle)
    (workspace : FinalProjectionAllocation.Workspace body.finalStorage) :
    TokenParameterConstruction.GraphPlan embedding angle := ⟨body,workspace.allocation⟩

theorem graph_tail_protect (body : TokenParameterConstruction.BodyPlan embedding angle)
    (workspace : FinalProjectionAllocation.Workspace body.finalStorage)
    (safe : MemoryRegions.Disjoint workspace.base FinalProjectionAllocation.bytes base size) :
    Qwen38TrellisM1MaxMemory.TailSafe (graphPlan body workspace).forward base size := by
  change MemoryRegions.Disjoint (2*(workspace.base/2)) 10240 base size ∧
    MemoryRegions.Disjoint (FinalProjectionConstruction.output body.finalStorage workspace.allocation).base 496640 base size
  rw [FinalProjectionConstruction.output_base]
  exact ⟨workspace.normalization_safe safe,workspace.output_safe safe⟩

theorem graph_cache_safe (body : TokenParameterConstruction.BodyPlan embedding angle)
    (workspace : FinalProjectionAllocation.Workspace body.finalStorage)
    (safe : DecodePreservation.Protected (MemoryRegions.Disjoint workspace.base FinalProjectionAllocation.bytes)
      p.graph.stages (DecodeChain.run p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle).2
      (graphPlan body workspace).forward.hiddenBuffer.bytes (graphPlan body workspace).forward.chainCache) :
    Qwen38TrellisM1MaxMemory.CacheSafe (graphPlan body workspace).forward :=
  cache_mono (fun _ _ region => graph_tail_protect body workspace region) _ _ _ _ safe

end Inference.Models.Qwen.TokenWorkspaceConstruction
