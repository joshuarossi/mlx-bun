import models.qwen.DeltaPreparationConstruction
import kernels.delta.MlxDepthwiseConvMemory
import kernels.delta.ConvolutionBounds
namespace Inference.Models.Qwen.DeltaConvolutionParsedSource
open Contracts.Mlx Kernels.Delta
open FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
set_option maxRecDepth 10000

variable {history : Inference.State.ConvolutionStorage.History} {next : Fin 10240→ArrayStorage.BF}
    {weights : Fin 10240→Fin 4→ArrayStorage.BF} {input : ConvolutionMemory.Input history next weights}
    {contracted : Bool} (execution : ConvolutionMemory.Execution input contracted)

def value (channel : Fin 10240) : ArrayStorage.BF :=
  Model.ofBits (HalfMemory.load execution.stores.memory (execution.base+2*channel.val))

theorem source : MlxDepthwiseConvMemory.Certificate execution := MlxDepthwiseConvMemory.checked execution

theorem value_eq (channel : Fin 10240) : value execution channel=
    Convolution.value contracted (fun tap=>Convolution.streamWindow history next tap channel) (weights channel) := by
  unfold value
  rw [(source execution).readback channel]
  rfl

theorem output_buffer (channel : Fin 10240) : execution.outputBuffer.read channel=value execution channel := by
  rw [MlxDepthwiseConvMemory.readback execution,value_eq execution]

-- The same completed source heap is the heads consumer's activation buffer.
-- No replacement values or expected head outputs are accepted by this join.
theorem head_input {qScale kScale : Fin 128→ArrayStorage.BF}
    (scales : DeltaConvolutionMemory.Scales execution qScale kScale) (channel : Fin 10240) :
    scales.headInput.storage.input.read channel=value execution channel := output_buffer execution channel

theorem readback_error (profile : ConvolutionBounds.Profile) (channel : Fin 10240)
    (targetInput targetWeight inputError weightError : Fin 4→ℝ)
    (inputRange : ∀ tap,Model.isFinite (Convolution.streamWindow history next tap channel)=true ∧
      |Model.toReal (Convolution.streamWindow history next tap channel)|≤Contracts.Mlx.Numerics.real profile.inputCap)
    (weightRange : ∀ tap,Model.isFinite (weights channel tap)=true ∧
      |Model.toReal (weights channel tap)|≤Contracts.Mlx.Numerics.real profile.weightCap)
    (inputBound : ∀ tap,|Model.toReal (Convolution.streamWindow history next tap channel)-targetInput tap|≤ inputError tap)
    (weightBound : ∀ tap,|Model.toReal (weights channel tap)-targetWeight tap|≤ weightError tap) :
    Model.isFinite (value execution channel)=true ∧
    |Model.toReal (value execution channel)|≤Model.toReal profile.storeCap ∧
    |Model.toReal (value execution channel)-∑ tap,targetInput tap*targetWeight tap|≤
      Convolution.budget contracted (fun tap=>Convolution.streamWindow history next tap channel) (weights channel)
        targetInput targetWeight inputError weightError := by
  rw [value_eq execution]
  exact profile.accuracy contracted _ _ targetInput targetWeight inputError weightError inputRange weightRange inputBound weightBound

variable {layer : DeltaNet.Layer} {activation : Fin 5120→ArrayStorage.BF} {cache : DeltaNet.Cache}
    (phase : DeltaAffineMemory.Execution layer activation) (storage : DeltaRegions.Storage cache)
    (parameters : DeltaParameterMemory.Storage layer phase.memory) (shared : storage.memory=phase.memory)
    (allocation : DeltaPreparationConstruction.ConvolutionAllocation phase storage parameters)

theorem constructed_source : MlxDepthwiseConvMemory.Certificate
    (DeltaPreparationConstruction.convolved phase storage parameters shared allocation) :=
  MlxDepthwiseConvMemory.checked _

theorem constructed_output (channel : Fin 10240) :
    value (DeltaPreparationConstruction.convolved phase storage parameters shared allocation) channel=
      Convolution.value layer.recurrence.convolutionContracted
        (fun tap=>Convolution.streamWindow cache.history (layer.qkv.forward activation) tap channel) (layer.convolutionWeight channel) :=
  value_eq _ channel

-- This theorem specializes the source readback to the exact constructed
-- preparation object, retaining its original convolution and scale buffers.
theorem constructed_head_input
    (preparation : DeltaPreparationConstruction.PreparationAllocation phase storage parameters shared allocation)
    (channel : Fin 10240) :
    (DeltaPreparationConstruction.fromStorage phase storage parameters shared allocation preparation).scales.headInput.storage.input.read channel=
      value (DeltaPreparationConstruction.convolved phase storage parameters shared allocation) channel :=
  output_buffer _ channel
end Inference.Models.Qwen.DeltaConvolutionParsedSource
