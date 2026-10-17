import models.qwen.DeltaNormalizedMemory
import models.qwen.DeltaMemoryRefinement

namespace Inference.Models.Qwen.ResidualDeltaMemory
open Contracts.Mlx Kernels Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- All phases operate on successive versions of the same heap. Allocation
-- separation and the attachment of loaded parameters remain input contracts.
structure Execution (layer : ResidualDelta.Layer) (cache : DeltaNet.Cache)
    (input : Fin 5120 → ArrayStorage.BF) where
  entry : DeltaNormalizedMemory.Execution layer input
  storage : DeltaRegions.Storage cache
  shared : storage.memory=entry.source.lhs.bytes
  historySafe : DeltaNormalizedMemory.Safe entry storage.buffers.history.base 61440
  stateSafe : DeltaNormalizedMemory.Safe entry storage.buffers.recurrent.base 3145728
  parameters : DeltaParameterMemory.Storage layer.mixer entry.source.lhs.bytes
  parameterSafe : DeltaParameterMemory.Protected parameters (DeltaNormalizedMemory.Safe entry)
  window : ConvolutionMemory.Input cache.history (layer.mixer.qkv.forward (layer.inputNorm.forward input)) layer.mixer.convolutionWeight
  historyLinked : window.window.joined.old=(entry.afterCache storage shared historySafe stateSafe).buffers.history
  qkvLinked : window.window.joined.source=entry.affine.qkvBuffer
  convolutionWeights : window.weight=(entry.parametersAfter parameters parameterSafe).convolution
  convolution : ConvolutionMemory.Execution window layer.mixer.recurrence.convolutionContracted
  preparation : DeltaConvolutionMemory.Execution convolution layer.mixer.headParams.qScale layer.mixer.headParams.kScale
    layer.mixer.recurrence.heads layer.mixer.headParams.width layer.mixer.headParams.eps
    layer.mixer.aLog (layer.mixer.a.forward (layer.inputNorm.forward input)) layer.mixer.dtBias
    (layer.mixer.b.forward (layer.inputNorm.forward input)) layer.mixer.recurrence.gates
  queryScaleLinked : preparation.scales.query=(entry.parametersAfter parameters parameterSafe).queryScale
  keyScaleLinked : preparation.scales.key=(entry.parametersAfter parameters parameterSafe).keyScale
  gatesLinked : preparation.gateSource=DeltaParameterMemory.gateInput entry.affine (entry.parametersAfter parameters parameterSafe)
  block : DeltaBlockMemory.Execution preparation cache.recurrent layer.mixer.recurrence.reduce layer.mixer.recurrence.flags
    (DeltaNet.zHead layer.mixer (fun _ => layer.inputNorm.forward input) 0) layer.mixer.normWeight
    layer.mixer.gated layer.mixer.out layer.suffix input
  stateLinked : block.state=(entry.afterCache storage shared historySafe stateSafe).buffers.recurrent
  residualLinked : block.source=entry.savedResidual
  gateSafe : DeltaConvolutionMemory.Safe preparation entry.affine.gateBuffer.base 12288
  normSafe : DeltaConvolutionMemory.Safe preparation (entry.parametersAfter parameters parameterSafe).normalization.base 256
  gateBase : block.tailInput.gate.base=entry.affine.gateBuffer.base
  normBase : block.tailInput.weight.base=(entry.parametersAfter parameters parameterSafe).normalization.base

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}

theorem Execution.window_memory (execution : Execution layer cache input) :
    execution.window.window.joined.old.bytes=execution.entry.affine.memory :=
  congrArg ArrayStorage.BFBuffer.bytes execution.historyLinked

def Execution.output (execution : Execution layer cache input) : Fin 5120 → ArrayStorage.BF := execution.block.output

def Execution.outputBuffer (execution : Execution layer cache input) : ArrayStorage.BFBuffer execution.output :=
  execution.block.outputBuffer

theorem Execution.output_eq (execution : Execution layer cache input) :
    execution.output=layer.forward cache (fun _ => input) 0 :=
  execution.block.suffix.suffix.output_eq.trans
    (congrArg (layer.suffix.forward input) (DeltaMemoryRefinement.tail_forward execution.block.tail))

def Execution.cacheAfter (execution : Execution layer cache input) : DeltaNet.Cache :=
  ⟨Convolution.tail cache.history (fun _ => layer.mixer.qkv.forward (layer.inputNorm.forward input)) 1,
    execution.block.recurrence.state⟩

def Execution.afterCache (execution : Execution layer cache input) : DeltaRegions.Storage execution.cacheAfter :=
  execution.block.afterCache

theorem Execution.cache_eq (execution : Execution layer cache input) :
    execution.cacheAfter=layer.cacheAfter cache (fun _ => input) 1 := by
  have recurrent := execution.block.recurrence.state_eq.trans (DeltaMemoryRefinement.produced_state execution.preparation)
  change DeltaNet.Cache.mk _ execution.block.recurrence.state=DeltaNet.Cache.mk _ _
  congr 1
  funext i c
  simp only [Convolution.tail, Convolution.joined, ResidualDelta.Layer.normalized]
  split <;> simp_all

theorem Execution.cache_output_shared (execution : Execution layer cache input) :
    execution.afterCache.memory=execution.outputBuffer.bytes := rfl

