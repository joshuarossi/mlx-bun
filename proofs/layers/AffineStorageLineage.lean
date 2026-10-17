import layers.AffineMemoryFrames

namespace Inference.Layers.AffineStorageLineage
open Contracts.Mlx AffineVerifyLinear

-- Keep the three physical parameter addresses distinct across heap frames.
def addresses (p : Projection steps rows) : AffineDevice.Storage p → Nat × Nat × Nat := match p with
  | .bits3 _ => fun weights => (weights.buffers.packedBase,weights.buffers.scaleBase,weights.buffers.biasBase)
  | .bits4 _ => fun weights => (weights.buffers.packedBase,weights.buffers.scaleBase,weights.buffers.biasBase)

theorem reframe_addresses (p : Projection steps rows) (weights : AffineDevice.Storage p) (after : ByteMemory.Bytes)
    (same : AffineMemoryFrames.Stable p weights after) :
    addresses p (AffineMemoryFrames.reframe p weights after same)=addresses p weights := by cases p <;> rfl

variable {steps groups : Nat} {p : Projection steps (4*groups)} {input : Fin (steps*512) → ArrayStorage.BF}

def launchWeights (execution : AffineMemory.Execution p input) : AffineDevice.Storage p := match p with
  | .bits3 _ => execution.weights
  | .bits4 _ => execution.weights

theorem fromStorage_weights (weights : AffineDevice.Storage p) (source : ArrayStorage.BFBuffer input)
    (shared : AffineMemory.Shared p weights source.bytes)
    (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups)≤2^64)
    (inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (weightsSeparate : AffineMemory.Separate p weights base (2*(4*groups))) :
    launchWeights (AffineMemory.fromStorage p input weights source shared base aligned bounded inputSeparate weightsSeparate)=weights :=
  by cases p <;> rfl

theorem fromStorage_addresses (weights : AffineDevice.Storage p) (source : ArrayStorage.BFBuffer input)
    (shared : AffineMemory.Shared p weights source.bytes)
    (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups)≤2^64)
    (inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (weightsSeparate : AffineMemory.Separate p weights base (2*(4*groups))) :
    addresses p (launchWeights
      (AffineMemory.fromStorage p input weights source shared base aligned bounded inputSeparate weightsSeparate))=addresses p weights :=
  congrArg (addresses p) (fromStorage_weights weights source shared base aligned bounded inputSeparate weightsSeparate)

theorem weightsAfter_addresses (execution : AffineMemory.Execution p input) (next : Projection nextSteps nextRows)
    (weights : AffineDevice.Storage next) (shared : AffineMemory.Shared next weights execution.source.bytes)
    (safe : AffineMemoryFrames.Protected next weights (MemoryRegions.Disjoint execution.base (2*(4*groups)))) :
    addresses next (AffineMemoryFrames.weightsAfter execution next weights shared safe)=addresses next weights :=
  reframe_addresses next weights _ _

end Inference.Layers.AffineStorageLineage
