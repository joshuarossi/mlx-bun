import contracts.mlx.HalfMemory
import contracts.mlx.WriteOwnership
import Mathlib.Data.List.ProdSigma

namespace Inference.Contracts.Mlx.Copy2D

-- Same-dtype 16-bit copy_gg_nd2 / elem_to_loc_2, with unit destination
-- inner stride. One thread copies one element. The input allocation is an
-- immutable byte view during this dispatch; native aliasing, grid dispatch
-- and source/binary correspondence must establish that execution boundary.
abbrev Label (rows columns : Nat) := Fin rows × Fin columns
def labels (rows columns : Nat) : List (Label rows columns) :=
  (List.finRange rows).product (List.finRange columns)

structure Layout where
  sourceBase : Nat
  sourceRow : Nat
  sourceColumn : Nat
  destinationBase : Nat
  destinationRow : Nat

def sourceAddress (layout : Layout) (label : Label rows columns) : Nat :=
  layout.sourceBase+2*(label.2.val*layout.sourceColumn+label.1.val*layout.sourceRow)

def destination (stride : Nat) (label : Label rows columns) : Nat :=
  label.2.val+label.1.val*stride

theorem row_inverse (stride : Nat) (room : columns ≤ stride) (label : Label rows columns) :
    destination stride label/stride=label.1.val := by
  have small : label.2.val<stride := Nat.lt_of_lt_of_le label.2.isLt room
  have positive : 0<stride := by omega
  simp only [destination, Nat.add_mul_div_right _ _ positive, Nat.div_eq_of_lt small, Nat.zero_add]

theorem column_inverse (stride : Nat) (room : columns ≤ stride) (label : Label rows columns) :
    destination stride label%stride=label.2.val := by
  simp only [destination, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le label.2.isLt room)]

theorem destination_unique (stride : Nat) (room : columns ≤ stride) (a b : Label rows columns)
    (same : destination stride a=destination stride b) : a=b := by
  have row := congrArg (fun index => index/stride) same
  have column := congrArg (fun index => index%stride) same
  rw [row_inverse stride room, row_inverse stride room] at row
  rw [column_inverse stride room, column_inverse stride room] at column
  exact Prod.ext (Fin.ext row) (Fin.ext column)

def entry (layout : Layout) (source : HalfMemory.Bytes) (label : Label rows columns) : HalfMemory.Store :=
  ⟨layout.destinationBase/2+destination layout.destinationRow label, HalfMemory.load source (sourceAddress layout label)⟩

def programs (layout : Layout) (source : HalfMemory.Bytes) (rows columns : Nat) : List (List HalfMemory.Store) :=
  (labels rows columns).map (fun label => [entry layout source label])

theorem member (layout : Layout) (source : HalfMemory.Bytes) (store : HalfMemory.Store)
    (inside : store ∈ (programs layout source rows columns).flatten) : ∃ label : Label rows columns, store=entry layout source label := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp ht
  exact ⟨label, List.mem_singleton.mp hs⟩

theorem covers (layout : Layout) (source : HalfMemory.Bytes) (label : Label rows columns) :
    entry layout source label ∈ (programs layout source rows columns).flatten :=
  List.mem_flatten.mpr ⟨[entry layout source label], List.mem_map.mpr
    ⟨label, List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩, rfl⟩, by simp⟩

theorem separated (layout : Layout) (source : HalfMemory.Bytes) (room : columns ≤ layout.destinationRow) :
    WriteOwnership.Separated MemoryCells.Store.word (programs layout source rows columns) := by
  apply List.pairwise_map.mpr
  apply ((List.nodup_finRange rows).product (List.nodup_finRange columns)).imp_of_mem
  intro first second _ _ different word left right
  have leftEq : word=(entry layout source first).word := by simpa only [List.map_singleton, List.mem_singleton] using left
  have rightEq : word=(entry layout source second).word := by simpa only [List.map_singleton, List.mem_singleton] using right
  apply different
  apply destination_unique layout.destinationRow room
  have same := leftEq.symm.trans rightEq
  exact Nat.add_left_cancel same

theorem stored (layout : Layout) (source : HalfMemory.Bytes) (room : columns ≤ layout.destinationRow)
    (before : HalfMemory.Words) (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs layout source rows columns) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (label : Label rows columns) :
    MemoryCells.execute schedule before (layout.destinationBase/2+destination layout.destinationRow label)=
      HalfMemory.load source (sourceAddress layout label) := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨other, rfl⟩ := member layout source store inside
    have equal := destination_unique layout.destinationRow room other label (Nat.add_left_cancel same)
    subst other
    rfl
  · exact ⟨entry layout source label, covers layout source label, rfl⟩

structure Trace (layout : Layout) (source : HalfMemory.Bytes) (rows columns : Nat) where
  before : HalfMemory.Bytes
  aligned : layout.destinationBase%2=0
  room : columns ≤ layout.destinationRow
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs layout source rows columns) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (layout : Layout) (source before : HalfMemory.Bytes) (rows columns : Nat)
    (aligned : layout.destinationBase%2=0) (room : columns ≤ layout.destinationRow) : Trace layout source rows columns :=
  let stores := programs layout source rows columns
  ⟨before, aligned, room, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {layout : Layout} {source : HalfMemory.Bytes} {rows columns : Nat}

def Trace.memory (trace : Trace layout source rows columns) : HalfMemory.Bytes :=
  HalfMemory.execute trace.schedule trace.before

theorem Trace.read_correct (trace : Trace layout source rows columns) (label : Label rows columns) :
    HalfMemory.load trace.memory (layout.destinationBase+2*destination layout.destinationRow label)=
      HalfMemory.load source (sourceAddress layout label) := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by have := trace.aligned; omega),
    show (layout.destinationBase+2*destination layout.destinationRow label)/2=
      layout.destinationBase/2+destination layout.destinationRow label by omega]
  exact stored layout source trace.room _ _ _ trace.execution trace.completed label

theorem Trace.frame (trace : Trace layout source rows columns) (word : Nat)
    (outside : ∀ label : Label rows columns, layout.destinationBase/2+destination layout.destinationRow label ≠ word) :
    HalfMemory.load trace.memory (2*word)=HalfMemory.load trace.before (2*word) := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by omega), show 2*word/2=word by omega]
  apply MemoryCells.frame
  intro store inside
  obtain ⟨label, rfl⟩ := member layout source store ((ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp inside)
  exact outside label

end Inference.Contracts.Mlx.Copy2D
