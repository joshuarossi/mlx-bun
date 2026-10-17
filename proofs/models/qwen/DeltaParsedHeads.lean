import models.qwen.DeltaConvolutionMemory
import kernels.delta.SiluHeads128Memory
import kernels.delta.SiluHeads128HostSelection

namespace Inference.Models.Qwen.DeltaParsedHeads
open Contracts.Mlx Kernels.Delta Layers
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000

variable {projected : Fin 10240 → ArrayStorage.BF} {qScale kScale : Fin 128 → ArrayStorage.BF}
  {headInput : DeltaHeadsMemory.Input projected qScale kScale}
  {p : SiluRmsHeads.Platform} {width eps : Float32}
  {heads : DeltaHeadsMemory.Execution headInput p width eps}
  {aLog a dtBias b : GateDevice.Heads} {gatePlatform : Inputs.Platform}

theorem source_execution (heads : DeltaHeadsMemory.Execution headInput p width eps)
    (widthSame : width=SiluHeads128Output.width) (epsSame : eps=SiluHeads128Output.epsilon)
    (initial : SiluHeads128Threads.Initial) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores,store ∈ heads.trace.schedule) :
    ∃ writes,SiluHeads128Memory.programs p (heads.during stores subset) heads.geometry.base initial=some writes ∧
      ThreadgroupWrites.Executes writes heads.trace.schedule heads.trace.remaining ∧
      ThreadgroupWrites.AtBarrier heads.trace.remaining := by
  subst width
  subst eps
  exact SiluHeads128Memory.source_execution heads initial stores subset

-- Read the preserved Q/K/V arrays from the later gate-output heap that is
-- actually passed into recurrence. No intermediate tensor is supplied.
def afterGates (preparation : DeltaPreparedMemory.Execution heads aLog a dtBias b gatePlatform) :
    DeltaHeads.Output 1 ArrayStorage.BF where
  q _ h col := preparation.operands.query.read (GatedInputs.index h col)
  k _ h col := preparation.operands.key.read (GatedInputs.index h col)
  v _ h col := preparation.operands.value.read (GatedInputs.index h col)

theorem after_eq (preparation : DeltaPreparedMemory.Execution heads aLog a dtBias b gatePlatform) :
    afterGates preparation=heads.output := by
  unfold afterGates DeltaHeadsMemory.Execution.output
  simp only [ArrayStorage.BFBuffer.read_correct,GatedInputs.flatten_index]
  rfl

theorem current_heap (preparation : DeltaPreparedMemory.Execution heads aLog a dtBias b gatePlatform) :
    preparation.operands.query.bytes=preparation.gates.betaBuffer.bytes ∧
    preparation.operands.key.bytes=preparation.gates.betaBuffer.bytes ∧
    preparation.operands.value.bytes=preparation.gates.betaBuffer.bytes := ⟨rfl,rfl,rfl⟩

theorem after_forward (preparation : DeltaPreparedMemory.Execution heads aLog a dtBias b gatePlatform) :
    afterGates preparation=DeltaHeads.forward p (fun _ => projected) qScale kScale width eps := by
  rw [after_eq,heads.output_eq]

theorem after_error (preparation : DeltaPreparedMemory.Execution heads aLog a dtBias b gatePlatform)
    (idealEps epsError : ℝ) (positive : 0 < idealEps) (epsBound : |Numerics.real eps-idealEps|≤epsError)
    (finite : DeltaHeads.Finite p (fun _ : Fin 1 => projected) qScale kScale width eps)
    (target error : Fin 1 → Fin 10240 → ℝ)
    (inputBound : ∀ row i, |Model.toReal (projected i)-target row i| ≤ error row i) :
    DeltaHeads.Error (afterGates preparation) (DeltaHeads.target target qScale kScale idealEps)
      (DeltaHeads.bounds p (fun _ => projected) qScale kScale width eps idealEps epsError target error) := by
  rw [after_forward]
  exact DeltaHeads.forward_error p _ qScale kScale width eps idealEps epsError positive epsBound finite target error inputBound

section Convolution
variable {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
  {weight : Fin 10240 → Fin 4 → ArrayStorage.BF}
  {input : ConvolutionMemory.Input history next weight} {contracted : Bool}
  {convolution : ConvolutionMemory.Execution input contracted}
  (preparation : DeltaConvolutionMemory.Execution convolution qScale kScale p width eps aLog a dtBias b gatePlatform)

theorem convolution_heap : preparation.scales.headInput.storage.input.bytes=convolution.stores.memory := rfl

theorem convolution_forward :
    afterGates preparation.prepared=DeltaHeads.forward (rows := 1) p
      (fun _ channel => Convolution.value contracted (fun tap => Convolution.streamWindow history next tap channel) (weight channel))
      qScale kScale width eps := by
  rw [after_eq]
  exact preparation.heads_eq

end Convolution
end Inference.Models.Qwen.DeltaParsedHeads