def Execution.readCache (execution : Execution layer cache input) : DeltaNet.Cache where
  history row channel := execution.afterCache.buffers.history.read (State.ConvolutionStorage.index row channel)
  recurrent := execution.afterCache.buffers.recurrent.read

theorem Execution.read_cache_eq (execution : Execution layer cache input) :
    execution.readCache=layer.cacheAfter cache (fun _ => input) 1 := by
  have attached : execution.readCache=execution.cacheAfter := by
    change DeltaNet.Cache.mk _ _=DeltaNet.Cache.mk _ _
    congr 1
    · funext row channel
      exact (execution.afterCache.buffers.history.read_correct _).trans (State.ConvolutionStorage.flatten_index _ row channel)
    · exact execution.afterCache.buffers.recurrent.read_eq
  exact attached.trans execution.cache_eq

def Execution.forwardBuffer (execution : Execution layer cache input) :
    ArrayStorage.BFBuffer (layer.forward cache (fun _ => input) 0) where
  bytes := execution.outputBuffer.bytes
  base := execution.outputBuffer.base
  aligned := execution.outputBuffer.aligned
  bounded := execution.outputBuffer.bounded
  attached := by
    intro i
    rw [← execution.output_eq]
    exact execution.outputBuffer.attached i

def Safe (execution : Execution layer cache input) (base size : Nat) : Prop :=
  DeltaNormalizedMemory.Safe execution.entry base size ∧ DeltaBlockMemory.Safe execution.block base size

theorem Execution.other_region (execution : Execution layer cache input) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=execution.entry.source.lhs.bytes (base+offset) :=
  (execution.block.other_region safe.2 offset bound).trans
    ((congrFun execution.window_memory _).trans (execution.entry.other_region safe.1 offset bound))

-- The Z gate and norm scale retain their original addresses and values
-- across convolution, head construction and decay/beta preparation.
theorem Execution.gate_preserved (execution : Execution layer cache input) (offset : Nat) (bound : offset<12288) :
    execution.block.tailInput.gate.bytes (execution.block.tailInput.gate.base+offset)=
      execution.entry.affine.gateBuffer.bytes (execution.entry.affine.gateBuffer.base+offset) := by
  rw [execution.block.tailInput.gateShared, execution.block.input_memory, execution.gateBase]
  exact (execution.preparation.other_region execution.gateSafe offset bound).trans (congrFun execution.window_memory _)

theorem Execution.norm_preserved (execution : Execution layer cache input) (offset : Nat) (bound : offset<256) :
    execution.block.tailInput.weight.bytes (execution.block.tailInput.weight.base+offset)=
      (execution.entry.parametersAfter execution.parameters execution.parameterSafe).normalization.bytes
        ((execution.entry.parametersAfter execution.parameters execution.parameterSafe).normalization.base+offset) := by
  rw [execution.block.tailInput.weightShared, execution.block.input_memory, execution.normBase]
  exact (execution.preparation.other_region execution.normSafe offset bound).trans (congrFun execution.window_memory _)

def Execution.retainedCaches {n : Nat} (execution : Execution layer cache input)
    (stages : List DecodeStage.Stage) (retained : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages retained execution.entry.source.lhs.bytes)
    (safe : DecodePreservation.Protected (Safe execution) stages retained execution.entry.source.lhs.bytes storage) :
    DecodeFrame.Storage stages retained execution.outputBuffer.bytes :=
  DecodePreservation.reframe (Safe execution) execution.entry.source.lhs.bytes execution.outputBuffer.bytes
    (fun _ _ region => execution.other_region region) stages retained storage safe

-- The numerical budget now bounds the values read from the completed heap,
-- including the recurrent cache that will feed the next invocation.
theorem Execution.output_error (execution : Execution layer cache input)
    (targetCache errorCache : DeltaNet.ReferenceCache) (hc : DeltaNet.CacheError cache targetCache errorCache)
    (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (input i)-target t i| ≤ error t i)
    (hf : layer.Finite cache (fun _ => input) 0)
    (capacity : layer.Capacity cache targetCache errorCache (fun _ => input) target error 0 hf) (i : Fin 5120) :
    |Model.toReal (execution.outputBuffer.read i)-layer.target targetCache target 0 i| ≤
      layer.budget cache targetCache errorCache (fun _ => input) target error 0 hf i := by
  rw [execution.outputBuffer.read_correct, execution.output_eq]
  exact layer.forward_error cache targetCache errorCache hc (fun _ => input) target error hi 0 hf capacity i

theorem Execution.cache_error (execution : Execution layer cache input)
    (targetCache errorCache : DeltaNet.ReferenceCache) (hc : DeltaNet.CacheError cache targetCache errorCache)
    (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (input i)-target t i| ≤ error t i)
    (hf : layer.Finite cache (fun _ => input) 0) :
    DeltaNet.CacheError execution.readCache (layer.targetCacheAfter targetCache target 1)
      (layer.cacheBudget cache targetCache errorCache (fun _ => input) target error 1) := by
  rw [execution.read_cache_eq]
  exact layer.cache_error cache targetCache errorCache hc (fun _ => input) target error hi 0 hf

end Inference.Models.Qwen.ResidualDeltaMemory
