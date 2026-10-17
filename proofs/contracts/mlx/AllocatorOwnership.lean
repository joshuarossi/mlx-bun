import contracts.mlx.MemoryRegions
import Mathlib.Data.Finset.Basic

namespace Inference.Contracts.Mlx.AllocatorOwnership

-- Ownership transitions for the pinned MetalAllocator/BufferCache path.
-- The mutex serializes cache removal/insertion. A valid free transfers the
-- caller's last live ownership; proving that precondition from array and
-- command-buffer lifetimes remains separate. Fresh Metal buffers must be
-- disjoint from every unreleased buffer. make_buffer aliases are excluded.
structure Buffer where
  id : Nat
  base : Nat
  size : Nat
  deriving DecidableEq

def Buffer.Separate (a b : Buffer) : Prop := MemoryRegions.Disjoint a.base a.size b.base b.size
def Buffer.Valid (buffer : Buffer) : Prop := 0<buffer.size ∧ buffer.base+buffer.size ≤ 2^64

structure State where
  active : Finset Buffer
  cached : Finset Buffer

def State.owned (state : State) : Finset Buffer := state.active ∪ state.cached
structure Valid (state : State) : Prop where
  exclusive : Disjoint state.active state.cached
  metadata : ∀ a ∈ state.owned, ∀ b ∈ state.owned, a.id=b.id → a=b
  ranges : ∀ buffer ∈ state.owned, buffer.Valid
  separate : ∀ a ∈ state.owned, ∀ b ∈ state.owned, a≠b → a.Separate b

def reuse (state : State) (buffer : Buffer) : State := ⟨insert buffer state.active, state.cached.erase buffer⟩
def recycle (state : State) (buffer : Buffer) : State := ⟨state.active.erase buffer, insert buffer state.cached⟩
def fresh (state : State) (buffer : Buffer) : State := ⟨insert buffer state.active, state.cached⟩
def release (state : State) (buffer : Buffer) : State := ⟨state.active.erase buffer, state.cached.erase buffer⟩

theorem reuse_owned (state : State) (buffer : Buffer) (cached : buffer ∈ state.cached) :
    (reuse state buffer).owned=state.owned := by
  ext value
  simp only [State.owned, reuse, Finset.mem_union, Finset.mem_insert, Finset.mem_erase]
  by_cases equal : value=buffer
  · subst value; simp [cached]
  · simp [ne_eq, equal]

theorem recycle_owned (state : State) (buffer : Buffer) (active : buffer ∈ state.active) :
    (recycle state buffer).owned=state.owned := by
  ext value
  simp only [State.owned, recycle, Finset.mem_union, Finset.mem_insert, Finset.mem_erase]
  by_cases equal : value=buffer
  · subst value; simp [active]
  · simp [ne_eq, equal]

theorem reuse_valid (state : State) (valid : Valid state) (buffer : Buffer) (cached : buffer ∈ state.cached) :
    Valid (reuse state buffer) where
  exclusive := by
    apply Finset.disjoint_left.mpr
    intro value live stored
    obtain ⟨different, oldStored⟩ := Finset.mem_erase.mp stored
    rcases Finset.mem_insert.mp live with equal|oldLive
    · exact different equal
    · exact Finset.disjoint_left.mp valid.exclusive oldLive oldStored
  metadata := by simpa only [reuse_owned state buffer cached] using valid.metadata
  ranges := by simpa only [reuse_owned state buffer cached] using valid.ranges
  separate := by simpa only [reuse_owned state buffer cached] using valid.separate

theorem recycle_valid (state : State) (valid : Valid state) (buffer : Buffer) (active : buffer ∈ state.active) :
    Valid (recycle state buffer) where
  exclusive := by
    apply Finset.disjoint_left.mpr
    intro value live stored
    obtain ⟨different, oldLive⟩ := Finset.mem_erase.mp live
    rcases Finset.mem_insert.mp stored with equal|oldStored
    · exact different equal
    · exact Finset.disjoint_left.mp valid.exclusive oldLive oldStored
  metadata := by simpa only [recycle_owned state buffer active] using valid.metadata
  ranges := by simpa only [recycle_owned state buffer active] using valid.ranges
  separate := by simpa only [recycle_owned state buffer active] using valid.separate

