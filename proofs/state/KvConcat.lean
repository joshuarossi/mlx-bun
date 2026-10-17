import state.KvAllocation
import contracts.mlx.Copy2D
import contracts.mlx.CopyShape

namespace Inference.State.KvConcat
open Contracts.Mlx

-- concatenate_gpu launches two GeneralGeneral copies into disjoint views
-- of one new allocation. All interleavings of their scalar writes are
-- admitted here, matching the concurrent host encoding. The extension is
-- supplied as an encoded zero tensor; its native fill is a separate phase.
def oldLayout (capacity : Nat) : Copy2D.Layout := ⟨0, capacity*256, 1, 0, (capacity+256)*256⟩
def newLayout (capacity : Nat) : Copy2D.Layout := ⟨0, 256*256, 1, 2*(capacity*256), (capacity+256)*256⟩
def zeros : HalfMemory.Bytes := HalfMemory.encode (fun _ => 0)

def programs (capacity : Nat) (source : HalfMemory.Bytes) : List (List HalfMemory.Store) :=
  Copy2D.programs (oldLayout capacity) source 4 (capacity*256) ++
    Copy2D.programs (newLayout capacity) zeros 4 (256*256)

def expected (capacity : Nat) (source : HalfMemory.Bytes) : HalfMemory.Words :=
  KvAllocation.concatWords capacity (HalfMemory.view source)

def oldTime (label : Copy2D.Label 4 (capacity*256)) : Nat := label.2.val/256
def newTime (capacity : Nat) (label : Copy2D.Label 4 (256*256)) : Nat := capacity+label.2.val/256
def coordinate (label : Copy2D.Label 4 columns) : Fin 256 := ⟨label.2.val%256, by omega⟩

theorem old_time_bound (label : Copy2D.Label 4 (capacity*256)) : oldTime label<capacity := by
  have := label.2.isLt
  unfold oldTime
  omega

theorem new_time_bounds (capacity : Nat) (label : Copy2D.Label 4 (256*256)) :
    capacity ≤ newTime capacity label ∧ newTime capacity label<capacity+256 := by
  have := label.2.isLt
  unfold newTime
  omega

theorem old_destination (capacity : Nat) (source : HalfMemory.Bytes) (label : Copy2D.Label 4 (capacity*256)) :
    (Copy2D.entry (oldLayout capacity) source label).word=
      Kv.address (capacity+256) label.1 (oldTime label) (coordinate label) := by
  dsimp [Copy2D.entry, oldLayout, Copy2D.destination, Kv.address, oldTime, coordinate]
  ring_nf
  omega

theorem new_destination (capacity : Nat) (label : Copy2D.Label 4 (256*256)) :
    (Copy2D.entry (newLayout capacity) zeros label).word=
      Kv.address (capacity+256) label.1 (newTime capacity label) (coordinate label) := by
  dsimp [Copy2D.entry, newLayout, Copy2D.destination, Kv.address, newTime, coordinate]
  ring_nf
  omega

theorem old_value (capacity : Nat) (source : HalfMemory.Bytes) (label : Copy2D.Label 4 (capacity*256)) :
    expected capacity source (Copy2D.entry (oldLayout capacity) source label).word=
      (Copy2D.entry (oldLayout capacity) source label).value := by
  rw [old_destination]
  unfold expected
  rw [KvAllocation.concat_old _ _ _ _ (old_time_bound label)]
  dsimp only [HalfMemory.view, Copy2D.entry, Copy2D.sourceAddress, oldLayout, oldTime, coordinate, Kv.address]
  congr 2
  ring_nf
  omega

theorem new_value (capacity : Nat) (source : HalfMemory.Bytes) (label : Copy2D.Label 4 (256*256)) :
    expected capacity source (Copy2D.entry (newLayout capacity) zeros label).word=
      (Copy2D.entry (newLayout capacity) zeros label).value := by
  rw [new_destination]
  unfold expected
  rw [KvAllocation.concat_zero _ _ _ _ (new_time_bounds capacity label).1 (new_time_bounds capacity label).2]
  dsimp [Copy2D.entry, Copy2D.sourceAddress, newLayout, zeros]
  rw [HalfMemory.load_encode _ _ (by omega)]

theorem separated (capacity : Nat) (source : HalfMemory.Bytes) :
    WriteOwnership.Separated MemoryCells.Store.word (programs capacity source) := by
  unfold WriteOwnership.Separated programs
  apply List.pairwise_append.mpr
  refine ⟨Copy2D.separated _ _ (by dsimp [oldLayout]; omega),
    Copy2D.separated _ _ (by dsimp [newLayout]; omega), ?_⟩
  intro oldThread oldInside newThread newInside word oldWord newWord
  obtain ⟨oldLabel, _, rfl⟩ := List.mem_map.mp oldInside
  obtain ⟨newLabel, _, rfl⟩ := List.mem_map.mp newInside
  have oldEq : word=(Copy2D.entry (oldLayout capacity) source oldLabel).word := by
    simpa only [List.map_singleton, List.mem_singleton] using oldWord
  have newEq : word=(Copy2D.entry (newLayout capacity) zeros newLabel).word := by
    simpa only [List.map_singleton, List.mem_singleton] using newWord
  have same := oldEq.symm.trans newEq
  rw [old_destination, new_destination] at same
  have oldBound := old_time_bound oldLabel
  have newBound := new_time_bounds capacity newLabel
  have equal := (Kv.address_unique (capacity+256) oldLabel.1 newLabel.1 (oldTime oldLabel) (newTime capacity newLabel)
    (coordinate oldLabel) (coordinate newLabel) (by omega) newBound.2 same).2.1
  omega

