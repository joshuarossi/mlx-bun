import models.qwen.TokenActivation
import kernels.sampling.GreedyDevice

namespace Inference.Models.Qwen.TokenDevice
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

structure Execution (p : Pipeline) (sampling : LogSumExpRanges.Platform) (cache : p.graph.Cache n)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (storage : DecodeStorage.Storage p.graph.stages cache) where
  inference : TokenActivation.Execution p cache token angle storage
  selection : GreedyDevice.Execution sampling inference.logits
  selectionInput : selection.lse.source=inference.logitsBuffer

def Execution.fromInference (p : Pipeline) (sampling : LogSumExpRanges.Platform) (cache : p.graph.Cache n)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (storage : DecodeStorage.Storage p.graph.stages cache)
    (inference : TokenActivation.Execution p cache token angle storage) : Execution p sampling cache token angle storage :=
  ⟨inference, GreedyDevice.Execution.fromStorage sampling inference.logits inference.logitsBuffer,
    GreedyDevice.Execution.fromStorage_input _ _ _⟩

def Execution.fromStorage (p : Pipeline) (sampling : LogSumExpRanges.Platform) (cache : p.graph.Cache n)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (storage : DecodeStorage.Storage p.graph.stages cache)
    (weights : Layers.QuantizedEmbeddingDevice.Storage p.embedding) : Execution p sampling cache token angle storage :=
  Execution.fromInference p sampling cache token angle storage (TokenActivation.Execution.fromStorage p cache token angle storage weights)

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320} {angle : RopeAngles.Inputs} {storage : DecodeStorage.Storage p.graph.stages cache}

def Execution.run (execution : Execution p sampling cache token angle storage) : Nat × p.graph.Cache (n+1) :=
  (execution.selection.token, execution.inference.run.2)

theorem Execution.run_eq (execution : Execution p sampling cache token angle storage) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧ |Model.toReal ((p.run cache token angle).1 i)| ≤ (2 : ℝ)^(23 : Nat)) :
    execution.run=TokenSampledSequenceRanges.run p sampling cache token angle := by
  have localBound : ∀ i, Model.isFinite (execution.inference.logits i)=true ∧ |Model.toReal (execution.inference.logits i)| ≤ (2 : ℝ)^(23 : Nat) := by
    rw [execution.inference.logits_eq]
    exact bound
  unfold Execution.run
  rw [execution.selection.token_eq primitive localBound, execution.inference.logits_eq]
  rfl

def Execution.after (execution : Execution p sampling cache token angle storage) : DecodeStorage.Storage p.graph.stages execution.run.2 :=
  execution.inference.after

theorem Execution.selection_bytes (execution : Execution p sampling cache token angle storage) :
    execution.selection.lse.source.bytes=execution.inference.projection.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.selectionInput

theorem Execution.token_read (execution : Execution p sampling cache token angle storage) :
    execution.run.1=(ByteMemory.load32 execution.selection.selection.output.memory 0).toNat := execution.selection.token_read

end Inference.Models.Qwen.TokenDevice
