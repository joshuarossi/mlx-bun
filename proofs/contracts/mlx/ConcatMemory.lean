import contracts.mlx.CopyExecution
import contracts.mlx.Concat1D
import contracts.mlx.DispatchBarriers

namespace Inference.Contracts.Mlx.ConcatMemory

-- Word bases describe the two scalar-copy views used for one-dimensional
-- concatenation. Both sources and the destination occupy one byte heap.
structure Layout (a b : Nat) where
  left : Nat
  right : Nat
  destination : Nat
  leftSeparate : MemoryRegions.Disjoint (2*destination) (2*(a+b)) (2*left) (2*a)
  rightSeparate : MemoryRegions.Disjoint (2*destination) (2*(a+b)) (2*right) (2*b)

def leftOperation (layout : Layout a b) (i : Fin a) : CopyExecution.Operation :=
  ⟨layout.left+i.val, layout.destination+i.val⟩
def rightOperation (layout : Layout a b) (i : Fin b) : CopyExecution.Operation :=
  ⟨layout.right+i.val, layout.destination+a+i.val⟩
def programs (layout : Layout a b) : List (List CopyExecution.Operation) :=
  (List.finRange a).map (fun i => [leftOperation layout i]) ++
    (List.finRange b).map (fun i => [rightOperation layout i])

theorem member (layout : Layout a b) (op : CopyExecution.Operation) (inside : op ∈ (programs layout).flatten) :
    (∃ i, op=leftOperation layout i) ∨ (∃ i, op=rightOperation layout i) := by
  simp only [programs, List.flatten_append, List.mem_append] at inside
  rcases inside with left|right
  · obtain ⟨thread, threadMember, opMember⟩ := List.mem_flatten.mp left
    obtain ⟨i, _, rfl⟩ := List.mem_map.mp threadMember
    exact Or.inl ⟨i, List.mem_singleton.mp opMember⟩
  · obtain ⟨thread, threadMember, opMember⟩ := List.mem_flatten.mp right
    obtain ⟨i, _, rfl⟩ := List.mem_map.mp threadMember
    exact Or.inr ⟨i, List.mem_singleton.mp opMember⟩

theorem left_covers (layout : Layout a b) (i : Fin a) : leftOperation layout i ∈ (programs layout).flatten := by
  simp only [programs, List.flatten_append, List.mem_append]
  exact Or.inl (List.mem_flatten.mpr ⟨[leftOperation layout i],
    List.mem_map.mpr ⟨i, List.mem_finRange _, rfl⟩, List.mem_singleton_self _⟩)

theorem right_covers (layout : Layout a b) (i : Fin b) : rightOperation layout i ∈ (programs layout).flatten := by
  simp only [programs, List.flatten_append, List.mem_append]
  exact Or.inr (List.mem_flatten.mpr ⟨[rightOperation layout i],
    List.mem_map.mpr ⟨i, List.mem_finRange _, rfl⟩, List.mem_singleton_self _⟩)

theorem writes_inside (layout : Layout a b) (op : CopyExecution.Operation) (inside : op ∈ (programs layout).flatten) :
    2*layout.destination ≤ 2*op.destination ∧ 2*op.destination+2 ≤ 2*layout.destination+2*(a+b) := by
  rcases member layout op inside with ⟨i, rfl⟩|⟨i, rfl⟩
  · have := i.isLt; dsimp [leftOperation]; omega
  · have := i.isLt; dsimp [rightOperation]; omega

theorem no_alias (layout : Layout a b) : CopyExecution.NoAlias (programs layout).flatten := by
  apply CopyExecution.no_alias_regions _ (2*layout.destination) (2*(a+b)) (writes_inside layout)
  intro op inside
  rcases member layout op inside with ⟨i, rfl⟩|⟨i, rfl⟩
  · refine ⟨2*layout.left, 2*a, ?_, ?_, layout.leftSeparate⟩
    all_goals have := i.isLt; dsimp [leftOperation]; omega
  · refine ⟨2*layout.right, 2*b, ?_, ?_, layout.rightSeparate⟩
    all_goals have := i.isLt; dsimp [rightOperation]; omega

