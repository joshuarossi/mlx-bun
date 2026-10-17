import kernels.normalization.MlxRmsLoopControl
import kernels.normalization.MlxRmsPointerSource

namespace Inference.Kernels.Normalization.MlxRmsLoopMemory
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open MlxRmsLoopControl (count)
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange NormalizationSchedule.threadColumns

def programs (threads : Nat) : List (List (Fin count)) :=
  (List.finRange threads).map (NormalizationSchedule.threadColumns count)

theorem program_source (threads : Nat) (positive : 0<threads) (thread : Fin threads) :
    MlxRmsLoopControl.executeSource MlxRmsLoopSyntax.sourceBody threads thread=
      some (NormalizationSchedule.threadColumns count thread) := MlxRmsLoopControl.source_columns threads positive thread

theorem coverage (threads : Nat) (positive : 0<threads) : (programs threads).flatten.Perm (List.finRange count) := by
  change ((List.finRange threads).flatMap (NormalizationSchedule.threadColumns count)).Perm _
  rw [←NormalizationSchedule.columns_by_thread]
  exact NormalizationSchedule.columns_complete threads count positive

def selectedText (threads : Nat) (positive : 0<threads) (col : Fin count) : String :=
  if MlxRmsOutputMemory.outer threads positive col+MlxRmsOutputMemory.origin threads positive col+4≤count
    then MlxRmsOutputSyntax.sourceBody else MlxRmsOutputSyntax.sourceTailBody

variable {values weight : Fin count → ArrayStorage.BF} (input : BinaryMemory.Input values weight)

