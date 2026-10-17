import models.qwen.NormalizationMemory
import models.qwen.DeltaParameterMemory
import models.qwen.DeltaProjectionHandoff
import models.qwen.ResidualDelta

namespace Inference.Models.Qwen.DeltaNormalizedMemory
open Contracts.Mlx
set_option maxRecDepth 10000

-- The original residual remains live, so this normalization output must
-- be separate from it. The affine phase consumes the stored normalized row.
structure Execution (layer : ResidualDelta.Layer) (input : Fin 5120 → ArrayStorage.BF) where
  source : BinaryMemory.Input input layer.inputNorm.weight
  normalization : NormalizationMemory.Execution layer.inputNorm source
  residualSeparate : MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 source.lhs.base 10240
  affine : DeltaAffineMemory.Execution layer.mixer (layer.inputNorm.forward input)
  linked : affine.source=NormalizationMemory.forwardBuffer normalization
  residualSafe : DeltaAffineMemory.Safe affine source.lhs.base 10240

variable {layer : ResidualDelta.Layer} {input : Fin 5120 → ArrayStorage.BF}

theorem Execution.affine_input_bytes (execution : Execution layer input) :
    execution.affine.source.bytes=execution.normalization.outputBuffer.bytes :=
  (congrArg ArrayStorage.BFBuffer.bytes execution.linked).trans (NormalizationMemory.forward_bytes execution.normalization)

def Execution.savedResidual (execution : Execution layer input) : ArrayStorage.BFBuffer input :=
  ArrayFrame.bf execution.source.lhs execution.affine.memory (by
    intro offset bound
    have affine := execution.affine.other_region execution.residualSafe offset bound
    rw [execution.affine_input_bytes] at affine
    exact affine.trans (execution.normalization.other_region execution.residualSeparate offset bound))

theorem Execution.residual_memory (execution : Execution layer input) : execution.savedResidual.bytes=execution.affine.memory := rfl

def Safe (execution : Execution layer input) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint (2*execution.normalization.normalized.base) 10240 base size ∧ DeltaAffineMemory.Safe execution.affine base size

theorem Execution.other_region (execution : Execution layer input) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.affine.memory (base+offset)=execution.source.lhs.bytes (base+offset) :=
  (execution.affine.other_region safe.2 offset bound).trans
    ((congrFun execution.affine_input_bytes _).trans (execution.normalization.other_region safe.1 offset bound))

def Execution.afterCache (execution : Execution layer input) {cache : DeltaNet.Cache} (storage : DeltaRegions.Storage cache)
    (shared : storage.memory=execution.source.lhs.bytes)
    (historySafe : Safe execution storage.buffers.history.base 61440)
    (stateSafe : Safe execution storage.buffers.recurrent.base 3145728) : DeltaRegions.Storage cache :=
  storage.reframe execution.affine.memory
    (fun offset bound => (execution.other_region historySafe offset bound).trans (congrFun shared _).symm)
    (fun offset bound => (execution.other_region stateSafe offset bound).trans (congrFun shared _).symm)

def Execution.parametersAfter (execution : Execution layer input)
    (parameters : DeltaParameterMemory.Storage layer.mixer execution.source.lhs.bytes)
    (safe : DeltaParameterMemory.Protected parameters (Safe execution)) : DeltaParameterMemory.Storage layer.mixer execution.affine.memory :=
  DeltaParameterMemory.reframe parameters execution.affine.memory
    (DeltaParameterMemory.protected_mono parameters (fun _ _ region => execution.other_region region) safe)

def Execution.retainedCaches {n : Nat} (execution : Execution layer input)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages cache execution.source.lhs.bytes)
    (safe : DecodePreservation.Protected (Safe execution) stages cache execution.source.lhs.bytes storage) :
    DecodeFrame.Storage stages cache execution.affine.memory :=
  DecodePreservation.reframe (Safe execution) execution.source.lhs.bytes execution.affine.memory
    (fun _ _ region => execution.other_region region) stages cache storage safe

theorem Execution.normalized_read (execution : Execution layer input) (i : Fin 5120) :
    execution.affine.inputAfter.read i=layer.inputNorm.forward input i := execution.affine.inputAfter.read_correct i

end Inference.Models.Qwen.DeltaNormalizedMemory
