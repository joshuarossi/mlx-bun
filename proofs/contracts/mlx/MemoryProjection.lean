import contracts.mlx.MemoryRegions

namespace Inference.Contracts.Mlx.MemoryProjection

-- Project a mixed store schedule onto one buffer without changing the
-- order of its writes. Compatibility is proved per byte by each consumer.
def execute (write : α → ByteMemory.Bytes → ByteMemory.Bytes) : List α → ByteMemory.Bytes → ByteMemory.Bytes
  | [], memory => memory
  | event::rest, memory => execute write rest (write event memory)

theorem project_at (write : α → ByteMemory.Bytes → ByteMemory.Bytes) (project : α → Option β)
    (selectedWrite : β → ByteMemory.Bytes → ByteMemory.Bytes) (events : List α) (address : Nat)
    (compatible : ∀ event ∈ events, ∀ first second : ByteMemory.Bytes, first address=second address →
      write event first address=(match project event with | none => second | some selected => selectedWrite selected second) address)
    (first second : ByteMemory.Bytes) (same : first address=second address) :
    execute write events first address=execute selectedWrite (events.filterMap project) second address := by
  induction events generalizing first second with
  | nil => exact same
  | cons event rest ih =>
    have next := compatible event List.mem_cons_self first second same
    have tail := fun event member => compatible event (List.mem_cons_of_mem _ member)
    cases selected : project event with
    | none =>
      simp only [execute, List.filterMap_cons, selected]
      exact ih tail _ _ (by simpa only [selected] using next)
    | some value =>
      simp only [execute, List.filterMap_cons, selected]
      exact ih tail _ _ (by simpa only [selected] using next)

theorem frame (write : α → ByteMemory.Bytes → ByteMemory.Bytes) (events : List α) (address : Nat)
    (misses : ∀ event ∈ events, ∀ memory, write event memory address=memory address) (before : ByteMemory.Bytes) :
    execute write events before address=before address := by
  induction events generalizing before with
  | nil => rfl
  | cons event rest ih =>
    rw [execute, ih (fun next member => misses next (List.mem_cons_of_mem _ member)), misses event List.mem_cons_self]

def wordWrite (store : ByteMemory.Store) (memory : ByteMemory.Bytes) : ByteMemory.Bytes :=
  ByteMemory.store32 memory (4*store.word) store.value
def halfWrite (store : HalfMemory.Store) (memory : ByteMemory.Bytes) : ByteMemory.Bytes :=
  HalfMemory.store memory (2*store.word) store.value

theorem words (stores : List ByteMemory.Store) (before : ByteMemory.Bytes) :
    execute wordWrite stores before=ByteMemory.execute stores before := by
  induction stores generalizing before with
  | nil => rfl
  | cons store rest ih => exact ih (wordWrite store before)

theorem halves (stores : List HalfMemory.Store) (before : ByteMemory.Bytes) :
    execute halfWrite stores before=HalfMemory.execute stores before := by
  induction stores generalizing before with
  | nil => rfl
  | cons store rest ih => exact ih (halfWrite store before)

theorem word_congr (store : ByteMemory.Store) (first second : ByteMemory.Bytes) (address : Nat)
    (same : first address=second address) : wordWrite store first address=wordWrite store second address := by
  unfold wordWrite ByteMemory.store32
  split
  · rfl
  · exact same

theorem half_congr (store : HalfMemory.Store) (first second : ByteMemory.Bytes) (address : Nat)
    (same : first address=second address) : halfWrite store first address=halfWrite store second address := by
  unfold halfWrite HalfMemory.store
  split
  · rfl
  · exact same

theorem word_misses (store : ByteMemory.Store) (inside : base ≤ 4*store.word ∧ 4*store.word+4 ≤ base+size)
    (separate : MemoryRegions.Disjoint base size other otherSize) (offset : Nat) (bound : offset<otherSize)
    (memory : ByteMemory.Bytes) : wordWrite store memory (other+offset)=memory (other+offset) := by
  have miss : ¬(4*store.word ≤ other+offset ∧ other+offset<4*store.word+4) := by
    rcases separate with h|h <;> omega
  simp only [wordWrite, ByteMemory.store32, miss, ite_false]

theorem half_misses (store : HalfMemory.Store) (inside : base ≤ 2*store.word ∧ 2*store.word+2 ≤ base+size)
    (separate : MemoryRegions.Disjoint base size other otherSize) (offset : Nat) (bound : offset<otherSize)
    (memory : ByteMemory.Bytes) : halfWrite store memory (other+offset)=memory (other+offset) := by
  have miss : ¬(2*store.word ≤ other+offset ∧ other+offset<2*store.word+2) := by
    rcases separate with h|h <;> omega
  simp only [halfWrite, HalfMemory.store, miss, ite_false]

end Inference.Contracts.Mlx.MemoryProjection
