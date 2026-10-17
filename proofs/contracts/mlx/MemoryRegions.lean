import contracts.mlx.HalfMemory

namespace Inference.Contracts.Mlx.MemoryRegions

-- Relate the local byte images used by kernel proofs to regions in one
-- shared memory. Allocation addresses and non-overlap remain allocator
-- inputs; readback and preservation follow from the concrete store lists.
def view (memory : ByteMemory.Bytes) (base : Nat) : ByteMemory.Bytes := fun offset => memory (base+offset)

theorem load32_view (memory : ByteMemory.Bytes) (base address : Nat) :
    ByteMemory.load32 (view memory base) address=ByteMemory.load32 memory (base+address) := by
  simp only [ByteMemory.load32, view, Nat.add_assoc]

theorem load16_view (memory : ByteMemory.Bytes) (base address : Nat) :
    HalfMemory.load (view memory base) address=HalfMemory.load memory (base+address) := by
  simp only [HalfMemory.load, view, Nat.add_assoc]

theorem store32_view (memory : ByteMemory.Bytes) (base address : Nat) (value : BitVec 32) :
    view (ByteMemory.store32 memory (base+address) value) base=ByteMemory.store32 (view memory base) address value := by
  funext offset
  simp only [view, ByteMemory.store32, Nat.add_assoc, Nat.add_le_add_iff_left, Nat.add_lt_add_iff_left,
    Nat.add_sub_add_left]

theorem store16_view (memory : ByteMemory.Bytes) (base address : Nat) (value : BitVec 16) :
    view (HalfMemory.store memory (base+address) value) base=HalfMemory.store (view memory base) address value := by
  funext offset
  simp only [view, HalfMemory.store, Nat.add_assoc, Nat.add_le_add_iff_left, Nat.add_lt_add_iff_left,
    Nat.add_sub_add_left]

def shift32 (base : Nat) (store : ByteMemory.Store) : ByteMemory.Store := ⟨base/4+store.word, store.value⟩
def shift16 (base : Nat) (store : HalfMemory.Store) : HalfMemory.Store := ⟨base/2+store.word, store.value⟩

theorem execute32_view (stores : List ByteMemory.Store) (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) :
    view (ByteMemory.execute (stores.map (shift32 base)) memory) base=ByteMemory.execute stores (view memory base) := by
  induction stores generalizing memory with
  | nil => rfl
  | cons store rest ih =>
    simp only [List.map_cons, ByteMemory.execute, shift32]
    rw [ih, show 4*(base/4+store.word)=base+4*store.word by omega, store32_view]

theorem execute16_view (stores : List HalfMemory.Store) (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%2=0) :
    view (HalfMemory.execute (stores.map (shift16 base)) memory) base=HalfMemory.execute stores (view memory base) := by
  induction stores generalizing memory with
  | nil => rfl
  | cons store rest ih =>
    simp only [List.map_cons, HalfMemory.execute, shift16]
    rw [ih, show 2*(base/2+store.word)=base+2*store.word by omega, store16_view]

def Inside32 (base size : Nat) (stores : List ByteMemory.Store) : Prop :=
  ∀ store ∈ stores, base ≤ 4*store.word ∧ 4*store.word+4 ≤ base+size
def Inside16 (base size : Nat) (stores : List HalfMemory.Store) : Prop :=
  ∀ store ∈ stores, base ≤ 2*store.word ∧ 2*store.word+2 ≤ base+size

theorem execute32_frame (stores : List ByteMemory.Store) (memory : ByteMemory.Bytes)
    (inside : Inside32 base size stores) (outside : address<base ∨ base+size ≤ address) :
    ByteMemory.execute stores memory address=memory address := by
  induction stores generalizing memory with
  | nil => rfl
  | cons store rest ih =>
    rw [ByteMemory.execute, ih (inside := fun s h => inside s (List.mem_cons_of_mem _ h))]
    apply ByteMemory.store32_frame
    have := inside store (List.mem_cons_self)
    omega

theorem execute16_frame (stores : List HalfMemory.Store) (memory : ByteMemory.Bytes)
    (inside : Inside16 base size stores) (outside : address<base ∨ base+size ≤ address) :
    HalfMemory.execute stores memory address=memory address := by
  induction stores generalizing memory with
  | nil => rfl
  | cons store rest ih =>
    rw [HalfMemory.execute, ih (inside := fun s h => inside s (List.mem_cons_of_mem _ h))]
    have := inside store (List.mem_cons_self)
    have miss : ¬(2*store.word ≤ address ∧ address<2*store.word+2) := by omega
    simp only [HalfMemory.store, miss, ite_false]

def Disjoint (first firstSize second secondSize : Nat) : Prop :=
  first+firstSize ≤ second ∨ second+secondSize ≤ first

theorem disjoint_symm (separate : Disjoint first firstSize second secondSize) : Disjoint second secondSize first firstSize :=
  separate.symm

theorem execute32_other (stores : List ByteMemory.Store) (memory : ByteMemory.Bytes)
    (inside : Inside32 base size stores) (separate : Disjoint base size other otherSize)
    (offset : Nat) (bound : offset<otherSize) :
    view (ByteMemory.execute stores memory) other offset=view memory other offset := by
  exact execute32_frame stores memory inside (by rcases separate with h|h <;> omega)

theorem execute16_other (stores : List HalfMemory.Store) (memory : ByteMemory.Bytes)
    (inside : Inside16 base size stores) (separate : Disjoint base size other otherSize)
    (offset : Nat) (bound : offset<otherSize) :
    view (HalfMemory.execute stores memory) other offset=view memory other offset := by
  exact execute16_frame stores memory inside (by rcases separate with h|h <;> omega)

theorem shift32_inside (stores : List ByteMemory.Store) (bounded : Inside32 0 size stores)
    (base : Nat) (aligned : base%4=0) : Inside32 base size (stores.map (shift32 base)) := by
  intro store member
  obtain ⟨original, originalMember, rfl⟩ := List.mem_map.mp member
  have := bounded original originalMember
  dsimp only [shift32]
  omega

theorem shift16_inside (stores : List HalfMemory.Store) (bounded : Inside16 0 size stores)
    (base : Nat) (aligned : base%2=0) : Inside16 base size (stores.map (shift16 base)) := by
  intro store member
  obtain ⟨original, originalMember, rfl⟩ := List.mem_map.mp member
  have := bounded original originalMember
  dsimp only [shift16]
  omega

end Inference.Contracts.Mlx.MemoryRegions
