import layers.AffineMemory

namespace Inference.Layers.AffineMemoryFrames
open Contracts.Mlx AffineVerifyLinear
set_option maxRecDepth 10000

def Protected (p : Projection steps rows) (weights : AffineDevice.Storage p) (property : Nat → Nat → Prop) : Prop :=
  match p with
  | .bits3 _ => property weights.buffers.packedBase (rows*(steps*64*3)) ∧
      property weights.buffers.scaleBase (2*(rows*(steps*8))) ∧ property weights.buffers.biasBase (2*(rows*(steps*8)))
  | .bits4 _ => property weights.buffers.packedBase (rows*(steps*64*4)) ∧
      property weights.buffers.scaleBase (2*(rows*(steps*8))) ∧ property weights.buffers.biasBase (2*(rows*(steps*8)))

def Stable (p : Projection steps rows) (weights : AffineDevice.Storage p) (after : ByteMemory.Bytes) : Prop :=
  match p with
  | .bits3 _ => Kernels.Quantization.AffineMemory.Stable .three weights.buffers steps rows after
  | .bits4 _ => Kernels.Quantization.AffineMemory.Stable .four weights.buffers steps rows after

theorem stable (p : Projection steps rows) (weights : AffineDevice.Storage p) (before after : ByteMemory.Bytes)
    (shared : AffineMemory.Shared p weights before)
    (same : Protected p weights (fun base size => ∀ offset < size, after (base+offset)=before (base+offset))) :
    Stable p weights after := by
  cases p with
  | bits3 p =>
    exact ⟨fun offset bound => (same.1 offset bound).trans (congrFun shared.packed _).symm,
      fun offset bound => (same.2.1 offset bound).trans (congrFun shared.scales _).symm,
      fun offset bound => (same.2.2 offset bound).trans (congrFun shared.biases _).symm⟩
  | bits4 p =>
    exact ⟨fun offset bound => (same.1 offset bound).trans (congrFun shared.packed _).symm,
      fun offset bound => (same.2.1 offset bound).trans (congrFun shared.scales _).symm,
      fun offset bound => (same.2.2 offset bound).trans (congrFun shared.biases _).symm⟩

def reframe (p : Projection steps rows) (weights : AffineDevice.Storage p) (after : ByteMemory.Bytes)
    (same : Stable p weights after) : AffineDevice.Storage p :=
  match p with
  | .bits3 _ => ⟨Kernels.Quantization.AffineMemory.reframe weights.buffers after,
      Kernels.Quantization.AffineMemory.reframe_geometry weights.geometry after,
      fun row => (Kernels.Quantization.AffineMemory.weights3_eq same row).trans (weights.attached row)⟩
  | .bits4 _ => ⟨Kernels.Quantization.AffineMemory.reframe weights.buffers after,
      Kernels.Quantization.AffineMemory.reframe_geometry weights.geometry after,
      fun row => (Kernels.Quantization.AffineMemory.weights4_eq same row).trans (weights.attached row)⟩

theorem reframe_shared (p : Projection steps rows) (weights : AffineDevice.Storage p) (after : ByteMemory.Bytes)
    (same : Stable p weights after) : AffineMemory.Shared p (reframe p weights after same) after := by
  cases p <;> exact ⟨rfl,rfl,rfl⟩

theorem reframe_protected (p : Projection steps rows) (weights : AffineDevice.Storage p) (after : ByteMemory.Bytes)
    (same : Stable p weights after) (property : Nat → Nat → Prop) :
    Protected p (reframe p weights after same) property ↔ Protected p weights property := by cases p <;> rfl

theorem protected_mono (p : Projection steps rows) (weights : AffineDevice.Storage p)
    {first second : Nat → Nat → Prop} (implies : ∀ base size, first base size → second base size)
    (safe : Protected p weights first) : Protected p weights second := by
  cases p <;> exact ⟨implies _ _ safe.1, implies _ _ safe.2.1, implies _ _ safe.2.2⟩

variable {steps groups : Nat} {p : Projection steps (4*groups)} {input : Fin (steps*512) → ArrayStorage.BF}

theorem source_preserved (execution : AffineMemory.Execution p input) (offset : Nat) (bound : offset<2*(steps*512)) :
    execution.outputBuffer.bytes (execution.source.base+offset)=execution.source.bytes (execution.source.base+offset) := by
  cases p with
  | bits3 _ => exact execution.kernel.other_region execution.kernel.inputSeparate offset bound
  | bits4 _ => exact execution.kernel.other_region execution.kernel.inputSeparate offset bound

def sourceAfter (execution : AffineMemory.Execution p input) : ArrayStorage.BFBuffer input :=
  ArrayFrame.bf execution.source execution.outputBuffer.bytes (source_preserved execution)

-- Preserve another projection's exact packed/scales/bias attachment through
-- this launch, so subsequent projections cannot silently acquire new weights.
def weightsAfter (execution : AffineMemory.Execution p input) (next : Projection nextSteps nextRows)
    (weights : AffineDevice.Storage next) (shared : AffineMemory.Shared next weights execution.source.bytes)
    (safe : Protected next weights (MemoryRegions.Disjoint execution.base (2*(4*groups)))) :
    AffineDevice.Storage next :=
  reframe next weights execution.outputBuffer.bytes
    (stable next weights execution.source.bytes execution.outputBuffer.bytes shared
      (protected_mono next weights (fun _ _ separate => execution.other_region separate) safe))

theorem weightsAfter_shared (execution : AffineMemory.Execution p input) (next : Projection nextSteps nextRows)
    (weights : AffineDevice.Storage next) (shared : AffineMemory.Shared next weights execution.source.bytes)
    (safe : Protected next weights (MemoryRegions.Disjoint execution.base (2*(4*groups)))) :
    AffineMemory.Shared next (weightsAfter execution next weights shared safe) execution.outputBuffer.bytes :=
  reframe_shared next weights execution.outputBuffer.bytes _

end Inference.Layers.AffineMemoryFrames
