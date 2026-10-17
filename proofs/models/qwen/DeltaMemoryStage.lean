import models.qwen.ResidualDeltaMemory

namespace Inference.Models.Qwen.DeltaMemoryStage
open Contracts.Mlx DecodeStage
set_option maxRecDepth 10000

private def reindex {first second : DeltaNet.Cache} (equal : first=second)
    (storage : DeltaRegions.Storage first) : DeltaRegions.Storage second := by
  cases equal
  exact storage

private theorem reindex_memory {first second : DeltaNet.Cache} (equal : first=second)
    (storage : DeltaRegions.Storage first) : (reindex equal storage).memory=storage.memory := by
  cases equal
  rfl

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Row BF}

-- Reindexing changes the logical cache description, not any byte, address,
-- or allocation. The graph receives the proved mathematical cache update.
def afterStorage (execution : ResidualDeltaMemory.Execution layer cache input) :
    DeltaRegions.Storage (layer.cacheAfter cache (fun _ => input) 1) :=
  reindex execution.cache_eq execution.afterCache

theorem after_memory (execution : ResidualDeltaMemory.Execution layer cache input) :
    (afterStorage execution).memory=execution.outputBuffer.bytes :=
  (reindex_memory execution.cache_eq execution.afterCache).trans execution.cache_output_shared

def before (execution : ResidualDeltaMemory.Execution layer cache input) (n : Nat) :
    DecodeFrame.StageBuffer (n := n) (.delta layer) cache execution.entry.source.lhs.bytes :=
  ⟨execution.storage, execution.shared⟩

def after (execution : ResidualDeltaMemory.Execution layer cache input) (n : Nat) (angle : Kernels.Attention.RopeAngles.Inputs) :
    DecodeFrame.StageBuffer (.delta layer) (DecodeStage.cacheAfter (n := n) (.delta layer) cache input angle)
      execution.forwardBuffer.bytes :=
  ⟨afterStorage execution, after_memory execution⟩

def retainedStage (execution : ResidualDeltaMemory.Execution layer cache input)
    (stage : Stage) (retained : Cache stage n)
    (buffer : DecodeFrame.StageBuffer stage retained execution.entry.source.lhs.bytes)
    (safe : DecodePreservation.StageProtected (ResidualDeltaMemory.Safe execution) stage retained buffer.storage) :
    DecodeFrame.StageBuffer stage retained execution.outputBuffer.bytes :=
  DecodePreservation.stageReframe (ResidualDeltaMemory.Safe execution) execution.entry.source.lhs.bytes execution.outputBuffer.bytes
    (fun _ _ region => execution.other_region region) stage retained buffer safe

theorem forward_read (execution : ResidualDeltaMemory.Execution layer cache input) (n : Nat)
    (angle : Kernels.Attention.RopeAngles.Inputs) (i : Fin 5120) :
    execution.outputBuffer.read i=DecodeStage.forward (n := n) (.delta layer) cache input angle i :=
  (execution.outputBuffer.read_correct i).trans (congrFun execution.output_eq i)

end Inference.Models.Qwen.DeltaMemoryStage
