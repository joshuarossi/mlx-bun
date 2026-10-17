import models.qwen.NormalizationDevice
import models.qwen.ResidualMlpDevice
import models.qwen.AttentionDevice
import models.qwen.ResidualAttention

namespace Inference.Models.Qwen.ResidualAttentionDevice
open Contracts.Mlx Kernels.Attention
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

structure Execution (b : ResidualAttention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) where
  normalization : NormalizationDevice.Execution b.inputNorm input
  mixer : AttentionDevice.Execution b.mixer (b.inputNorm.forward input) angle cache
  mixerInput : AttentionDevice.inputStorage mixer=NormalizationDevice.forwardBuffer b.inputNorm input normalization
  suffix : ResidualMlpDevice.Execution b.suffix input (AttentionDevice.forward b.mixer (b.inputNorm.forward input) angle cache mixer)
  residualInput : suffix.normalization.source=normalization.source
  residualUpdate : suffix.normalization.update=AttentionDevice.outputStorage b.mixer (b.inputNorm.forward input) angle cache mixer

def Execution.fromMixer (b : ResidualAttention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n)
    (normalization : NormalizationDevice.Execution b.inputNorm input)
    (mixer : AttentionDevice.Execution b.mixer (b.inputNorm.forward input) angle cache)
    (mixerInput : AttentionDevice.inputStorage mixer=NormalizationDevice.forwardBuffer b.inputNorm input normalization)
    (suffixWeights : ArrayStorage.BFBuffer b.suffix.norm.weight) : Execution b input angle cache :=
  let suffix := ResidualMlpDevice.Execution.fromStorage b.suffix input _ normalization.source
    (AttentionDevice.outputStorage b.mixer (b.inputNorm.forward input) angle cache mixer) suffixWeights
  ⟨normalization, mixer, mixerInput, suffix, rfl, rfl⟩

theorem mixer_fromBuffers_input (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (storage : State.KvAllocation.Storage cache) (source : ArrayStorage.BFBuffer input)
    (weights : AttentionAffine.Weights layer.projections) (outputWeights : Layers.AffineDevice.Storage layer.output) :
    AttentionDevice.inputStorage (AttentionDevice.Execution.fromBuffers layer input angle cache storage source weights outputWeights)=source := rfl

def Execution.fromNormalization (b : ResidualAttention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (storage : State.KvAllocation.Storage cache)
    (normalization : NormalizationDevice.Execution b.inputNorm input)
    (weights : AttentionAffine.Weights b.mixer.projections) (outputWeights : Layers.AffineDevice.Storage b.mixer.output)
    (suffixWeights : ArrayStorage.BFBuffer b.suffix.norm.weight) : Execution b input angle cache :=
  Execution.fromMixer b input angle cache normalization
    (AttentionDevice.Execution.fromBuffers b.mixer (b.inputNorm.forward input) angle cache storage
      (NormalizationDevice.forwardBuffer b.inputNorm input normalization) weights outputWeights)
    (mixer_fromBuffers_input _ _ _ _ _ _ _ _) suffixWeights

def Execution.fromStorage (b : ResidualAttention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (storage : State.KvAllocation.Storage cache)
    (source : ArrayStorage.BFBuffer input) : Execution b input angle cache :=
  Execution.fromNormalization b input angle cache storage
    (NormalizationDevice.fromStorage b.inputNorm input source (ArrayStorage.BFBuffer.canonical _ (by decide)))
    (AttentionAffine.Weights.canonical b.mixer.projections)
    (Layers.AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide)) (ArrayStorage.BFBuffer.canonical _ (by decide))

variable {n : Nat} {b : ResidualAttention.Layer} {input : Fin 5120 → BF} {angle : RopeAngles.Inputs} {cache : State.Kv.Cache BF n}

def Execution.output (execution : Execution b input angle cache) : Fin 5120 → BF := execution.suffix.output
def Execution.outputBuffer (execution : Execution b input angle cache) : ArrayStorage.BFBuffer execution.output := execution.suffix.outputBuffer

theorem Execution.output_eq (execution : Execution b input angle cache) : execution.output=b.forward input angle cache := by
  unfold Execution.output
  rw [execution.suffix.output_eq, AttentionDevice.forward_eq]
  rfl

def Execution.cacheAfter (execution : Execution b input angle cache) : State.Kv.Cache BF (n+1) :=
  State.KvBytes.cacheAfter execution.mixer.updated.toKvBytes

def Execution.storageAfter (execution : Execution b input angle cache) : State.KvAllocation.Storage execution.cacheAfter := by
  have same : execution.cacheAfter=b.cacheAfter input angle cache := State.KvBytes.cacheAfter_eq execution.mixer.updated.toKvBytes
  exact same.symm ▸ execution.mixer.updated.after

theorem Execution.cache_eq (execution : Execution b input angle cache) : execution.cacheAfter=b.cacheAfter input angle cache :=
  State.KvBytes.cacheAfter_eq execution.mixer.updated.toKvBytes

theorem Execution.mixer_input_bytes (execution : Execution b input angle cache) :
    (AttentionDevice.inputStorage execution.mixer).bytes=execution.normalization.stores.memory := by
  rw [execution.mixerInput, NormalizationDevice.forward_bytes]

theorem Execution.residual_input_bytes (execution : Execution b input angle cache) :
    execution.suffix.normalization.source.bytes=execution.normalization.source.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.residualInput

theorem Execution.residual_update_bytes (execution : Execution b input angle cache) :
    execution.suffix.normalization.update.bytes=execution.mixer.projection.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.residualUpdate

theorem Execution.output_bytes (execution : Execution b input angle cache) :
    execution.outputBuffer.bytes=execution.suffix.addition.stores.memory := rfl

theorem Execution.fromStorage_input (b : ResidualAttention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (storage : State.KvAllocation.Storage cache) (source : ArrayStorage.BFBuffer input) :
    (Execution.fromStorage b input angle cache storage source).normalization.source=source := rfl

theorem Execution.fromStorage_cache (b : ResidualAttention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (storage : State.KvAllocation.Storage cache) (source : ArrayStorage.BFBuffer input) :
    (Execution.fromStorage b input angle cache storage source).mixer.storage=storage := rfl

end Inference.Models.Qwen.ResidualAttentionDevice
