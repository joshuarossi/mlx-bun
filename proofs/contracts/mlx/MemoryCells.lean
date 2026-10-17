import contracts.mlx.ThreadgroupWrites

namespace Inference.Contracts.Mlx.MemoryCells

-- Cells retain their declared payload type. In particular raw uint words
-- never pass through a floating-point constructor before being read.
structure Store (α : Type u) where
  word : Nat
  value : α

def write (memory : Nat → α) (store : Store α) : Nat → α :=
  fun word => if word=store.word then store.value else memory word

def execute : List (Store α) → (Nat → α) → (Nat → α)
  | [], memory => memory
  | store::rest, memory => execute rest (write memory store)

theorem frame (stores : List (Store α)) (memory : Nat → α) (word : Nat)
    (h : ∀ store ∈ stores, store.word ≠ word) : execute stores memory word = memory word := by
  induction stores generalizing memory with
  | nil => rfl
  | cons store rest ih =>
    rw [execute, ih (write memory store) (fun s hs => h s (by simp [hs]))]
    unfold write
    exact ite_eq_right (Ne.symm (h store (by simp)))

theorem written_value (stores : List (Store α)) (memory : Nat → α) (word : Nat) (value : α)
    (values : ∀ store ∈ stores, store.word=word → store.value=value)
    (covered : ∃ store ∈ stores, store.word=word) : execute stores memory word=value := by
  induction stores generalizing memory with
  | nil => simp at covered
  | cons store rest ih =>
    by_cases tail : ∃ s ∈ rest, s.word=word
    · exact ih (write memory store) (fun s hs => values s (by simp [hs])) tail
    · have frameRest : ∀ s ∈ rest, s.word ≠ word := by
        intro s hs he
        exact tail ⟨s, hs, he⟩
      have head : store.word=word := by
        obtain ⟨s, hs, he⟩ := covered
        rcases List.mem_cons.mp hs with h | h
        · subst s; exact he
        · exact False.elim (tail ⟨s, h, he⟩)
      rw [execute, frame rest (write memory store) word frameRest]
      simp only [write, head, ite_true]
      exact values store (by simp) head

theorem completed_value {programs after : List (List (Store α))} {schedule : List (Store α)}
    (execution : ThreadgroupWrites.Executes programs schedule after) (ready : ThreadgroupWrites.AtBarrier after)
    (memory : Nat → α) (word : Nat) (value : α)
    (values : ∀ store ∈ programs.flatten, store.word=word → store.value=value)
    (covered : ∃ store ∈ programs.flatten, store.word=word) : execute schedule memory word=value := by
  have order := ThreadgroupWrites.completed_schedule execution ready
  apply written_value schedule memory word value
  · intro store member equal
    exact values store (order.mem_iff.mp member) equal
  · obtain ⟨store, member, equal⟩ := covered
    exact ⟨store, order.mem_iff.mpr member, equal⟩

end Inference.Contracts.Mlx.MemoryCells
