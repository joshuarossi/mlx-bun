import models.qwen.TokenWorkspaceConstruction

namespace Inference.Models.Qwen.TokenBoundaryHighWater
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

def Before (cursor base size : Nat) : Prop := base+size≤cursor

theorem fresh (inside : Before cursor base size) : MemoryRegions.Disjoint cursor count base size := Or.inr inside

theorem before_next (inside : Before cursor base size) : Before (cursor+count) base size := by unfold Before at *; omega

theorem aligned_next (aligned : cursor%16=0) (sizeAligned : count%16=0) : (cursor+count)%16=0 := by omega

def retainParameters {p : Pipeline} {memory : ByteMemory.Bytes} (original : TokenParameterMemory.Storage p memory)
    (after : ByteMemory.Bytes) (safe : original.Protected (Before cursor))
    (frame : ∀ base size, Before cursor base size → ∀ offset < size, after (base+offset)=memory (base+offset)) :
    TokenParameterMemory.Storage p after := original.reframe after (original.protected_mono frame safe)

theorem retainParameters_before {p : Pipeline} {memory : ByteMemory.Bytes} (original : TokenParameterMemory.Storage p memory)
    (after : ByteMemory.Bytes) (safe : original.Protected (Before cursor))
    (frame : ∀ base size, Before cursor base size → ∀ offset < size, after (base+offset)=memory (base+offset)) :
    (retainParameters original after safe frame).Protected (Before (cursor+count)) :=
  (original.reframe_protected _ _ _).mpr (original.protected_mono (fun _ _ inside => before_next inside) safe)

def retainCaches (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages time)
    (before after : ByteMemory.Bytes) (storage : DecodeFrame.Storage stages cache before)
    (safe : DecodePreservation.Protected (Before cursor) stages cache before storage)
    (frame : ∀ base size, Before cursor base size → ∀ offset < size, after (base+offset)=before (base+offset)) :
    DecodeFrame.Storage stages cache after := DecodePreservation.reframe (Before cursor) before after frame stages cache storage safe

theorem retainCaches_before (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages time)
    (before after : ByteMemory.Bytes) (storage : DecodeFrame.Storage stages cache before)
    (safe : DecodePreservation.Protected (Before cursor) stages cache before storage)
    (frame : ∀ base size, Before cursor base size → ∀ offset < size, after (base+offset)=before (base+offset)) :
    DecodePreservation.Protected (Before (cursor+count)) stages cache after (retainCaches stages cache before after storage safe frame) :=
  DecodePreservation.preserves_geometry (Before cursor) (Before (cursor+count)) before after frame stages cache storage safe
    (TokenWorkspaceConstruction.cache_mono (fun _ _ inside => before_next inside) _ _ _ _ safe)

variable {p : Pipeline} {time : Nat} {state : TokenAutoregressiveMemory.State p time}
  {original : TokenParameterMemory.Storage p state.index.bytes} {cursor : Nat}

def embeddingWorkspace (aligned : cursor%16=0) (room : cursor+13120≤2^64)
    (token : Before cursor state.index.base 4) (parameters : original.Protected (Before cursor)) :
    QuantizedEmbeddingAllocation.Workspace original.embedding state.index where
  base := cursor
  aligned := by omega
  bounded := room
  packedSafe := fresh parameters.1
  scalesSafe := fresh parameters.2.1
  biasesSafe := fresh parameters.2.2.1
  tokenSafe := fresh token

def embeddingPlan (aligned : cursor%16=0) (room : cursor+13120≤2^64)
    (token : Before cursor state.index.base 4) (parameters : original.Protected (Before cursor))
    (caches : DecodePreservation.Protected (Before cursor) p.graph.stages state.logical.cache state.index.bytes state.caches) :
    TokenParameterConstruction.EmbeddingPlan original :=
  TokenWorkspaceConstruction.embeddingPlan (embeddingWorkspace aligned room token parameters)
    (TokenWorkspaceConstruction.cache_mono (fun _ _ inside => fresh inside) _ _ _ _ caches)
    (original.protected_mono (fun _ _ inside => fresh inside) parameters)

