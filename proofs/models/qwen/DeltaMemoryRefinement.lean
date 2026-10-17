import models.qwen.DeltaProjectionHandoff
import models.qwen.DeltaBlockMemory

namespace Inference.Models.Qwen.DeltaMemoryRefinement
open Contracts.Mlx Kernels Kernels.Delta
set_option maxRecDepth 10000

variable {layer : DeltaNet.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}
  {convInput : ConvolutionMemory.Input cache.history (layer.qkv.forward input) layer.convolutionWeight}
  {convolution : ConvolutionMemory.Execution convInput layer.recurrence.convolutionContracted}
  {preparation : DeltaConvolutionMemory.Execution convolution layer.headParams.qScale layer.headParams.kScale
    layer.recurrence.heads layer.headParams.width layer.headParams.eps layer.aLog (layer.a.forward input) layer.dtBias
    (layer.b.forward input) layer.recurrence.gates}

theorem convolution_eq (convolution : ConvolutionMemory.Execution convInput layer.recurrence.convolutionContracted) :
    convolution.output=State.Ssm.convolved layer.recurrence (DeltaNet.convData layer cache (fun _ => input)) 0 := by
  funext channel
  rw [convolution.output_eq]
  unfold State.Ssm.convolved State.Ssm.window DeltaNet.convData
  congr 1
  funext tap
  by_cases inside : tap.val<3 <;>
    simp only [Convolution.streamWindow, Convolution.window, Convolution.joined, Nat.zero_add, inside, ↓reduceDIte]

theorem inputs_eq (preparation : DeltaConvolutionMemory.Execution convolution layer.headParams.qScale layer.headParams.kScale
    layer.recurrence.heads layer.headParams.width layer.headParams.eps layer.aLog (layer.a.forward input) layer.dtBias
    (layer.b.forward input) layer.recurrence.gates) :
    preparation.prepared.values.inputs=(fun head row => DeltaNet.inputs layer cache (fun _ => input) head row 0) := by
  funext head row
  unfold GatedInputs.Values.inputs DeltaPreparedMemory.Execution.values
  simp only [Layers.DeltaHeadsDevice.produced_eq, GateDevice.produced_decay]
  rw [convolution_eq]
  rfl

theorem produced_output (preparation : DeltaConvolutionMemory.Execution convolution layer.headParams.qScale layer.headParams.kScale
    layer.recurrence.heads layer.headParams.width layer.headParams.eps layer.aLog (layer.a.forward input) layer.dtBias
    (layer.b.forward input) layer.recurrence.gates) :
    GatedDevice.producedOutput layer.recurrence.reduce layer.recurrence.flags cache.recurrent preparation.prepared.values.inputs=
      DeltaNet.recurrentOutput layer cache (fun _ => input) 0 := by
  rw [inputs_eq]
  unfold GatedDevice.producedOutput
  rfl

theorem produced_state (preparation : DeltaConvolutionMemory.Execution convolution layer.headParams.qScale layer.headParams.kScale
    layer.recurrence.heads layer.headParams.width layer.headParams.eps layer.aLog (layer.a.forward input) layer.dtBias
    (layer.b.forward input) layer.recurrence.gates) :
    GatedDevice.producedState layer.recurrence.reduce layer.recurrence.flags cache.recurrent preparation.prepared.values.inputs=
      (DeltaCache.after layer cache (fun _ => input) 1).recurrent := by
  rw [inputs_eq]
  unfold GatedDevice.producedState
  rfl

variable {recurrence : GatedShared.Execution layer.recurrence.reduce layer.recurrence.flags cache.recurrent preparation.prepared.values}
  {tailInput : DeltaTailMemory.Input recurrence (DeltaNet.zHead layer (fun _ => input) 0) layer.normWeight}

theorem tail_forward (tail : DeltaTailMemory.Execution tailInput layer.gated layer.headParams.width layer.headParams.eps layer.out) :
    tail.output=layer.forward cache (fun _ => input) 0 := by
  have target : layer.out.forward (GatedInputs.flatten (fun head =>
      GatedRmsNorm.value layer.gated
        (GatedDevice.producedOutput layer.recurrence.reduce layer.recurrence.flags cache.recurrent preparation.prepared.values.inputs head)
        (DeltaNet.zHead layer (fun _ => input) 0 head) layer.normWeight layer.headParams.width layer.headParams.eps))=
      layer.forward cache (fun _ => input) 0 := by
    rw [produced_output preparation]
    rfl
  exact tail.output_eq.trans target

theorem tail_state (tail : DeltaTailMemory.Execution tailInput layer.gated layer.headParams.width layer.headParams.eps layer.out) :
    tail.afterState.read=(DeltaCache.after layer cache (fun _ => input) 1).recurrent :=
  tail.state_eq.trans (produced_state preparation)

end Inference.Models.Qwen.DeltaMemoryRefinement
