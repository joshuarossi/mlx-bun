import kernels.copy.MlxKvConcatSource
import kernels.copy.CopyExecutionConfluence

namespace Inference.Kernels.Copy.MlxKvConcatMemory
open Contracts.Mlx State MlxKvConcatSource
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs KvConcatMemory.programs

variable {capacity : Nat}

def oldLabel (label : Copy2D.Label 4 (capacity*256)) : Copy2D.Label 4 ((capacity+256)*256) :=
  (label.1,⟨label.2.val,by have := label.2.isLt; omega⟩)

def newLabel (label : Copy2D.Label 4 (256*256)) : Copy2D.Label 4 ((capacity+256)*256) :=
  (label.1,⟨capacity*256+label.2.val,by have := label.2.isLt; omega⟩)

def destinationLayout (layout : KvConcatMemory.Layout capacity) : Copy2D.Layout :=
  ⟨0,0,0,2*layout.destination,(capacity+256)*256⟩

theorem old_destination (layout : KvConcatMemory.Layout capacity) (label : Copy2D.Label 4 (capacity*256)) :
    (KvConcatMemory.oldOperation layout label).destination=
      (Copy2DMemory.operation (destinationLayout layout) (oldLabel (capacity:=capacity) label)).destination := by
  rw [←old_operation]
  dsimp [Copy2DMemory.operation,oldLayout,destinationLayout,oldLabel,Copy2D.destination]

theorem new_destination (layout : KvConcatMemory.Layout capacity) (label : Copy2D.Label 4 (256*256)) :
    (KvConcatMemory.newOperation layout label).destination=
      (Copy2DMemory.operation (destinationLayout layout) (newLabel (capacity:=capacity) label)).destination := by
  rw [←new_operation]
  dsimp [Copy2DMemory.operation,newLayout,destinationLayout,newLabel,Copy2D.destination]
  omega

private theorem destination_unique (layout : KvConcatMemory.Layout capacity)
    (first second : Copy2D.Label 4 ((capacity+256)*256))
    (equal : (Copy2DMemory.operation (destinationLayout layout) first).destination=
      (Copy2DMemory.operation (destinationLayout layout) second).destination) : first=second :=
  Copy2D.destination_unique ((capacity+256)*256) (by omega) first second (Nat.add_left_cancel equal)

private theorem shift_injective {columns : Nat} (shift : Nat) {a b : Copy2D.Label 4 columns}
    (equal : (a.1,shift+a.2.val)=(b.1,shift+b.2.val)) : a=b := by
  apply Prod.ext
  · have head := congrArg (fun label : Fin 4 × Nat => label.1) equal
    exact head
  · apply Fin.ext
    have column := congrArg (fun label : Fin 4 × Nat => label.2) equal
    exact Nat.add_left_cancel column

theorem consistent (layout : KvConcatMemory.Layout capacity) :
    CopyExecutionConfluence.Consistent (KvConcatMemory.programs layout) := by
  intro first firstMember second secondMember equal
  rcases KvConcatMemory.member layout first firstMember with ⟨a,rfl⟩|⟨a,rfl⟩ <;>
    rcases KvConcatMemory.member layout second secondMember with ⟨b,rfl⟩|⟨b,rfl⟩
  · rw [old_destination,old_destination] at equal
    have labels := destination_unique layout _ _ equal
    have same : a=b := by
      apply Prod.ext
      · have head := congrArg (fun label : Copy2D.Label 4 ((capacity+256)*256) => label.1) labels
        exact head
      · apply Fin.ext
        exact congrArg (fun label : Copy2D.Label 4 ((capacity+256)*256) => label.2.val) labels
    subst b
    rfl
  · rw [old_destination,new_destination] at equal
    have labels := congrArg (fun label : Copy2D.Label 4 ((capacity+256)*256) => label.2.val) (destination_unique layout _ _ equal)
    have := a.2.isLt
    change a.2.val=capacity*256+b.2.val at labels
    omega
  · rw [new_destination,old_destination] at equal
    have labels := congrArg (fun label : Copy2D.Label 4 ((capacity+256)*256) => label.2.val) (destination_unique layout _ _ equal)
    have := b.2.isLt
    change capacity*256+a.2.val=b.2.val at labels
    omega
  · rw [new_destination,new_destination] at equal
    have labels := destination_unique layout _ _ equal
    have pair := congrArg
      (fun label : Copy2D.Label 4 ((capacity+256)*256) => (label.1,label.2.val)) labels
    dsimp only [newLabel] at pair
    have same : a=b := shift_injective (columns:=65536) (a:=a) (b:=b) (capacity*256) pair
    subst b
    rfl