theorem embedding_output (aligned : cursor%16=0) (room : cursor+13120≤2^64)
    (token : Before cursor state.index.base 4) (parameters : original.Protected (Before cursor))
    (caches : DecodePreservation.Protected (Before cursor) p.graph.stages state.logical.cache state.index.bytes state.caches) :
    let entry := (embeddingPlan aligned room token parameters caches).entry
    entry.source.base=cursor+2880 ∧ Before (cursor+13120) entry.source.base 10240 := by
  have base := (embeddingWorkspace aligned room token parameters).output_base
    (⟨original.packedShared,original.scalesShared,original.biasesShared⟩ : QuantizedEmbeddingMemory.Shared original.embedding state.index)
  have outputBase : (embeddingPlan aligned room token parameters caches).entry.source.base=cursor+2880 := base
  refine ⟨outputBase,?_⟩
  unfold Before
  rw [outputBase]

theorem embedding_parameters (aligned : cursor%16=0) (room : cursor+13120≤2^64)
    (token : Before cursor state.index.base 4) (parameters : original.Protected (Before cursor))
    (caches : DecodePreservation.Protected (Before cursor) p.graph.stages state.logical.cache state.index.bytes state.caches) :
    (embeddingPlan aligned room token parameters caches).afterEmbedding.Protected (Before (cursor+13120)) :=
  ((embeddingPlan aligned room token parameters caches).afterEmbedding_protected _).mpr
    (original.protected_mono (fun _ _ inside => before_next inside) parameters)

theorem embedding_caches (aligned : cursor%16=0) (room : cursor+13120≤2^64)
    (token : Before cursor state.index.base 4) (parameters : original.Protected (Before cursor))
    (caches : DecodePreservation.Protected (Before cursor) p.graph.stages state.logical.cache state.index.bytes state.caches) :
    let entry := (embeddingPlan aligned room token parameters caches).entry
    DecodePreservation.Protected (Before (cursor+13120)) p.graph.stages state.logical.cache entry.source.bytes entry.storage := by
  unfold TokenAutoregressiveMemoryConstruction.Entry.storage TokenAutoregressiveMemory.embeddingCaches
  apply DecodePreservation.preserves_geometry
  exact TokenWorkspaceConstruction.cache_mono (fun _ _ inside => before_next inside) _ _ _ _ caches

theorem embedding_next (aligned : cursor%16=0) : (cursor+13120)%16=0 := aligned_next aligned (by decide +kernel)

variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
  {input : Fin 5120 → ArrayStorage.BF} {storage : FinalProjectionConstruction.Storage norm projection input}

def finalWorkspace (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor storage.source.base 10240) (weight : Before cursor storage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected projection storage.outputWeights (Before cursor)) :
    FinalProjectionAllocation.Workspace storage where
  base := cursor
  aligned := by omega
  bounded := room
  sourceSafe := fresh source
  normSafe := fresh weight
  outputSafe := AffineMemoryFrames.protected_mono _ _ (fun _ _ inside => fresh inside) parameters

variable {angle : RopeAngles.Inputs} {embedding : TokenParameterConstruction.EmbeddingPlan original}

def graphPlan (body : TokenParameterConstruction.BodyPlan embedding angle)
    (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor body.finalStorage.source.base 10240) (weight : Before cursor body.finalStorage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected p.graph.output body.finalStorage.outputWeights (Before cursor)) :
    TokenParameterConstruction.GraphPlan embedding angle :=
  TokenWorkspaceConstruction.graphPlan body (finalWorkspace aligned room source weight parameters)

