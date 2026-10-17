import kernels.sampling.LogSumExpSourceGeometry
namespace Inference.Kernels.Sampling.LogSumExpSourceHost

-- Reviewed translation of pinned logsumexp.cpp and its BF16 instantiation.
-- Extraction of an actual native array's flags/type/shape and the pipeline's
-- maxTotalThreadsPerThreadgroup remain explicit descriptor boundaries.
structure Metadata where
  axis : Nat
  dataSize : Nat
  contiguous : Bool
  lastStride : Nat
  rowContiguous : Bool
  bf16 : Bool
  deriving DecidableEq,Repr
structure Launch where
  axis : Nat
  rows : Nat
  reads : Nat
  simdSize : Nat
  threads : Nat
  grid : Nat
  looped : Bool
  fresh : Bool
  deriving DecidableEq,Repr

def select (metadata : Metadata) (pipelineMaximum : Nat) : Option Launch :=
  if metadata.contiguous && decide (metadata.lastStride=1) && metadata.rowContiguous && metadata.bf16 then
    if 0<metadata.axis ∧ metadata.axis<2^31 ∧ metadata.dataSize/metadata.axis<2^31 then
      let looped := decide (4096<metadata.axis)
      let threads := if looped then pipelineMaximum else 32*((((metadata.axis+4-1)/4)+32-1)/32)
      some ⟨metadata.axis,metadata.dataSize/metadata.axis,4,32,threads,(metadata.dataSize/metadata.axis)*threads,looped,true⟩
    else none
  else none

def selected : Metadata := ⟨248320,248320,true,1,true,true⟩
def launch : Launch := ⟨248320,1,4,32,1024,1024,true,true⟩
theorem selected_launch : select selected 1024=some launch := by rfl

theorem selected_arguments (maxThreads : Nat) (nativeMaximum : maxThreads=1024) :
    select selected maxThreads=some launch ∧
      LogSumExpSourceGeometry.iterations launch.axis launch.reads launch.threads=61 ∧
      launch.threads/launch.simdSize=32 := by
  subst maxThreads
  exact ⟨selected_launch,rfl,rfl⟩

theorem row_zero (row : Fin launch.rows) : row.val=0 := by have := row.isLt; change row.val<1 at this; omega

theorem group_complete (group lane : Fin 32) :
    LogSumExpLayout.threadAt group lane=⟨group.val*32+lane.val,by have := group.isLt;have := lane.isLt;omega⟩ := rfl

theorem ownership (thread : Fin 1024) :
    LogSumExpLayout.threadAt (LogSumExpLayout.groupOf thread) (LogSumExpLayout.laneOf thread)=thread :=
  LogSumExpLayout.thread_roundtrip thread
-- This boundary is supplied from the actual native descriptor and pipeline;
-- neither equality claims a floating-point computation result.
structure Attachment where
  metadata : Metadata
  pipelineMaximum : Nat
  selectedMetadata : metadata=selected
  maximum1024 : pipelineMaximum=1024

theorem attached_launch (native : Attachment) : select native.metadata native.pipelineMaximum=some launch := by
  rw [native.selectedMetadata,native.maximum1024]
  exact selected_launch
end Inference.Kernels.Sampling.LogSumExpSourceHost
