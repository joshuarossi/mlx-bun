import models.qwen.NormalizationMemory
import models.qwen.AttentionParameterMemory
import models.qwen.AttentionProjectionHandoff
import models.qwen.ResidualAttention

namespace Inference.Models.Qwen.AttentionNormalizedMemory
open Contracts.Mlx
set_option maxRecDepth 10000

-- The original residual remains live, so this normalization output must
-- be separate from it. The affine phase consumes the stored normalized row.
structure Execution (layer : ResidualAttention.Layer) (input : Fin 5120 → ArrayStorage.BF) where
  source : BinaryMemory.Input input layer.inputNorm.weight
  normalization : NormalizationMemory.Execution layer.inputNorm source
  residualSeparate : MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 source.lhs.base 10240
  affine : AttentionAffineMemory.Execution layer.mixer.projections (layer.inputNorm.forward input)
  linked : affine.source=NormalizationMemory.forwardBuffer normalization
  residualSafe : AttentionAffineMemory.Safe affine source.lhs.base 10240

variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}

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
  MemoryRegions.Disjoint (2*execution.normalization.normalized.base) 10240 base size ∧ AttentionAffineMemory.Safe execution.affine base size

theorem Execution.other_region (execution : Execution layer input) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.affine.memory (base+offset)=execution.source.lhs.bytes (base+offset) :=
  (execution.affine.other_region safe.2 offset bound).trans
    ((congrFun execution.affine_input_bytes _).trans (execution.normalization.other_region safe.1 offset bound))

def Execution.afterCache {n : Nat} (execution : Execution layer input)
    {cache : State.Kv.Cache ArrayStorage.BF n} (storage : State.KvRegions.Storage cache)
    (shared : storage.memory=execution.source.lhs.bytes)
    (keysSafe : Safe execution storage.layout.keyBase (State.KvRegions.bytes n))
    (valuesSafe : Safe execution storage.layout.valueBase (State.KvRegions.bytes n)) : State.KvRegions.Storage cache :=
  storage.reframe execution.affine.memory
    (fun offset bound => (execution.other_region keysSafe offset bound).trans (congrFun shared _).symm)
    (fun offset bound => (execution.other_region valuesSafe offset bound).trans (congrFun shared _).symm)

def Execution.parametersAfter (execution : Execution layer input)
    (parameters : AttentionParameterMemory.Storage layer.mixer execution.source.lhs.bytes)
    (safe : AttentionParameterMemory.Protected parameters (Safe execution)) : AttentionParameterMemory.Storage layer.mixer execution.affine.memory :=
  AttentionParameterMemory.reframe parameters execution.affine.memory
    (AttentionParameterMemory.protected_mono parameters (fun _ _ region => execution.other_region region) safe)

def Execution.retainedCaches {n : Nat} (execution : Execution layer input)
    (stages : List DecodeStage.Stage) (cache : DecodeChain.Caches stages n)
    (storage : DecodeFrame.Storage stages cache execution.source.lhs.bytes)
    (safe : DecodePreservation.Protected (Safe execution) stages cache execution.source.lhs.bytes storage) :
    DecodeFrame.Storage stages cache execution.affine.memory :=
  DecodePreservation.reframe (Safe execution) execution.source.lhs.bytes execution.affine.memory
    (fun _ _ region => execution.other_region region) stages cache storage safe

theorem Execution.normalized_read (execution : Execution layer input) (i : Fin 5120) :
    execution.affine.source.read i=layer.inputNorm.forward input i := execution.affine.source.read_correct i

theorem Execution.residual_read (execution : Execution layer input) (i : Fin 5120) :
    execution.savedResidual.read i=input i := execution.savedResidual.read_correct i

theorem Execution.projected_read (execution : Execution layer input) :
    execution.affine.read=layer.mixer.projections.forward (layer.inputNorm.forward input) :=
  execution.affine.read_eq

theorem Execution.input_address (execution : Execution layer input) :
    execution.affine.source.base=2*execution.normalization.normalized.base :=
  (congrArg ArrayStorage.BFBuffer.base execution.linked).trans
    (NormalizationMemory.forward_base execution.normalization)

-- This constructor consumes an actual normalization execution and a linked
-- affine execution; allocation separation remains an explicit obligation.
def fromPhases (source : BinaryMemory.Input input layer.inputNorm.weight)
    (normalization : NormalizationMemory.Execution layer.inputNorm source)
    (separate : MemoryRegions.Disjoint (2*normalization.normalized.base) 10240 source.lhs.base 10240)
    (affine : AttentionAffineMemory.Execution layer.mixer.projections (layer.inputNorm.forward input))
    (linked : affine.source=NormalizationMemory.forwardBuffer normalization)
    (residualSafe : AttentionAffineMemory.Safe affine source.lhs.base 10240) : Execution layer input :=
  ⟨source, normalization, separate, affine, linked, residualSafe⟩

end Inference.Models.Qwen.AttentionNormalizedMemory