theorem active_separate (state : State) (valid : Valid state) (a b : Buffer)
    (left : a ∈ state.active) (right : b ∈ state.active) (different : a≠b) : a.Separate b :=
  valid.separate a (Finset.mem_union_left _ left) b (Finset.mem_union_left _ right) different

theorem reused_separate (state : State) (valid : Valid state) (buffer : Buffer) (cached : buffer ∈ state.cached)
    (other : Buffer) (active : other ∈ state.active) : buffer.Separate other := by
  apply valid.separate buffer (Finset.mem_union_right _ cached) other (Finset.mem_union_left _ active)
  intro equal
  subst other
  exact Finset.disjoint_left.mp valid.exclusive active cached

-- A recycled allocation remains owned by the allocator; reuse removes it
-- from the cache before making it active. Its physical region is unchanged.
theorem reused_membership (state : State) (buffer : Buffer) :
    buffer ∈ (reuse state buffer).active ∧ buffer ∉ (reuse state buffer).cached := by
  simp [reuse]

theorem recycled_membership (state : State) (buffer : Buffer) :
    buffer ∉ (recycle state buffer).active ∧ buffer ∈ (recycle state buffer).cached := by
  simp [recycle]

theorem fresh_owned (state : State) (buffer : Buffer) : (fresh state buffer).owned=insert buffer state.owned := by
  ext value
  simp [State.owned, fresh, or_assoc]

theorem fresh_valid (state : State) (valid : Valid state) (buffer : Buffer) (range : buffer.Valid)
    (newId : ∀ old ∈ state.owned, buffer.id≠old.id)
    (newRegion : ∀ old ∈ state.owned, buffer.Separate old) : Valid (fresh state buffer) where
  exclusive := by
    apply Finset.disjoint_left.mpr
    intro value live cached
    rcases Finset.mem_insert.mp live with equal|oldLive
    · subst value
      exact newId buffer (Finset.mem_union_right _ cached) rfl
    · exact Finset.disjoint_left.mp valid.exclusive oldLive cached
  metadata := by
    intro a ha b hb same
    rw [fresh_owned] at ha hb
    rcases Finset.mem_insert.mp ha with rfl|oldA <;> rcases Finset.mem_insert.mp hb with rfl|oldB
    · rfl
    · exact False.elim (newId b oldB same)
    · exact False.elim (newId a oldA same.symm)
    · exact valid.metadata a oldA b oldB same
  ranges := by
    intro value member
    rw [fresh_owned] at member
    rcases Finset.mem_insert.mp member with rfl|old
    · exact range
    · exact valid.ranges value old
  separate := by
    intro a ha b hb different
    rw [fresh_owned] at ha hb
    rcases Finset.mem_insert.mp ha with rfl|oldA <;> rcases Finset.mem_insert.mp hb with rfl|oldB
    · exact False.elim (different rfl)
    · exact newRegion b oldB
    · exact MemoryRegions.disjoint_symm (newRegion a oldA)
    · exact valid.separate a oldA b oldB different

theorem release_owned_subset (state : State) (buffer : Buffer) : (release state buffer).owned ⊆ state.owned := by
  intro value member
  rcases Finset.mem_union.mp member with active|cached
  · exact Finset.mem_union_left _ (Finset.mem_erase.mp active).2
  · exact Finset.mem_union_right _ (Finset.mem_erase.mp cached).2

theorem release_valid (state : State) (valid : Valid state) (buffer : Buffer) : Valid (release state buffer) where
  exclusive := by
    apply Finset.disjoint_left.mpr
    intro value active cached
    exact Finset.disjoint_left.mp valid.exclusive (Finset.mem_erase.mp active).2 (Finset.mem_erase.mp cached).2
  metadata := fun a ha b hb same => valid.metadata a (release_owned_subset state buffer ha) b (release_owned_subset state buffer hb) same
  ranges := fun value member => valid.ranges value (release_owned_subset state buffer member)
  separate := fun a ha b hb different => valid.separate a (release_owned_subset state buffer ha) b (release_owned_subset state buffer hb) different

theorem empty_valid : Valid ⟨∅, ∅⟩ where
  exclusive := by simp
  metadata := by simp [State.owned]
  ranges := by simp [State.owned]
  separate := by simp [State.owned]

end Inference.Contracts.Mlx.AllocatorOwnership
