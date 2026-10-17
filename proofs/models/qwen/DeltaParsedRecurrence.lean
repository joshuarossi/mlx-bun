import models.qwen.DeltaMemoryRefinement
import kernels.delta.GatedOutputSource

namespace Inference.Models.Qwen.DeltaParsedRecurrence
open Contracts.Mlx Kernels Kernels.Delta
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000

variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {values : GatedInputs.Values}
  (recurrence : GatedShared.Execution reduce flags initial values)
  {gate : GatedRmsNormDevice.Rows} {weight : Fin 128 → ArrayStorage.BF}
  (input : DeltaTailMemory.Input recurrence gate weight)

theorem source_execution (events : List GatedBytes.Event)
    (inside : ∀ event ∈ events,event ∈ recurrence.stores.trace.schedule) :
    ∃ writes, GatedOutputSource.programs (recurrence.during events inside)
      recurrence.stores.trace.stateBase recurrence.stores.trace.outputBase reduce flags=some writes ∧
      ThreadgroupWrites.Executes writes recurrence.stores.trace.schedule recurrence.stores.trace.remaining ∧
      ThreadgroupWrites.AtBarrier recurrence.stores.trace.remaining :=
  GatedOutputSource.source_execution recurrence events inside

theorem tail_heap : input.normalization.storage.input.bytes=recurrence.stores.memory := rfl

theorem tail_read (head : Fin 48) (row : Fin 128) :
    input.normalization.storage.input.read (GatedInputs.index head row)=
      GatedDevice.producedOutput reduce flags initial values.inputs head row := by
  rw [ArrayStorage.BFBuffer.read_correct,GatedInputs.flatten_index,recurrence.output_eq]

theorem state_heap : recurrence.after.bytes=input.normalization.storage.input.bytes := rfl

theorem state_error (platform : FlushedReduction.SimdContract reduce) (head : Fin 48) (row key : Fin 128)
    (targetState stateError : Fin 128 → ℝ) (target error : Recurrence.Inputs ℝ)
    (hs : ∀ k, |Numerics.real (initial head row k)-targetState k|≤stateError k)
    (hi : Recurrence.InputError (values.inputs head row) target error)
    (finite : Arithmetic.Finite (Recurrence.bind (initial head row) (values.inputs head row))
      (Gated.stateExpr flags platform.tree key)) :
    |Numerics.real (recurrence.after.read head row key)-Recurrence.targetStep targetState target key|≤
      Recurrence.stepBudget platform.tree flags (initial head row) (values.inputs head row)
        targetState stateError target error key := by
  rw [recurrence.after.read_eq,recurrence.state_eq]
  unfold GatedDevice.producedState
  exact Recurrence.step_error reduce platform flags _ _ _ _ _ _ hs hi key finite

section Model
variable {layer : DeltaNet.Layer} {cache : DeltaNet.Cache} {x : Fin 5120 → ArrayStorage.BF}
  {convInput : ConvolutionMemory.Input cache.history (layer.qkv.forward x) layer.convolutionWeight}
  {convolution : ConvolutionMemory.Execution convInput layer.recurrence.convolutionContracted}
  (preparation : DeltaConvolutionMemory.Execution convolution layer.headParams.qScale layer.headParams.kScale
    layer.recurrence.heads layer.headParams.width layer.headParams.eps layer.aLog (layer.a.forward x) layer.dtBias
    (layer.b.forward x) layer.recurrence.gates)
  (run : GatedShared.Execution layer.recurrence.reduce layer.recurrence.flags cache.recurrent preparation.prepared.values)
  (tailInput : DeltaTailMemory.Input run (DeltaNet.zHead layer (fun _ => x) 0) layer.normWeight)

theorem model_tail_read (head : Fin 48) (row : Fin 128) :
    tailInput.normalization.storage.input.read (GatedInputs.index head row)=
      DeltaNet.recurrentOutput layer cache (fun _ => x) 0 head row := by
  rw [tail_read run tailInput,DeltaMemoryRefinement.produced_output preparation]

theorem model_state_read (head : Fin 48) (row key : Fin 128) :
    run.after.read head row key=(DeltaCache.after layer cache (fun _ => x) 1).recurrent head row key := by
  rw [run.after.read_eq,run.state_eq,DeltaMemoryRefinement.produced_state preparation]

theorem model_final_heap (tail : DeltaTailMemory.Execution tailInput layer.gated
    layer.headParams.width layer.headParams.eps layer.out) :
    tail.afterState.bytes=tail.buffer.bytes ∧
      tail.afterState.read=(DeltaCache.after layer cache (fun _ => x) 1).recurrent ∧
      tail.output=layer.forward cache (fun _ => x) 0 :=
  ⟨tail.state_output_shared,DeltaMemoryRefinement.tail_state tail,DeltaMemoryRefinement.tail_forward tail⟩
end Model

end Inference.Models.Qwen.DeltaParsedRecurrence
