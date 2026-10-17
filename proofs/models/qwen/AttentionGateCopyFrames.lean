import kernels.attention.MlxAttentionGateCopyMemory
import layers.AffineMemoryFrames

namespace Inference.Models.Qwen.AttentionGateCopyFrames
open Contracts.Mlx Kernels.Attention Layers
set_option maxRecDepth 10000
variable {queryGate : Fin 12288 → ArrayStorage.BF}

def sourceAfter (copy : MlxAttentionGateCopyMemory.Execution queryGate) {n : Nat}
    {values : Fin n → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    (shared : source.bytes=copy.source.bytes)
    (safe : MemoryRegions.Disjoint copy.base 12288 source.base (2*n)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf source copy.trace.memory (by
    intro offset bound
    exact (MlxAttentionGateCopyMemory.other_region copy safe offset bound).trans (congrFun shared _).symm)

variable {steps rows : Nat} (copy : MlxAttentionGateCopyMemory.Execution queryGate)
  (p : AffineVerifyLinear.Projection steps rows) (weights : AffineDevice.Storage p)
  (shared : AffineMemory.Shared p weights copy.source.bytes)
  (safe : AffineMemoryFrames.Protected p weights (MemoryRegions.Disjoint copy.base 12288))

def weightsAfter : AffineDevice.Storage p :=
  AffineMemoryFrames.reframe p weights copy.trace.memory
    (AffineMemoryFrames.stable p weights copy.source.bytes copy.trace.memory shared
      (AffineMemoryFrames.protected_mono p weights
        (fun _ _ separate => MlxAttentionGateCopyMemory.other_region copy separate) safe))

theorem weights_shared : AffineMemory.Shared p (weightsAfter copy p weights shared safe) copy.trace.memory :=
  AffineMemoryFrames.reframe_shared p weights copy.trace.memory _

theorem weights_separate (base size : Nat) :
    AffineMemory.Separate p (weightsAfter copy p weights shared safe) base size ↔ AffineMemory.Separate p weights base size := by
  cases p <;> constructor <;> intro separation <;>
    exact ⟨separation.packed,separation.scales,separation.biases⟩

-- This builds the next projection on the heap AFTER the parsed copy. The
-- input payload and every packed/scales/bias attachment are derived by frame
-- proofs; neither a post-copy source tensor nor new weights are premises.
def projectAfter {groups : Nat} (copy : MlxAttentionGateCopyMemory.Execution queryGate)
    (p : AffineVerifyLinear.Projection steps (4*groups)) {input : Fin (steps*512) → ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer input) (sourceShared : source.bytes=copy.source.bytes)
    (sourceSafe : MemoryRegions.Disjoint copy.base 12288 source.base (2*(steps*512)))
    (weights : AffineDevice.Storage p) (shared : AffineMemory.Shared p weights copy.source.bytes)
    (safe : AffineMemoryFrames.Protected p weights (MemoryRegions.Disjoint copy.base 12288))
    (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups)≤2^64)
    (inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (weightsSeparate : AffineMemory.Separate p weights base (2*(4*groups))) : AffineMemory.Execution p input :=
  AffineMemory.fromStorage p input (weightsAfter copy p weights shared safe)
    (sourceAfter copy source sourceShared sourceSafe) (weights_shared copy p weights shared safe)
    base aligned bounded inputSeparate ((weights_separate copy p weights shared safe base _).mpr weightsSeparate)

theorem project_after_source {groups : Nat} (copy : MlxAttentionGateCopyMemory.Execution queryGate)
    (p : AffineVerifyLinear.Projection steps (4*groups)) {input : Fin (steps*512) → ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer input) (sourceShared : source.bytes=copy.source.bytes)
    (sourceSafe : MemoryRegions.Disjoint copy.base 12288 source.base (2*(steps*512)))
    (weights : AffineDevice.Storage p) (shared : AffineMemory.Shared p weights copy.source.bytes)
    (safe : AffineMemoryFrames.Protected p weights (MemoryRegions.Disjoint copy.base 12288))
    (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups)≤2^64)
    (inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (weightsSeparate : AffineMemory.Separate p weights base (2*(4*groups))) :
    (projectAfter copy p source sourceShared sourceSafe weights shared safe base aligned bounded inputSeparate weightsSeparate).source.bytes=
      copy.trace.memory := by cases p <;> rfl

-- Once the projection completes, its actual destination writes preserve the
-- already constructed contiguous gate allocation when the regions separate.
def gateAfter {groups : Nat} {p : AffineVerifyLinear.Projection steps (4*groups)}
    {input : Fin (steps*512) → ArrayStorage.BF} (copy : MlxAttentionGateCopyMemory.Execution queryGate)
    (execution : AffineMemory.Execution p input) (shared : execution.source.bytes=copy.trace.memory)
    (safe : MemoryRegions.Disjoint execution.base (2*(4*groups)) copy.base 12288) :
    ArrayStorage.BFBuffer (MlxAttentionGateCopyMemory.values queryGate) :=
  ArrayFrame.bf (MlxAttentionGateCopyMemory.buffer copy) execution.outputBuffer.bytes (by
    intro offset bound
    exact (execution.other_region safe offset bound).trans (congrFun shared _))

end Inference.Models.Qwen.AttentionGateCopyFrames
