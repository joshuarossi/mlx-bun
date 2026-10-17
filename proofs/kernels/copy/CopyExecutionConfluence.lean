import contracts.mlx.CopyExecution

namespace Inference.Kernels.Copy.CopyExecutionConfluence
open Contracts.Mlx
set_option maxRecDepth 10000

variable {programs : List (List CopyExecution.Operation)}

-- Copies may share destinations only when their original source word agrees.
-- Together with NoAlias this proves whole-heap equality for all completed
-- owner schedules, including bytes outside the destination allocation.
def Consistent (programs : List (List CopyExecution.Operation)) : Prop :=
  ∀ first∈programs.flatten, ∀ second∈programs.flatten,
    first.destination=second.destination → first.source=second.source

private theorem untouched (trace : CopyExecution.Trace programs) (separate : CopyExecution.NoAlias programs.flatten)
    (word : Nat) (outside : ∀ op∈programs.flatten, op.destination≠word) :
    HalfMemory.load trace.memory (2*word)=HalfMemory.load trace.before (2*word) := by
  rw [trace.memory_fixed separate,HalfMemory.execute_load _ _ _ (by omega)]
  rw [show 2*word/2=word by omega]
  change MemoryCells.execute _ (HalfMemory.view trace.before) word=HalfMemory.view trace.before word
  apply MemoryCells.frame
  intro write present
  obtain ⟨op,member,equal⟩ := List.mem_map.mp present
  subst write
  exact outside op ((ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member)

theorem same_heap (first second : CopyExecution.Trace programs)
    (shared : first.before=second.before)
    (separate : CopyExecution.NoAlias programs.flatten) (consistent : Consistent programs) :
    first.memory=second.memory := by
  have loads (word : Nat) : HalfMemory.load first.memory (2*word)=HalfMemory.load second.memory (2*word) := by
    by_cases inside : ∃ op∈programs.flatten, op.destination=word
    · obtain ⟨op,member,destination⟩ := inside
      have left := first.read_correct separate word (HalfMemory.load first.before (2*op.source))
        (by intro other present equal; rw [consistent other present op member (equal.trans destination.symm)])
        ⟨op,member,destination⟩
      have right := second.read_correct separate word (HalfMemory.load second.before (2*op.source))
        (by intro other present equal; rw [consistent other present op member (equal.trans destination.symm)])
        ⟨op,member,destination⟩
      rw [shared] at left
      exact left.trans right.symm
    · have outside : ∀ op∈programs.flatten, op.destination≠word := by
        intro op member equal
        exact inside ⟨op,member,equal⟩
      rw [untouched first separate word outside,untouched second separate word outside,shared]
  funext address
  have equal := congrArg (fun raw => HalfMemory.byte raw (address%2)) (loads (address/2))
  rw [HalfMemory.byte_load _ _ _ (by omega),HalfMemory.byte_load _ _ _ (by omega)] at equal
  simpa only [show 2*(address/2)+address%2=address by omega] using equal

end Inference.Kernels.Copy.CopyExecutionConfluence
