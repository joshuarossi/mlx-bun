import models.qwen.FinalProjectionAllocation
import models.qwen.FinalProjectionSamplerSource

namespace Inference.Models.Qwen.FinalProjectionSamplerAllocation
open Contracts.Mlx Layers Kernels.Sampling
set_option maxRecDepth 10000

def bytes : Nat := 508832
def Before (cursor base size : Nat) : Prop := base+size≤cursor

variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
  {input : Fin 5120 → ArrayStorage.BF} {storage : FinalProjectionConstruction.Storage norm projection input}

structure Request (storage : FinalProjectionConstruction.Storage norm projection input) where
  cursor : Nat
  aligned : cursor%16=0
  room : cursor+bytes≤2^64
  source : Before cursor storage.source.base 10240
  norm : Before cursor storage.normWeights.base 10240
  weights : AffineMemoryFrames.Protected projection storage.outputWeights (Before cursor)

variable (request : Request storage)

def workspace : FinalProjectionAllocation.Workspace storage where
  base := request.cursor
  aligned := by have := request.aligned; omega
  bounded := by have := request.room; unfold bytes at this; change request.cursor+506880≤2^64; omega
  sourceSafe := Or.inr request.source
  normSafe := Or.inr request.norm
  outputSafe := AffineMemoryFrames.protected_mono _ _ (fun _ _ below => Or.inr below) request.weights

def allocation : FinalProjectionConstruction.Allocation storage := (workspace request).allocation

private theorem output_buffer_base (allocation : FinalProjectionConstruction.Allocation storage) :
    (FinalProjectionSamplerSource.logitsBuffer storage allocation).base=allocation.outputBase := by
  cases projection <;> rfl

theorem logits_base : (FinalProjectionSamplerSource.logitsBuffer storage (allocation request)).base=request.cursor+10240 :=
  output_buffer_base (allocation request)

private def afterProjection {values : Fin 248320 → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    (cursor : Nat) (aligned : cursor%16=0) (room : cursor+bytes≤2^64)
    (base : source.base=cursor+10240) : NormalizedArgmaxAllocation.Workspace source where
  base := cursor+506880
  aligned := by omega
  bounded := by unfold bytes at room; change cursor+506880+1952≤2^64; omega
  separate := Or.inr (by omega)

def samplerWorkspace : NormalizedArgmaxAllocation.Workspace (FinalProjectionSamplerSource.logitsBuffer storage (allocation request)) :=
  afterProjection _ request.cursor request.aligned request.room (logits_base request)

def execution (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    FinalProjectionSamplerSource.Execution storage (allocation request) sampling :=
  ⟨samplerWorkspace request,lseLocal,tileLocal,finishLocal⟩

theorem normalization_safe (below : Before request.cursor base size) :
    MemoryRegions.Disjoint (2*(allocation request).normBase) 10240 base size :=
  (workspace request).normalization_safe (Or.inr below)

theorem projection_safe (below : Before request.cursor base size) :
    MemoryRegions.Disjoint (allocation request).outputBase 496640 base size :=
  (workspace request).output_safe (Or.inr below)

theorem sampler_safe (below : Before request.cursor base size) :
    MemoryRegions.Disjoint (samplerWorkspace request).base NormalizedArgmaxAllocation.bytes base size :=
  Or.inr (by change base+size≤request.cursor+506880; unfold Before at below; omega)

theorem frame (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
    (below : Before request.cursor base size) (offset : Nat) (bound : offset<size) :
    (execution request sampling lseLocal tileLocal finishLocal).sampler.memory (base+offset)=storage.source.bytes (base+offset) :=
  (FinalProjectionSamplerSource.preserve_region _ (sampler_safe request below) offset bound).trans
    ((workspace request).other_region (Or.inr below) offset bound)

theorem token_base (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    (execution request sampling lseLocal tileLocal finishLocal).sampler.selection.destination=request.cursor+508828 := by
  change (request.cursor+506880)+1948=request.cursor+508828
  omega

theorem token_bound (sampling : LogSumExpRanges.Platform) (lseLocal : ByteMemory.Bytes)
    (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes) :
    Before (request.cursor+bytes) (execution request sampling lseLocal tileLocal finishLocal).sampler.selection.destination 4 := by
  have address := token_base request sampling lseLocal tileLocal finishLocal
  unfold Before bytes
  omega

theorem next_aligned : (request.cursor+bytes)%16=0 := by have := request.aligned; unfold bytes; omega

end Inference.Models.Qwen.FinalProjectionSamplerAllocation
