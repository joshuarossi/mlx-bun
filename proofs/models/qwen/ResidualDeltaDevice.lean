import models.qwen.NormalizationDevice
import models.qwen.ResidualMlpDevice
import models.qwen.DeltaDevice
import models.qwen.ResidualDelta

namespace Inference.Models.Qwen.ResidualDeltaDevice
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

structure Execution (b : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache) where
  normalization : NormalizationDevice.Execution b.inputNorm input
  mixer : DeltaDevice.Execution b.mixer (b.inputNorm.forward input) cache
  mixerInput : DeltaDevice.inputStorage mixer=NormalizationDevice.forwardBuffer b.inputNorm input normalization
  suffix : ResidualMlpDevice.Execution b.suffix input (DeltaDevice.forward b.mixer (b.inputNorm.forward input) cache mixer)
  residualInput : suffix.normalization.source=normalization.source
  residualUpdate : suffix.normalization.update=DeltaDevice.outputStorage b.mixer (b.inputNorm.forward input) cache mixer

def Execution.fromNormalization (b : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (storage : DeltaDevice.Storage cache) (normalization : NormalizationDevice.Execution b.inputNorm input)
    (weights : DeltaAffine.Weights b.mixer) (suffixWeights : ArrayStorage.BFBuffer b.suffix.norm.weight) : Execution b input cache :=
  let mixer := DeltaDevice.Execution.fromBuffers b.mixer (b.inputNorm.forward input) cache storage
    (NormalizationDevice.forwardBuffer b.inputNorm input normalization) weights
  let suffix := ResidualMlpDevice.Execution.fromStorage b.suffix input _ normalization.source
    (DeltaDevice.outputStorage b.mixer (b.inputNorm.forward input) cache mixer) suffixWeights
  ⟨normalization, mixer, DeltaDevice.fromBuffers_input _ _ _ _ _ _, suffix, rfl, rfl⟩

def Execution.fromStorage (b : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (storage : DeltaDevice.Storage cache) (source : ArrayStorage.BFBuffer input) : Execution b input cache :=
  Execution.fromNormalization b input cache storage
    (NormalizationDevice.fromStorage b.inputNorm input source (ArrayStorage.BFBuffer.canonical _ (by decide)))
    (DeltaAffine.Weights.canonical b.mixer) (ArrayStorage.BFBuffer.canonical _ (by decide))

variable {b : ResidualDelta.Layer} {input : Fin 5120 → BF} {cache : DeltaNet.Cache}

def Execution.output (execution : Execution b input cache) : Fin 5120 → BF := execution.suffix.output
def Execution.outputBuffer (execution : Execution b input cache) : ArrayStorage.BFBuffer execution.output := execution.suffix.outputBuffer

theorem Execution.output_eq (execution : Execution b input cache) :
    execution.output=b.forward cache (fun _ => input) 0 := by
  unfold Execution.output
  rw [execution.suffix.output_eq, DeltaDevice.forward_eq]
  rfl

def Execution.cacheAfter (execution : Execution b input cache) : DeltaNet.Cache :=
  DeltaDevice.cacheAfter b.mixer (b.inputNorm.forward input) cache execution.mixer

def Execution.storageAfter (execution : Execution b input cache) : DeltaDevice.Storage execution.cacheAfter :=
  DeltaDevice.storageAfter b.mixer (b.inputNorm.forward input) cache execution.mixer

theorem Execution.cache_eq (execution : Execution b input cache) : execution.cacheAfter=b.cacheAfter cache (fun _ => input) 1 :=
  DeltaDevice.cache_eq b.mixer (b.inputNorm.forward input) cache execution.mixer

theorem Execution.mixer_input_bytes (execution : Execution b input cache) :
    (DeltaDevice.inputStorage execution.mixer).bytes=execution.normalization.stores.memory := by
  rw [execution.mixerInput, NormalizationDevice.forward_bytes]

theorem Execution.residual_input_bytes (execution : Execution b input cache) :
    execution.suffix.normalization.source.bytes=execution.normalization.source.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.residualInput

theorem Execution.residual_update_bytes (execution : Execution b input cache) :
    execution.suffix.normalization.update.bytes=execution.mixer.projection.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.residualUpdate

theorem Execution.output_bytes (execution : Execution b input cache) :
    execution.outputBuffer.bytes=execution.suffix.addition.stores.memory := rfl

theorem Execution.fromStorage_input (b : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (storage : DeltaDevice.Storage cache) (source : ArrayStorage.BFBuffer input) :
    (Execution.fromStorage b input cache storage source).normalization.source=source := rfl

theorem Execution.fromStorage_cache (b : ResidualDelta.Layer) (input : Fin 5120 → BF) (cache : DeltaNet.Cache)
    (storage : DeltaDevice.Storage cache) (source : ArrayStorage.BFBuffer input) :
    (Execution.fromStorage b input cache storage source).mixer.storage=storage := rfl

end Inference.Models.Qwen.ResidualDeltaDevice