theorem graph_cache_safe (body : TokenParameterConstruction.BodyPlan embedding angle)
    (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor body.finalStorage.source.base 10240) (weight : Before cursor body.finalStorage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected p.graph.output body.finalStorage.outputWeights (Before cursor))
    (caches : DecodePreservation.Protected (Before cursor) p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
      (graphPlan body aligned room source weight parameters).forward.hiddenBuffer.bytes
      (graphPlan body aligned room source weight parameters).forward.chainCache) :
    Qwen38TrellisM1MaxMemory.CacheSafe (graphPlan body aligned room source weight parameters).forward :=
  TokenWorkspaceConstruction.graph_cache_safe body (finalWorkspace aligned room source weight parameters)
    (TokenWorkspaceConstruction.cache_mono (fun _ _ inside => fresh inside) _ _ _ _ caches)

set_option maxRecDepth 100000 in
private theorem final_workspace_end (w : FinalProjectionAllocation.Workspace storage) :
    w.output.base=w.base+10240 ∧ Before (w.base+506880) w.output.base 496640 :=
  ⟨w.output_base,by unfold Before; rw [w.output_base]⟩

theorem final_output (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor storage.source.base 10240) (weight : Before cursor storage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected projection storage.outputWeights (Before cursor)) :
    let output := (finalWorkspace aligned room source weight parameters).output
    output.base=cursor+10240 ∧ Before (cursor+506880) output.base 496640 := by
  exact final_workspace_end (finalWorkspace aligned room source weight parameters)

set_option maxRecDepth 100000 in
private theorem final_buffer_base (w : FinalProjectionAllocation.Workspace storage) :
    w.output.outputBuffer.base=w.output.base := by cases projection <;> rfl

set_option maxRecDepth 100000 in
theorem final_output_buffer (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor storage.source.base 10240) (weight : Before cursor storage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected projection storage.outputWeights (Before cursor)) :
    let output := (finalWorkspace aligned room source weight parameters).output.outputBuffer
    output.base=cursor+10240 ∧ Before (cursor+506880) output.base 496640 := by
  dsimp only
  rw [final_buffer_base]
  exact final_output aligned room source weight parameters

set_option maxRecDepth 100000 in
theorem graph_output (body : TokenParameterConstruction.BodyPlan embedding angle)
    (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor body.finalStorage.source.base 10240) (weight : Before cursor body.finalStorage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected p.graph.output body.finalStorage.outputWeights (Before cursor)) :
    let output := (graphPlan body aligned room source weight parameters).forward.logitsBuffer
    output.base=cursor+10240 ∧ Before (cursor+506880) output.base 496640 :=
  final_output_buffer aligned room source weight parameters

theorem final_frame (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor storage.source.base 10240) (weight : Before cursor storage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected projection storage.outputWeights (Before cursor))
    (inside : Before cursor base size) (offset : Nat) (bound : offset<size) :
    (finalWorkspace aligned room source weight parameters).output.outputBuffer.bytes (base+offset)=storage.source.bytes (base+offset) :=
  (finalWorkspace aligned room source weight parameters).other_region (fresh inside) offset bound

theorem final_next (aligned : cursor%16=0) : (cursor+506880)%16=0 := aligned_next aligned (by decide +kernel)

theorem graph_frame (body : TokenParameterConstruction.BodyPlan embedding angle)
    (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor body.finalStorage.source.base 10240) (weight : Before cursor body.finalStorage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected p.graph.output body.finalStorage.outputWeights (Before cursor))
    (inside : Before cursor base size) (offset : Nat) (bound : offset<size) :
    (graphPlan body aligned room source weight parameters).forward.logitsBuffer.bytes (base+offset)=
      (graphPlan body aligned room source weight parameters).forward.hiddenBuffer.bytes (base+offset) :=
  (graphPlan body aligned room source weight parameters).forward.tail_frame
    (TokenWorkspaceConstruction.graph_tail_protect body (finalWorkspace aligned room source weight parameters) (fresh inside)) offset bound

