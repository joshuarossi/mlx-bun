import contracts.mlx.MemoryRegions

namespace Inference.Contracts.Mlx.AllocatorSizes

-- Pinned MetalAllocator::malloc rounds requests larger than vm_page_size.
-- Small requests are left unchanged. The host page size is a parameter.
def rounded (page requested : Nat) : Nat :=
  if page<requested then page*((requested+page-1)/page) else requested

theorem rounded_bounds (page requested : Nat) (positive : 0<page) :
    requested ≤ rounded page requested ∧ rounded page requested < requested+page := by
  unfold rounded
  split
  · have remainder := Nat.mod_lt (requested+page-1) positive
    have division := Nat.mod_add_div (requested+page-1) page
    omega
  · omega

theorem rounded_small (page requested : Nat) (small : requested ≤ page) : rounded page requested=requested := by
  simp [rounded, show ¬page<requested by omega]

theorem rounded_multiple (page requested : Nat) (large : page<requested) : rounded page requested%page=0 := by
  simp [rounded, large]

theorem rounded_positive (page requested : Nat) (hp : 0<page) (hr : 0<requested) : 0<rounded page requested :=
  Nat.lt_of_lt_of_le hr (rounded_bounds page requested hp).1

-- The actual size_t operations agree with natural arithmetic under these
-- bounds. The product is below requested+page, not an additional assumption.
theorem rounded_no_overflow (page requested : Nat) (positive : 0<page) (bound : requested+page ≤ 2^64) :
    requested+page-1 < 2^64 ∧ rounded page requested < 2^64 := by
  have range := rounded_bounds page requested positive
  omega

-- lower_bound supplies length >= request. The following cutoff is exactly
-- the cache's rejection test; accepted buffers cover every requested byte.
def reusable (page requested length : Nat) : Prop :=
  requested ≤ length ∧ length < min (2*requested) (requested+2*page)

theorem reused_covers (page requested length : Nat) (accepted : reusable page requested length)
    (offset width : Nat) (inside : offset+width ≤ requested) : offset+width ≤ length :=
  Nat.le_trans inside accepted.1

theorem reused_limits (page requested length : Nat) (accepted : reusable page requested length) :
    length < 2*requested ∧ length < requested+2*page := by
  exact ⟨Nat.lt_of_lt_of_le accepted.2 (Nat.min_le_left _ _), Nat.lt_of_lt_of_le accepted.2 (Nat.min_le_right _ _)⟩

theorem cutoff_rejects_larger (page requested first later : Nat) (ordered : first ≤ later)
    (rejected : min (2*requested) (requested+2*page) ≤ first) : ¬reusable page requested later := by
  intro accepted
  exact Nat.not_lt_of_ge (Nat.le_trans rejected ordered) accepted.2

theorem request_fits (page requested length : Nat) (positive : 0<page)
    (capacity : rounded page requested ≤ length) : requested ≤ length :=
  Nat.le_trans (rounded_bounds page requested positive).1 capacity

theorem read_addressable (page requested length base offset width : Nat) (positive : 0<page)
    (capacity : rounded page requested ≤ length) (addressable : base+length ≤ 2^64)
    (inside : offset+width ≤ requested) : base+offset+width ≤ 2^64 := by
  have := request_fits page requested length positive capacity
  omega

end Inference.Contracts.Mlx.AllocatorSizes
