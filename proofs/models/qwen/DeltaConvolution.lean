import models.qwen.DeltaExecution
import kernels.delta.GatedInputs
import kernels.delta.ConvolutionDevice
import layers.DeltaHeadsDevice
import contracts.mlx.ArrayViews
import models.qwen.DeltaAffine
import kernels.delta.GateDevice

namespace Inference.Models.Qwen.DeltaConvolution
open Contracts.Mlx Kernels.Delta
abbrev BF := BFloat16Arithmetic.Value
set_option maxRecDepth 10000

structure Execution (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache) where
  projections : DeltaAffine.Inputs layer input
  convolution : ConvolutionDevice.Execution layer.recurrence.convolutionContracted cache.history (layer.qkv.forward input) layer.convolutionWeight
  projectionBuffer : convolution.convolution.source=projections.qkv.forwardBuffer
  heads : Layers.DeltaHeadsDevice.Execution layer.recurrence.heads layer.headParams.width layer.headParams.eps
    convolution.output layer.headParams.qScale layer.headParams.kScale
  inputBuffer : heads.storage.input=ArrayViews.readback convolution.stores.buffer
  gates : GateDevice.Execution layer.recurrence.gates layer.aLog (layer.a.forward input) layer.dtBias (layer.b.forward input)
  gateA : gates.storage.projectionA=projections.a.forwardBuffer
  gateB : gates.storage.projectionB=projections.b.forwardBuffer

def Execution.fromBuffers (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (storage : State.ConvolutionStorage.Storage cache.history) (source : ArrayStorage.BFBuffer input)
    (weights : DeltaAffine.Weights layer) : Execution layer input cache :=
  let projections := DeltaAffine.Inputs.fromStorage layer input source weights
  let next := projections.qkv.forwardBuffer
  let joined := State.ConvolutionStorage.JoinTrace.canonical cache.history (layer.qkv.forward input) storage next
  let window : State.ConvolutionStorage.Execution cache.history (layer.qkv.forward input) :=
    ⟨storage, next, joined, Copy1D.Trace.canonical joined.memory 20480 1 30720 (by decide)⟩
  let weight := ArrayStorage.BFBuffer.canonical (ConvolutionDevice.weightWords layer.convolutionWeight) (by decide)
  let convolution : ConvolutionDevice.Execution layer.recurrence.convolutionContracted cache.history (layer.qkv.forward input) layer.convolutionWeight :=
    ⟨window, weight, HalfArrayWrites.Trace.canonical _ (by decide)⟩
  let inputs : Layers.DeltaHeadsDevice.Storage convolution.output layer.headParams.qScale layer.headParams.kScale :=
    ⟨ArrayViews.readback convolution.stores.buffer, ArrayStorage.BFBuffer.canonical _ (by decide), ArrayStorage.BFBuffer.canonical _ (by decide)⟩
  let gateStorage : GateDevice.Storage layer.aLog (layer.a.forward input) layer.dtBias (layer.b.forward input) :=
    ⟨ArrayStorage.BFBuffer.canonical _ (by decide), projections.a.forwardBuffer,
      ArrayStorage.BFBuffer.canonical _ (by decide), projections.b.forwardBuffer⟩
  ⟨projections, convolution, rfl, Layers.DeltaHeadsDevice.Execution.fromStorage _ _ _ _ _ _ inputs, rfl,
    GateDevice.Execution.fromStorage _ _ _ _ _ gateStorage, rfl, rfl⟩

def Execution.fromStorage (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (storage : State.ConvolutionStorage.Storage cache.history) : Execution layer input cache :=
  Execution.fromBuffers layer input cache storage (ArrayStorage.BFBuffer.canonical _ (by decide)) (DeltaAffine.Weights.canonical layer)

theorem output_eq (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) :
    execution.convolution.output=State.Ssm.convolved layer.recurrence (DeltaNet.convData layer cache (fun _ => input)) 0 := by
  funext channel
  exact execution.convolution.window_eq channel

def heads (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) : Layers.DeltaHeads.Output 1 BF := execution.heads.output

theorem heads_eq (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) :
    heads layer input cache execution=State.Ssm.heads layer.recurrence layer.headParams (DeltaNet.convData layer cache (fun _ => input)) 0 := by
  unfold heads
  rw [execution.heads.output_eq, output_eq]
  rfl

@[irreducible] def inputValues (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) : GatedInputs.Values :=
  let h := heads layer input cache execution
  { key := h.k 0
    query := h.q 0
    value := h.v 0
    decay := execution.gates.decay
    beta := execution.gates.beta }

theorem inputs_eq (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) :
    (inputValues layer input cache execution).inputs=(fun head row => DeltaNet.inputs layer cache (fun _ => input) head row 0) := by
  unfold inputValues
  rw [heads_eq, execution.gates.decay_eq, execution.gates.beta_eq]
  unfold GatedInputs.Values.inputs DeltaNet.inputs State.Ssm.inputs Kernels.Delta.Inputs.actual State.Ssm.projected
  rfl

theorem history_eq (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) : execution.convolution.retained=(DeltaCache.after layer cache (fun _ => input) 1).history := by
  rw [execution.convolution.history_eq]
  funext row channel
  unfold DeltaCache.after Convolution.tail Convolution.joined
  by_cases h : 1+row.val<3 <;> simp only [h, ↓reduceDIte]

def inputStorage (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) : GatedInputs.Storage (inputValues layer input cache execution) := by
  unfold inputValues
  exact ⟨execution.heads.keyBuffer, execution.heads.queryBuffer, execution.heads.valueBuffer,
    execution.gates.decayBuffer, execution.gates.betaBuffer⟩

theorem head_input_bytes (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) : execution.heads.storage.input.bytes=execution.convolution.stores.memory :=
  congrArg ArrayStorage.BFBuffer.bytes execution.inputBuffer

theorem key_bytes (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) : (inputStorage layer input cache execution).key.bytes=execution.heads.kStores.memory := by
  unfold inputStorage
  rfl

theorem projection_bytes (execution : Execution layer input cache) :
    execution.convolution.convolution.source.bytes=execution.projections.qkv.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.projectionBuffer

theorem gate_projection_bytes (execution : Execution layer input cache) :
    execution.gates.storage.projectionA.bytes=execution.projections.a.outputBuffer.bytes ∧
    execution.gates.storage.projectionB.bytes=execution.projections.b.outputBuffer.bytes :=
  ⟨congrArg ArrayStorage.BFBuffer.bytes execution.gateA, congrArg ArrayStorage.BFBuffer.bytes execution.gateB⟩

theorem gate_output_bytes (layer : DeltaNet.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (execution : Execution layer input cache) :
    (inputStorage layer input cache execution).decay.bytes=execution.gates.decayStores.memory ∧
    (inputStorage layer input cache execution).beta.bytes=execution.gates.betaStores.memory := by
  unfold inputStorage
  exact ⟨rfl, rfl⟩

end Inference.Models.Qwen.DeltaConvolution
