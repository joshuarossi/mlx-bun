import kernels.delta.GatedDevice
import kernels.GatedRmsNormDevice

namespace Inference.Kernels.Delta.GatedOutput
open Contracts.Mlx

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {inputs : GatedDevice.Inputs}

-- Reuse the completed recurrence output allocation directly. The next
-- normalization launch consumes its readback, with no re-encoding step.
def buffer (execution : GatedDevice.Execution reduce flags initial inputs) :
    ArrayStorage.BFBuffer (GatedInputs.flatten execution.output) where
  bytes := execution.stores.outputMemory
  base := execution.stores.outputBase
  aligned := execution.stores.outputAligned
  bounded := execution.stores.outputBounded
  attached := by
    intro i
    change HalfMemory.load execution.stores.outputMemory (execution.stores.outputBase+2*i.val)=
      HalfMemory.load execution.stores.outputMemory (execution.stores.outputBase+2*(i.val/128*128+i.val%128))
    congr 1
    omega

theorem read_correct (execution : GatedDevice.Execution reduce flags initial inputs) (head : Fin 48) (row : Fin 128) :
    (buffer execution).read (GatedInputs.index head row)=execution.output head row := by
  rw [ArrayStorage.BFBuffer.read_correct, GatedInputs.flatten_index]

def normalizationStorage (execution : GatedDevice.Execution reduce flags initial inputs)
    (gate : GatedRmsNormDevice.Rows) (weight : Fin 128 → ArrayStorage.BF) :
    GatedRmsNormDevice.Storage execution.output gate weight :=
  ⟨buffer execution, ArrayStorage.BFBuffer.canonical _ (by decide), ArrayStorage.BFBuffer.canonical _ (by decide)⟩

def normalization (p : GatedRmsNorm.Platform) (width eps : Float32)
    (execution : GatedDevice.Execution reduce flags initial inputs)
    (gate : GatedRmsNormDevice.Rows) (weight : Fin 128 → ArrayStorage.BF) :
    GatedRmsNormDevice.Execution p width eps execution.output gate weight :=
  GatedRmsNormDevice.Execution.fromStorage p width eps _ _ _ (normalizationStorage execution gate weight)

theorem normalization_input_bytes (p : GatedRmsNorm.Platform) (width eps : Float32)
    (execution : GatedDevice.Execution reduce flags initial inputs)
    (gate : GatedRmsNormDevice.Rows) (weight : Fin 128 → ArrayStorage.BF) :
    (normalization p width eps execution gate weight).storage.input.bytes=execution.stores.outputMemory := rfl

theorem normalization_output (p : GatedRmsNorm.Platform) (width eps : Float32)
    (execution : GatedDevice.Execution reduce flags initial inputs)
    (gate : GatedRmsNormDevice.Rows) (weight : Fin 128 → ArrayStorage.BF) :
    (normalization p width eps execution gate weight).output=
      fun head => GatedRmsNorm.value p (execution.output head) (gate head) weight width eps :=
  GatedRmsNormDevice.Execution.output_eq _

end Inference.Kernels.Delta.GatedOutput
