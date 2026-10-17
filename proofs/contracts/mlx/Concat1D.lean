import contracts.mlx.Copy1D

namespace Inference.Contracts.Mlx.Concat1D

-- Two one-word-per-thread copies share one destination allocation.
-- Any legal interleaving is admitted, including the concurrent concat
-- dispatch. Source values can be raw loads from two different buffers.
def joined (left : Fin a → α) (right : Fin b → α) (i : Fin (a+b)) : α :=
  if h : i.val<a then left ⟨i.val, h⟩ else right ⟨i.val-a, by have := i.isLt; omega⟩

def expected (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) (word : Nat) : BitVec 16 :=
  if h : word<a then left ⟨word, h⟩ else if h : word<a+b then right ⟨word-a, by omega⟩ else 0

theorem expected_joined (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) (i : Fin (a+b)) :
    expected left right i.val=joined left right i := by
  simp only [expected, joined, i.isLt, ↓reduceDIte]

def programs (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) : List (List HalfMemory.Store) :=
  HalfArrayWrites.programs 0 left ++ HalfArrayWrites.programs (2*a) right

theorem left_value (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) (i : Fin a) :
    expected left right (HalfArrayWrites.entry 0 left i).word=(HalfArrayWrites.entry 0 left i).value := by
  simp only [HalfArrayWrites.entry, Nat.zero_div, Nat.zero_add, expected, i.isLt, ↓reduceDIte]

theorem right_value (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) (i : Fin b) :
    expected left right (HalfArrayWrites.entry (2*a) right i).word=(HalfArrayWrites.entry (2*a) right i).value := by
  have ib := i.isLt
  simp only [HalfArrayWrites.entry, show 2*a/2=a by omega, expected,
    show ¬a+i.val<a by omega, show a+i.val<a+b by omega, ↓reduceDIte, Nat.add_sub_cancel_left]

theorem correct_value (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) (store : HalfMemory.Store)
    (inside : store ∈ (programs left right).flatten) : store.value=expected left right store.word := by
  simp only [programs, List.flatten_append, List.mem_append] at inside
  rcases inside with h | h
  · obtain ⟨i, rfl⟩ := HalfArrayWrites.member 0 left store h
    exact (left_value left right i).symm
  · obtain ⟨i, rfl⟩ := HalfArrayWrites.member (2*a) right store h
    exact (right_value left right i).symm

theorem covers (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) (i : Fin (a+b)) :
    ∃ store ∈ (programs left right).flatten, store.word=i.val := by
  by_cases h : i.val<a
  · refine ⟨HalfArrayWrites.entry 0 left ⟨i.val, h⟩, ?_, by simp only [HalfArrayWrites.entry, Nat.zero_div, Nat.zero_add]⟩
    simp only [programs, List.flatten_append, List.mem_append]
    exact Or.inl (HalfArrayWrites.covers _ _ _)
  · let j : Fin b := ⟨i.val-a, by have := i.isLt; omega⟩
    refine ⟨HalfArrayWrites.entry (2*a) right j, ?_, ?_⟩
    · simp only [programs, List.flatten_append, List.mem_append]
      exact Or.inr (HalfArrayWrites.covers _ _ _)
    · dsimp [HalfArrayWrites.entry, j]
      omega

theorem separated (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) :
    WriteOwnership.Separated MemoryCells.Store.word (programs left right) := by
  unfold WriteOwnership.Separated programs
  apply List.pairwise_append.mpr
  refine ⟨HalfArrayWrites.separated _ _, HalfArrayWrites.separated _ _, ?_⟩
  intro leftThread hl rightThread hr word wl wr
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp hl
  obtain ⟨j, _, rfl⟩ := List.mem_map.mp hr
  have li : word=(HalfArrayWrites.entry 0 left i).word := by simpa only [List.map_singleton, List.mem_singleton] using wl
  have rj : word=(HalfArrayWrites.entry (2*a) right j).word := by simpa only [List.map_singleton, List.mem_singleton] using wr
  have := i.isLt
  dsimp [HalfArrayWrites.entry] at li rj
  omega

theorem stored (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) (before : HalfMemory.Words)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs left right) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (i : Fin (a+b)) :
    MemoryCells.execute schedule before i.val=joined left right i := by
  rw [← expected_joined]
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    rw [correct_value left right store inside, same]
  · exact covers left right i

structure Trace (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) where
  before : HalfMemory.Bytes
  bounded : 2*(a+b) ≤ 2^64
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs left right) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (left : Fin a → BitVec 16) (right : Fin b → BitVec 16) (bounded : 2*(a+b) ≤ 2^64) : Trace left right :=
  let stores := programs left right
  ⟨fun _ => 0, bounded, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {a b : Nat} {left : Fin a → BitVec 16} {right : Fin b → BitVec 16}

def Trace.memory (trace : Trace left right) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before

theorem Trace.read_correct (trace : Trace left right) (i : Fin (a+b)) :
    HalfMemory.load trace.memory (2*i.val)=joined left right i := by
  unfold Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by omega), show 2*i.val/2=i.val by omega]
  exact stored left right _ _ _ trace.execution trace.completed i

theorem Trace.left_read (trace : Trace left right) (i : Fin a) :
    HalfMemory.load trace.memory (2*i.val)=left i := by
  rw [trace.read_correct ⟨i.val, by omega⟩]
  simp only [joined, i.isLt, ↓reduceDIte]

theorem Trace.right_read (trace : Trace left right) (i : Fin b) :
    HalfMemory.load trace.memory (2*(a+i.val))=right i := by
  rw [trace.read_correct ⟨a+i.val, by have := i.isLt; omega⟩]
  simp only [joined, show ¬a+i.val<a by omega, ↓reduceDIte, Nat.add_sub_cancel_left]

end Inference.Contracts.Mlx.Concat1D
