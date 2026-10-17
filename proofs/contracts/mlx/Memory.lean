import contracts.mlx.M1Max

namespace Inference.Contracts.Mlx.Memory
open M1Max

structure Store where
  word : Nat
  value : Float32

def write (memory : WordMemory) (store : Store) : WordMemory :=
  fun word => if word=store.word then store.value else memory word

def execute : List Store → WordMemory → WordMemory
  | [], memory => memory
  | store::rest, memory => execute rest (write memory store)

theorem frame (stores : List Store) (memory : WordMemory) (word : Nat)
    (h : ∀ store ∈ stores, store.word ≠ word) : execute stores memory word = memory word := by
  induction stores generalizing memory with
  | nil => rfl
  | cons store rest ih =>
    rw [execute, ih (write memory store) (fun s hs => h s (by simp [hs]))]
    unfold write
    exact ite_eq_right (Ne.symm (h store (by simp)))

-- Any ordering of stores which write the same value at an address establishes
-- that value there. No scheduling order or initial memory value is assumed.
theorem written_value (stores : List Store) (memory : WordMemory) (word : Nat) (value : Float32)
    (values : ∀ store ∈ stores, store.word=word → store.value=value)
    (covered : ∃ store ∈ stores, store.word=word) : execute stores memory word = value := by
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

theorem written_value_permuted (stores reordered : List Store) (order : reordered.Perm stores)
    (memory : WordMemory) (word : Nat) (value : Float32)
    (values : ∀ store ∈ stores, store.word=word → store.value=value)
    (covered : ∃ store ∈ stores, store.word=word) : execute reordered memory word = value := by
  apply written_value
  · intro s hs he
    exact values s (order.mem_iff.mp hs) he
  · obtain ⟨s, hs, he⟩ := covered
    exact ⟨s, order.mem_iff.mpr hs, he⟩

-- Logical cells are independent of byte width. In particular bf16 device
-- elements are not treated as the four-byte words used by scratch loads.
def putCell (memory : Nat → α) (index : Nat) (value : α) : Nat → α :=
  fun i => if i = index then value else memory i

def writeCells (values : Nat → α) : List Nat → (Nat → α) → (Nat → α)
  | [], memory => memory
  | i :: rest, memory => writeCells values rest (putCell memory i (values i))

def mapCells (f : Nat → α → α) : List Nat → (Nat → α) → (Nat → α)
  | [], memory => memory
  | i :: rest, memory => mapCells f rest (putCell memory i (f i (memory i)))

theorem writeCells_read (values : Nat → α) (indices : List Nat) (before : Nat → α) (i : Nat) :
    writeCells values indices before i = if i ∈ indices then values i else before i := by
  induction indices generalizing before with
  | nil => simp [writeCells]
  | cons j rest ih =>
    by_cases ht : i ∈ rest
    · simp [writeCells, ih, ht]
    · by_cases hj : i = j
      · subst j
        simp [writeCells, ih, ht, putCell]
      · simp [writeCells, ih, ht, hj, putCell]

theorem mapCells_eq_writeCells (f : Nat → α → α) (indices : List Nat) (original before : Nat → α)
    (hn : indices.Nodup) (ha : ∀ i ∈ indices, before i = original i) :
    mapCells f indices before = writeCells (fun i => f i (original i)) indices before := by
  induction indices generalizing before with
  | nil => rfl
  | cons i rest ih =>
    have hnodup := List.nodup_cons.mp hn
    have hhead := ha i (by simp)
    simp only [mapCells, writeCells, hhead]
    apply ih _ hnodup.2
    intro j hj
    have hne : j ≠ i := by intro h; subst j; exact hnodup.1 hj
    simp only [putCell, hne, ite_false]
    exact ha j (by simp [hj])

-- No address is updated twice. Consequently an in-place elementwise pass
-- reads each cell's original value, regardless of the order of its owners.
theorem mapCells_read (f : Nat → α → α) (indices : List Nat) (before : Nat → α)
    (hn : indices.Nodup) (i : Nat) :
    mapCells f indices before i = if i ∈ indices then f i (before i) else before i := by
  rw [mapCells_eq_writeCells f indices before before hn (fun _ _ => rfl), writeCells_read]

end Inference.Contracts.Mlx.Memory
