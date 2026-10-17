import kernels.sampling.LogSumExpSourceLoop
namespace Inference.Kernels.Sampling.LogSumExpSourceMerge
open Contracts.Mlx

-- SIMD topology, native SIMD max tie behavior and FTZ reduction lowering
-- remain attached through the existing explicit trees/platform contracts.
def group (p : LogSumExpRanges.Platform) (lanes : Fin 32→LogSumExpBlockRanges.State) : LogSumExpBlockRanges.State :=
  let maximum := Maximum.tree (fun i=>(lanes i).maximum) p.maximumTree
  let adjusted := fun i=>FlushToZero.mul (lanes i).normalizer
    (LogSumExpSourceArithmetic.exponential p.scalar (lanes i).maximum maximum)
  ⟨maximum,FlushedReduction.evaluate adjusted p.sumTree⟩

theorem group_model (p : LogSumExpRanges.Platform) (lanes : Fin 32→LogSumExpBlockRanges.State) :
    group p lanes=LogSumExpMergeRanges.merge p.scalar lanes p.maximumTree p.sumTree := by
  exact congrArg (fun normalizer=>LogSumExpBlockRanges.State.mk
    (LogSumExpMergeRanges.maximum lanes p.maximumTree) normalizer)
    (LogSumExpMergeRanges.execution p.scalar lanes p.maximumTree p.sumTree).symm

def groups (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (base : Nat) : Fin 32→LogSumExpBlockRanges.State :=
  fun simd=>group p (fun lane=>LogSumExpSourceLoop.loop p.scalar memory base (LogSumExpLayout.threadAt simd lane) 61 (by decide))

theorem groups_model {logits : Fin 248320→ArrayStorage.BF} (source : ArrayStorage.BFBuffer logits)
    (p : LogSumExpRanges.Platform) : groups p source.bytes source.base=LogSumExpDevice.groups p source := by
  rw [LogSumExpDevice.groups_eq]
  funext simd
  unfold groups LogSumExpRanges.groupState
  rw [group_model]
  apply congrArg (fun states=>LogSumExpMergeRanges.merge p.scalar states p.maximumTree p.sumTree)
  funext lane
  exact LogSumExpSourceLoop.loop_model source p.scalar (LogSumExpLayout.threadAt simd lane) 61 (by decide)
end Inference.Kernels.Sampling.LogSumExpSourceMerge