theorem programs (layout : KvConcatMemory.Layout capacity) :
    KvConcatMemory.programs layout=
      Copy2DMemory.programs (oldLayout layout) 4 (capacity*256)++
      Copy2DMemory.programs (newLayout layout) 4 (256*256) := by
  unfold KvConcatMemory.programs Copy2DMemory.programs
  congr 1
  · apply List.map_congr_left
    intro label _
    rw [old_operation]
  · apply List.map_congr_left
    intro label _
    rw [new_operation]

theorem same_heap (layout : KvConcatMemory.Layout capacity) (first second : KvConcatMemory.Trace layout)
    (shared : first.before=second.before) : first.memory=second.memory :=
  CopyExecutionConfluence.same_heap first second shared (KvConcatMemory.no_alias layout) (consistent layout)

private theorem execute_append (first second : List CopyExecution.Operation) (before : ByteMemory.Bytes) :
    CopyExecution.execute (first++second) before=CopyExecution.execute second (CopyExecution.execute first before) := by
  induction first generalizing before with
  | nil => rfl
  | cons operation rest ih => exact ih _

theorem old_separate (layout : KvConcatMemory.Layout capacity) :
    GeneralCopy2DWideInterleaving.Separate (width:=capacity*256) (oldLayout layout) := by
  intro reader writer
  rw [old_operation,old_operation]
  exact KvConcatMemory.no_alias layout _ (KvConcatMemory.old_covers layout reader)
    _ (KvConcatMemory.old_covers layout writer)

theorem new_separate (layout : KvConcatMemory.Layout capacity) :
    GeneralCopy2DWideInterleaving.Separate (width:=256*256) (newLayout layout) := by
  intro reader writer
  rw [new_operation,new_operation]
  exact KvConcatMemory.no_alias layout _ (KvConcatMemory.new_covers layout reader)
    _ (KvConcatMemory.new_covers layout writer)

def oldTrace (layout : KvConcatMemory.Layout capacity) (before : ByteMemory.Bytes) :
    Copy2DMemory.Trace (oldLayout layout) 4 (capacity*256) :=
  CopyExecution.Trace.canonical _ before

def newTrace (layout : KvConcatMemory.Layout capacity) (before : ByteMemory.Bytes) :
    Copy2DMemory.Trace (newLayout layout) 4 (256*256) :=
  CopyExecution.Trace.canonical _ (oldTrace layout before).memory

def oldChecked (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout)
    (before : ByteMemory.Bytes) :=
  GeneralCopy2DWideSourceRefinement.canonical (old_bounds layout allocation) before

def newChecked (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout)
    (before : ByteMemory.Bytes) :=
  GeneralCopy2DWideSourceRefinement.canonical (new_bounds layout allocation) (oldTrace layout before).memory

theorem old_heap (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout)
    (before : ByteMemory.Bytes) :
    (oldChecked layout allocation before).bodyAfter=(oldTrace layout before).memory ∧
    (oldChecked layout allocation before).eventAfter.memory=(oldTrace layout before).memory :=
  GeneralCopy2DWideSourceRefinement.checked_eq (old_bounds layout allocation)
    (old_separate layout) (oldTrace layout before) (oldChecked layout allocation before)

private theorem canonical_memory (layout : KvConcatMemory.Layout capacity) (before : ByteMemory.Bytes) :
    (CopyExecution.Trace.canonical (KvConcatMemory.programs layout) before).memory=(newTrace layout before).memory := by
  change CopyExecution.execute (KvConcatMemory.programs layout).flatten before=
    CopyExecution.execute (Copy2DMemory.programs (newLayout layout) 4 (256*256)).flatten
      (CopyExecution.execute (Copy2DMemory.programs (oldLayout layout) 4 (capacity*256)).flatten before)
  rw [programs,List.flatten_append,execute_append]

theorem new_heap (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout)
    (trace : KvConcatMemory.Trace layout) :
    (newChecked layout allocation trace.before).bodyAfter=trace.memory ∧
    (newChecked layout allocation trace.before).eventAfter.memory=trace.memory := by
  have completed := GeneralCopy2DWideSourceRefinement.checked_eq (new_bounds layout allocation)
    (new_separate layout) (newTrace layout trace.before) (newChecked layout allocation trace.before)
  have joined := (canonical_memory layout trace.before).symm.trans
    (same_heap layout (CopyExecution.Trace.canonical _ trace.before) trace rfl)
  exact ⟨completed.1.trans joined,completed.2.trans joined⟩

theorem new_starts (layout : KvConcatMemory.Layout capacity) (allocation : Allocation layout)
    (before : ByteMemory.Bytes) :
    GeneralCopy2DWideInterleaving.Executes (width:=256*256) (newLayout layout)
      (GeneralCopy2DWideInterleaving.initial (oldChecked layout allocation before).eventAfter.memory)
      (newChecked layout allocation before).events (newChecked layout allocation before).eventAfter := by
  rw [(old_heap layout allocation before).2]
  exact (newChecked layout allocation before).eventExecution

end Inference.Kernels.Copy.MlxKvConcatMemory