theorem graph_caches_before (body : TokenParameterConstruction.BodyPlan embedding angle)
    (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor body.finalStorage.source.base 10240) (weight : Before cursor body.finalStorage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected p.graph.output body.finalStorage.outputWeights (Before cursor))
    (caches : DecodePreservation.Protected (Before cursor) p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
      (graphPlan body aligned room source weight parameters).forward.hiddenBuffer.bytes
      (graphPlan body aligned room source weight parameters).forward.chainCache) :
    DecodePreservation.Protected (Before (cursor+506880)) p.graph.stages
      (DecodeChain.run p.graph.stages state.logical.cache (p.embedding.forward state.logical.token) angle).2
      (graphPlan body aligned room source weight parameters).forward.logitsBuffer.bytes
      ((graphPlan body aligned room source weight parameters).forward.afterCache
        (graph_cache_safe body aligned room source weight parameters caches)) := by
  unfold Qwen38TrellisM1MaxMemory.Execution.afterCache
  apply DecodePreservation.preserves_geometry
  exact TokenWorkspaceConstruction.cache_mono (fun _ _ inside => before_next inside) _ _ _ _ caches

def graphParametersAfter (body : TokenParameterConstruction.BodyPlan embedding angle)
    (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor body.finalStorage.source.base 10240) (weight : Before cursor body.finalStorage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected p.graph.output body.finalStorage.outputWeights (Before cursor))
    (loaded : TokenParameterMemory.Storage p (graphPlan body aligned room source weight parameters).forward.hiddenBuffer.bytes)
    (safe : loaded.Protected (Before cursor)) :
    TokenParameterMemory.Storage p (graphPlan body aligned room source weight parameters).forward.logitsBuffer.bytes :=
  retainParameters loaded _ safe (fun _ _ inside => graph_frame body aligned room source weight parameters inside)

theorem graph_parameters_before (body : TokenParameterConstruction.BodyPlan embedding angle)
    (aligned : cursor%16=0) (room : cursor+506880≤2^64)
    (source : Before cursor body.finalStorage.source.base 10240) (weight : Before cursor body.finalStorage.normWeights.base 10240)
    (parameters : AffineMemoryFrames.Protected p.graph.output body.finalStorage.outputWeights (Before cursor))
    (loaded : TokenParameterMemory.Storage p (graphPlan body aligned room source weight parameters).forward.hiddenBuffer.bytes)
    (safe : loaded.Protected (Before cursor)) :
    (graphParametersAfter body aligned room source weight parameters loaded safe).Protected (Before (cursor+506880)) :=
  retainParameters_before loaded _ safe _

variable {logits : Fin 248320 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer logits}

def samplerWorkspace (aligned : cursor%16=0) (room : cursor+1952≤2^64)
    (input : Before cursor source.base 496640) : NormalizedArgmaxAllocation.Workspace source where
  base := cursor
  aligned := by omega
  bounded := room
  separate := fresh input