def sourceCell {factor : Float32} (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (before : HalfMemory.Bytes) : Option HalfMemory.Bytes := do
  let owner := NormalizationSchedule.owner threads positive col.val
  let x ←MlxRmsPointerSource.execute MlxRmsPointerSource.sourceX "x" input.lhs.base 0 count owner.thread.val 1
  let w ←MlxRmsPointerSource.execute MlxRmsPointerSource.sourceW "w" input.rhs.base 0 count owner.thread.val 1
  let out ←MlxRmsPointerSource.execute MlxRmsPointerSource.sourceOut "out" (2*existing.base) 0 count owner.thread.val 1
  MlxRmsOutputSemantics.executeSource (selectedText threads positive col) x w out inverse inverseBase
    (MlxRmsOutputMemory.outer threads positive col) (MlxRmsOutputMemory.inner threads positive col) before

theorem source_cell {factor : Float32} (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (before : HalfMemory.Bytes) :
    sourceCell input existing threads positive inverse inverseBase col before=
      some (MlxRmsOutputMemory.cell threads positive input.lhs.base input.rhs.base
        (2*existing.base) inverse inverseBase col before) := by
  have width : count≤2^32 := by decide
  have pointers := MlxRmsPointerSource.buffer_pointers input threads positive width col
  have small : MlxRmsOutputMemory.origin threads positive col<2^32 := by
    have := MlxRmsOutputMemory.column_address threads positive col
    have := col.isLt
    omega
  have output := MlxRmsPointerSource.out_address (2*existing.base) count
    (NormalizationSchedule.owner threads positive col.val).thread.val small
    (MlxRmsPointerSource.buffer_room existing.buffer threads positive col)
  dsimp only [sourceCell]
  dsimp only at pointers
  rw [pointers.1,pointers.2,output]
  unfold selectedText
  split
  · simpa [MlxRmsOutputMemory.sourceCell,MlxRmsOutputMemory.origin,Option.bind_some] using
      MlxRmsOutputMemory.source_cell threads positive width input.lhs.base input.rhs.base
        (2*existing.base) inverse inverseBase col before
  · simpa [MlxRmsOutputMemory.sourceCell,MlxRmsOutputMemory.origin,Option.bind_some] using
      MlxRmsOutputMemory.tail_source_cell threads positive width input.lhs.base input.rhs.base
        (2*existing.base) inverse inverseBase col before

inductive Runs (input : BinaryMemory.Input values weight) {factor : Float32} (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) (inverse : M1Max.WordMemory) (inverseBase : Nat) :
    List (Fin count) → HalfMemory.Bytes → HalfMemory.Bytes → Prop where
  | nil (before) : Runs input existing threads positive inverse inverseBase [] before before
  | next (sourceStep : sourceCell input existing threads positive inverse inverseBase col before=some after)
      (rest : Runs input existing threads positive inverse inverseBase columns after final) :
      Runs input existing threads positive inverse inverseBase (col::columns) before final

theorem canonical {factor : Float32} (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (columns : List (Fin count)) (before : HalfMemory.Bytes) :
    Runs input existing threads positive inverse inverseBase columns before
      (MlxRmsOutputMemory.run threads positive input.lhs.base input.rhs.base (2*existing.base) inverse inverseBase columns before) := by
  induction columns generalizing before with
  | nil => exact .nil _
  | cons col rest ih => exact .next (source_cell input existing threads positive inverse inverseBase col before) (ih _)

def outputTrace (factor : Float32) (destination threads : Nat) (positive : 0<threads) :
    ElementwiseMemory.Trace (BinaryMemory.kernel input (RmsNormMemory.operation factor) destination) where
  programs := programs threads
  coverage := coverage threads positive
  before := input.lhs.bytes
  schedule := (programs threads).flatten
  remaining := List.replicate (programs threads).length []
  execution := ThreadgroupWrites.canonical (programs threads)
  completed := ThreadgroupWrites.canonical_barrier (programs threads)

def outputExecution {factor : Float32} (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) : BinaryMemory.Execution input (RmsNormMemory.operation factor) :=
  ⟨existing.base,existing.bounded,outputTrace input factor existing.base threads positive,rfl,existing.independent⟩

-- Heap confluence includes donated x: each execution's independence proof,
-- attached bytes and frame theorem account for aliases. No memory-equality
-- premise or existing owner schedule is fed to the parsed execution.
theorem same_heap {factor : Float32}
    (first second : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (sameBase : first.base=second.base) : first.trace.memory=second.trace.memory := by
  funext address
  by_cases inside : 2*first.base≤address ∧ address<2*first.base+2*count
  · let col : Fin count := ⟨(address-2*first.base)/2,by omega⟩
    let offset := (address-2*first.base)%2
    have bound : offset<2 := by dsimp [offset]; omega
    have atAddress : 2*first.base+2*col.val+offset=address := by dsimp [col,offset]; omega
    have left := congrArg (fun bits => HalfMemory.byte bits offset) (first.buffer.attached col)
    have right := congrArg (fun bits => HalfMemory.byte bits offset) (second.buffer.attached col)
    change HalfMemory.byte (HalfMemory.load first.trace.memory (2*first.base+2*col.val)) offset=_ at left
    change HalfMemory.byte (HalfMemory.load second.trace.memory (2*second.base+2*col.val)) offset=_ at right
    rw [HalfMemory.byte_load _ _ _ bound] at left right
    have sameAddress : 2*second.base+2*col.val+offset=address := by rw [←sameBase]; exact atAddress
    rw [atAddress] at left
    rw [sameAddress] at right
    exact left.trans right.symm
  · have outside : MemoryRegions.Disjoint (2*first.base) (2*count) address 1 := by unfold MemoryRegions.Disjoint; omega
    have left := first.other_region outside 0 (by decide)
    have right := second.other_region (by simpa only [sameBase] using outside) 0 (by decide)
    simpa only [Nat.add_zero] using left.trans right.symm

theorem output_heap {factor : Float32} (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) :
    (outputExecution input existing threads positive).trace.memory=existing.trace.memory := same_heap input _ _ rfl

theorem output_stores {factor : Float32} (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (threads : Nat) (positive : 0<threads) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (factorRead : inverse inverseBase=factor) :
    Runs input existing threads positive inverse inverseBase (programs threads).flatten input.lhs.bytes existing.trace.memory := by
  have memory := (MlxRmsOutputMemory.refines_existing input threads positive
    (outputExecution input existing threads positive) inverse inverseBase factorRead).trans
      (output_heap input existing threads positive)
  change MlxRmsOutputMemory.run threads positive input.lhs.base input.rhs.base (2*existing.base)
    inverse inverseBase (programs threads).flatten input.lhs.bytes=existing.trace.memory at memory
  have stores := canonical input existing threads positive inverse inverseBase (programs threads).flatten input.lhs.bytes
  rw [memory] at stores
  exact stores

theorem checked_rms (threads : Nat) (positive : 0<threads) {platform : RmsNorm.Platform} {size eps : Float32}
    (existing : RmsNormMemory.Execution input platform size eps) :
    Runs input existing.normalized threads positive (MlxRmsOutputMemory.inverseWords input existing) 0
      (programs threads).flatten input.lhs.bytes existing.normalized.trace.memory :=
  output_stores input existing.normalized threads positive _ 0 existing.factorRead.symm

end Inference.Kernels.Normalization.MlxRmsLoopMemory
