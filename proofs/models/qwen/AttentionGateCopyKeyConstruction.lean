import models.qwen.AttentionGateCopyKvMemory

namespace Inference.Models.Qwen.AttentionGateCopyKeyConstruction
open Contracts.Mlx Kernels.Attention Layers
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

structure Preparation (p : AttentionHeads.Projections) (input : Fin 5120 → ArrayStorage.BF) where
  q : AffineMemory.Execution (groups:=3072) p.q input
  copy : MlxAttentionGateCopyMemory.Execution (p.q.forward input)
  linked : copy.source=q.forwardBuffer
  weights : AffineDevice.Storage p.k
  shared : AffineMemory.Shared p.k weights copy.source.bytes
  inputSafe : MemoryRegions.Disjoint copy.base 12288 q.source.base 10240
  weightsSafe : AffineMemoryFrames.Protected p.k weights (MemoryRegions.Disjoint copy.base 12288)

structure Allocation {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}
    (prep : Preparation p input) where
  base : Nat
  aligned : base%2=0
  bounded : base+2048≤2^64
  inputSeparate : MemoryRegions.Disjoint base 2048 prep.q.source.base 10240
  weightsSeparate : AffineMemory.Separate p.k prep.weights base 2048

variable {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}

theorem query_input_shared (prep : Preparation p input) :
    (AffineMemoryFrames.sourceAfter prep.q).bytes=prep.copy.source.bytes := by
  have shared := congrArg ArrayStorage.BFBuffer.bytes prep.linked
  exact shared.symm

def key (prep : Preparation p input) (allocation : Allocation prep) : AffineMemory.Execution (groups:=256) p.k input :=
  AttentionGateCopyFrames.projectAfter (steps:=10) (groups:=256) prep.copy p.k (AffineMemoryFrames.sourceAfter prep.q)
    (query_input_shared prep) prep.inputSafe prep.weights prep.shared prep.weightsSafe
    allocation.base allocation.aligned allocation.bounded allocation.inputSeparate allocation.weightsSeparate

theorem key_heap (prep : Preparation p input) (allocation : Allocation prep) :
    (key prep allocation).source.bytes=prep.copy.trace.memory :=
  AttentionGateCopyFrames.project_after_source (steps:=10) (groups:=256) prep.copy p.k (AffineMemoryFrames.sourceAfter prep.q)
    (query_input_shared prep) prep.inputSafe prep.weights prep.shared prep.weightsSafe
    allocation.base allocation.aligned allocation.bounded allocation.inputSeparate allocation.weightsSeparate

theorem key_base (prep : Preparation p input) (allocation : Allocation prep) :
    (key prep allocation).source.base=prep.q.source.base := by
  have same : (key prep allocation).source=
      AttentionGateCopyFrames.sourceAfter prep.copy (AffineMemoryFrames.sourceAfter prep.q)
        (query_input_shared prep) prep.inputSafe := by
    unfold key AttentionGateCopyFrames.projectAfter
    exact AffineMemory.source_fromStorage (p:=p.k) (steps:=10) (groups:=256) _ _ _ _ _ _ _ _
  have bases := congrArg ArrayStorage.BFBuffer.base same
  exact bases

-- The value launch is an actual existing affine execution linked to the
-- just-constructed key output, rather than a postulated K/V tensor.
def withValue (prep : Preparation p input) (allocation : Allocation prep)
    (value : AffineMemory.Execution (groups:=256) p.v input)
    (valueInput : value.source=AffineMemoryFrames.sourceAfter (key prep allocation))
    (copyQuery : MemoryRegions.Disjoint prep.copy.base 12288 prep.q.forwardBuffer.base 24576)
    (keyQuery : MemoryRegions.Disjoint (key prep allocation).base 2048 prep.q.forwardBuffer.base 24576)
    (valueQuery : MemoryRegions.Disjoint value.base 2048 prep.q.forwardBuffer.base 24576)
    (valueKey : MemoryRegions.Disjoint value.base 2048 (key prep allocation).forwardBuffer.base 2048)
    (keyGate : MemoryRegions.Disjoint (key prep allocation).base 2048 prep.copy.base 12288)
    (valueGate : MemoryRegions.Disjoint value.base 2048 prep.copy.base 12288) : AttentionGateCopyKvMemory.Execution p input :=
  ⟨prep.q,prep.copy,prep.linked,key prep allocation,key_heap prep allocation,key_base prep allocation,
    value,valueInput,copyQuery,keyQuery,valueQuery,valueKey,keyGate,valueGate⟩

end Inference.Models.Qwen.AttentionGateCopyKeyConstruction