def samplerPlan (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    TokenAutoregressiveMemoryConstruction.SamplerPlan source :=
  TokenWorkspaceConstruction.samplerPlan (samplerWorkspace aligned room input) lseLocal tileLocal finishLocal

theorem sampler_region (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (inside : Before cursor base size) : (samplerPlan aligned room input lseLocal tileLocal finishLocal).Region base size :=
  TokenWorkspaceConstruction.sampler_protect (samplerWorkspace aligned room input) sampling lseLocal tileLocal finishLocal (fresh inside)

theorem sampler_frame (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (inside : Before cursor base size) (offset : Nat) (bound : offset<size) :
    ((samplerPlan aligned room input lseLocal tileLocal finishLocal).build sampling).memory (base+offset)=source.bytes (base+offset) := by
  unfold samplerPlan
  rw [TokenWorkspaceConstruction.sampler_pipeline]
  exact (samplerWorkspace aligned room input).other_region sampling lseLocal tileLocal finishLocal (fresh inside) offset bound

theorem sampler_output (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    let output := (samplerPlan aligned room input lseLocal tileLocal finishLocal).build sampling
    output.selection.destination=cursor+1948 ∧ Before (cursor+1952) output.selection.destination 4 := by
  have base := (samplerWorkspace aligned room input).token_base sampling lseLocal tileLocal finishLocal
  have outputBase : ((samplerPlan aligned room input lseLocal tileLocal finishLocal).build sampling).selection.destination=cursor+1948 := base
  refine ⟨outputBase,?_⟩
  unfold Before
  rw [outputBase]

theorem sampler_next (aligned : cursor%16=0) : (cursor+1952)%16=0 := aligned_next aligned (by decide +kernel)

theorem sampler_cache_regions (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages steps)
    (buffers : DecodeFrame.Storage stages cache source.bytes)
    (safe : DecodePreservation.Protected (Before cursor) stages cache source.bytes buffers) :
    DecodePreservation.Protected (samplerPlan aligned room input lseLocal tileLocal finishLocal).Region stages cache source.bytes buffers :=
  TokenWorkspaceConstruction.cache_mono (fun _ _ inside => sampler_region aligned room input sampling lseLocal tileLocal finishLocal inside) _ _ _ _ safe

theorem sampler_parameter_regions (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (parameters : TokenParameterMemory.Storage p source.bytes) (safe : parameters.Protected (Before cursor)) :
    parameters.Protected (samplerPlan aligned room input lseLocal tileLocal finishLocal).Region :=
  parameters.protected_mono (fun _ _ inside => sampler_region aligned room input sampling lseLocal tileLocal finishLocal inside) safe

def samplerParametersAfter (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (parameters : TokenParameterMemory.Storage p source.bytes) (safe : parameters.Protected (Before cursor)) :
    TokenParameterMemory.Storage p ((samplerPlan aligned room input lseLocal tileLocal finishLocal).build sampling).memory :=
  retainParameters parameters _ safe (fun _ _ inside => sampler_frame aligned room input sampling lseLocal tileLocal finishLocal inside)

theorem sampler_parameters_before (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (parameters : TokenParameterMemory.Storage p source.bytes) (safe : parameters.Protected (Before cursor)) :
    (samplerParametersAfter aligned room input sampling lseLocal tileLocal finishLocal parameters safe).Protected (Before (cursor+1952)) :=
  retainParameters_before parameters _ safe _

def samplerCachesAfter (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages steps)
    (buffers : DecodeFrame.Storage stages cache source.bytes)
    (safe : DecodePreservation.Protected (Before cursor) stages cache source.bytes buffers) :
    DecodeFrame.Storage stages cache ((samplerPlan aligned room input lseLocal tileLocal finishLocal).build sampling).memory :=
  retainCaches stages cache source.bytes _ buffers safe (fun _ _ inside => sampler_frame aligned room input sampling lseLocal tileLocal finishLocal inside)

theorem sampler_caches_before (aligned : cursor%16=0) (room : cursor+1952≤2^64) (input : Before cursor source.base 496640)
    (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages steps)
    (buffers : DecodeFrame.Storage stages cache source.bytes)
    (safe : DecodePreservation.Protected (Before cursor) stages cache source.bytes buffers) :
    DecodePreservation.Protected (Before (cursor+1952)) stages cache _
      (samplerCachesAfter aligned room input sampling lseLocal tileLocal finishLocal stages cache buffers safe) :=
  retainCaches_before stages cache source.bytes _ buffers safe _

theorem sampler_actual_caches_before
    (execution : Qwen38TrellisM1MaxSamplingMemory.Execution graph cache input angle sampling)
    (safe : DecodePreservation.Protected (Before cursor) graph.stages
      (DecodeChain.run graph.stages cache input angle).2 execution.forward.logitsBuffer.bytes
      (execution.forward.afterCache execution.forwardSafe)) :
    DecodePreservation.Protected (Before (cursor+1952)) graph.stages
      (DecodeChain.run graph.stages cache input angle).2 execution.memory execution.afterCache := by
  unfold Qwen38TrellisM1MaxSamplingMemory.Execution.afterCache
  apply DecodePreservation.preserves_geometry
  exact TokenWorkspaceConstruction.cache_mono (fun _ _ inside => before_next inside) _ _ _ _ safe

end Inference.Models.Qwen.TokenBoundaryHighWater