theorem correct_value (capacity : Nat) (source : HalfMemory.Bytes) (store : HalfMemory.Store)
    (inside : store ∈ (programs capacity source).flatten) : store.value=expected capacity source store.word := by
  simp only [programs, List.flatten_append, List.mem_append] at inside
  rcases inside with old | fresh
  · obtain ⟨label, rfl⟩ := Copy2D.member (oldLayout capacity) source store old
    exact (old_value capacity source label).symm
  · obtain ⟨label, rfl⟩ := Copy2D.member (newLayout capacity) zeros store fresh
    exact (new_value capacity source label).symm

theorem covers (capacity : Nat) (source : HalfMemory.Bytes) (head : Fin 4) (time : Fin (capacity+256)) (i : Fin 256) :
    ∃ store ∈ (programs capacity source).flatten, store.word=Kv.address (capacity+256) head time.val i := by
  by_cases old : time.val<capacity
  · let label : Copy2D.Label 4 (capacity*256) := (head, ⟨time.val*256+i.val, by have := i.isLt; omega⟩)
    refine ⟨Copy2D.entry (oldLayout capacity) source label, ?_, ?_⟩
    · simp only [programs, List.flatten_append, List.mem_append]
      exact Or.inl (Copy2D.covers _ _ label)
    · dsimp [Copy2D.entry, Copy2D.destination, oldLayout, label, Kv.address]
      ring
  · let label : Copy2D.Label 4 (256*256) := (head, ⟨(time.val-capacity)*256+i.val, by have := i.isLt; have := time.isLt; omega⟩)
    refine ⟨Copy2D.entry (newLayout capacity) zeros label, ?_, ?_⟩
    · simp only [programs, List.flatten_append, List.mem_append]
      exact Or.inr (Copy2D.covers _ _ label)
    · dsimp [Copy2D.entry, Copy2D.destination, newLayout, label, Kv.address]
      ring_nf
      omega

theorem stored (capacity : Nat) (source : HalfMemory.Bytes) (before : HalfMemory.Words)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs capacity source) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (head : Fin 4) (time : Fin (capacity+256)) (i : Fin 256) :
    MemoryCells.execute schedule before (Kv.address (capacity+256) head time.val i)=
      expected capacity source (Kv.address (capacity+256) head time.val i) := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    rw [correct_value capacity source store inside, same]
  · exact covers capacity source head time i

structure Trace (capacity : Nat) (source : HalfMemory.Bytes) where
  before : HalfMemory.Bytes
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs capacity source) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (capacity : Nat) (source before : HalfMemory.Bytes) : Trace capacity source :=
  let stores := programs capacity source
  ⟨before, stores.flatten, List.replicate stores.length [], ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {capacity : Nat} {source : HalfMemory.Bytes}

def Trace.memory (trace : Trace capacity source) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before

theorem Trace.read_correct (trace : Trace capacity source) (head : Fin 4) (time : Fin (capacity+256)) (i : Fin 256) :
    HalfMemory.load trace.memory (2*Kv.address (capacity+256) head time.val i)=
      expected capacity source (Kv.address (capacity+256) head time.val i) := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by omega),
    show 2*Kv.address (capacity+256) head time.val i/2=Kv.address (capacity+256) head time.val i by omega]
  exact stored capacity source _ _ _ trace.execution trace.completed head time i

theorem Trace.preserves (trace : Trace capacity source) (head : Fin 4) (time : Fin capacity) (i : Fin 256) :
    HalfMemory.load trace.memory (2*Kv.address (capacity+256) head time.val i)=
      HalfMemory.load source (2*Kv.address capacity head time.val i) := by
  rw [trace.read_correct head ⟨time.val, by omega⟩ i]
  exact KvAllocation.concat_old capacity (HalfMemory.view source) head time.val time.isLt i

theorem Trace.extension_zero (trace : Trace capacity source) (head : Fin 4) (time : Fin 256) (i : Fin 256) :
    HalfMemory.load trace.memory (2*Kv.address (capacity+256) head (capacity+time.val) i)=0 := by
  rw [trace.read_correct head ⟨capacity+time.val, by omega⟩ i]
  exact KvAllocation.concat_zero capacity (HalfMemory.view source) head (capacity+time.val) (by omega) (by omega) i

end Inference.State.KvConcat