abbrev Trace (layout : Layout a b) := CopyExecution.Trace (programs layout)

theorem left_read (layout : Layout a b) (trace : Trace layout) (i : Fin a) :
    HalfMemory.load trace.memory (2*(layout.destination+i.val))=HalfMemory.load trace.before (2*(layout.left+i.val)) := by
  apply trace.read_correct (no_alias layout)
  · intro op inside same
    rcases member layout op inside with ⟨j, rfl⟩|⟨j, rfl⟩
    · have equal : j=i := Fin.ext (Nat.add_left_cancel same)
      subst j
      rfl
    · have := i.isLt
      dsimp [rightOperation] at same
      omega
  · exact ⟨leftOperation layout i, left_covers layout i, rfl⟩

theorem right_read (layout : Layout a b) (trace : Trace layout) (i : Fin b) :
    HalfMemory.load trace.memory (2*(layout.destination+a+i.val))=HalfMemory.load trace.before (2*(layout.right+i.val)) := by
  apply trace.read_correct (no_alias layout)
  · intro op inside same
    rcases member layout op inside with ⟨j, rfl⟩|⟨j, rfl⟩
    · have := j.isLt
      dsimp [leftOperation] at same
      omega
    · have equal : j=i := Fin.ext (Nat.add_left_cancel same)
      subst j
      rfl
  · exact ⟨rightOperation layout i, right_covers layout i, rfl⟩

theorem joined_read (layout : Layout a b) (trace : Trace layout) (i : Fin (a+b)) :
    HalfMemory.load trace.memory (2*(layout.destination+i.val))=
      Concat1D.joined (fun j : Fin a => HalfMemory.load trace.before (2*(layout.left+j.val)))
        (fun j : Fin b => HalfMemory.load trace.before (2*(layout.right+j.val))) i := by
  unfold Concat1D.joined
  split
  · rename_i inside
    exact left_read layout trace ⟨i.val, inside⟩
  · rename_i outside
    have bounds := i.isLt
    have address : layout.destination+i.val=layout.destination+a+(i.val-a) := by omega
    rw [address]
    exact right_read layout trace ⟨i.val-a, by omega⟩

theorem stores_inside (layout : Layout a b) (trace : Trace layout) :
    MemoryRegions.Inside16 (2*layout.destination) (2*(a+b)) (trace.schedule.map (CopyExecution.store trace.before)) := by
  intro write inside
  obtain ⟨op, opMember, rfl⟩ := List.mem_map.mp inside
  exact writes_inside layout op ((ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp opMember)

theorem other_region (layout : Layout a b) (trace : Trace layout)
    (separate : MemoryRegions.Disjoint (2*layout.destination) (2*(a+b)) base size) (offset : Nat) (bound : offset<size) :
    trace.memory (base+offset)=trace.before (base+offset) := by
  rw [trace.memory_fixed (no_alias layout)]
  exact MemoryRegions.execute16_other _ _ (stores_inside layout trace) separate offset bound

-- Native concatenate_gpu enters one ConcurrentContext and registers both
-- copies against the same output resource. The next consumer must wait for
-- the group; the byte proofs above admit every completing copy interleaving.
def dispatchCopy (context : DispatchBarriers.Concurrent) (source output : Nat) : DispatchBarriers.Concurrent :=
  DispatchBarriers.concurrentDispatch (DispatchBarriers.concurrentOutput
    { context with current := DispatchBarriers.input context.current source } output)

def dispatchCopies (state : DispatchBarriers.State) (left right output : Nat) : DispatchBarriers.Concurrent :=
  dispatchCopy (dispatchCopy (DispatchBarriers.beginConcurrent state) left output) right output

theorem consumer_barrier (state : DispatchBarriers.State) (left right output : Nat) :
    (DispatchBarriers.input (DispatchBarriers.finishConcurrent (dispatchCopies state left right output)) output).needsBarrier=true := by
  apply DispatchBarriers.concurrent_consumer
  simp [dispatchCopies, dispatchCopy, DispatchBarriers.concurrentDispatch, DispatchBarriers.concurrentOutput]

end Inference.Contracts.Mlx.ConcatMemory
