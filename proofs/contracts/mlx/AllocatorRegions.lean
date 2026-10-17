import contracts.mlx.AllocatorOwnership
import contracts.mlx.AllocatorSizes

namespace Inference.Contracts.Mlx.AllocatorRegions
open AllocatorOwnership

-- Tensor views may occupy only part of an allocation. Separation of live
-- allocations implies separation of all such bounded tensor views.
structure Slice (buffer : Buffer) where
  offset : Nat
  length : Nat
  bounded : offset+length ≤ buffer.size

def Slice.base {buffer : Buffer} (slice : Slice buffer) : Nat := buffer.base+slice.offset

theorem Slice.addressable {buffer : Buffer} (slice : Slice buffer) (valid : buffer.Valid) :
    slice.base+slice.length ≤ 2^64 := by
  have := slice.bounded
  dsimp [Slice.base]
  obtain ⟨_, bound⟩ := valid
  omega

theorem slices_separate {a b : Buffer} (first : Slice a) (second : Slice b) (separate : a.Separate b) :
    MemoryRegions.Disjoint first.base first.length second.base second.length := by
  have := first.bounded
  have := second.bounded
  dsimp [Buffer.Separate, MemoryRegions.Disjoint] at separate
  dsimp [MemoryRegions.Disjoint, Slice.base]
  omega

theorem live_slices (state : State) (valid : Valid state) {a b : Buffer}
    (first : Slice a) (second : Slice b) (activeA : a ∈ state.active) (activeB : b ∈ state.active) (different : a≠b) :
    MemoryRegions.Disjoint first.base first.length second.base second.length :=
  slices_separate first second (active_separate state valid a b activeA activeB different)

theorem reused_slice (state : State) (valid : Valid state) {allocation live : Buffer}
    (output : Slice allocation) (retained : Slice live) (cached : allocation ∈ state.cached) (active : live ∈ state.active) :
    MemoryRegions.Disjoint output.base output.length retained.base retained.length :=
  slices_separate output retained (reused_separate state valid allocation cached live active)

def requested (buffer : Buffer) (page request : Nat) (positive : 0<page)
    (capacity : AllocatorSizes.rounded page request ≤ buffer.size) : Slice buffer :=
  ⟨0, request, by simpa only [Nat.zero_add] using AllocatorSizes.request_fits page request buffer.size positive capacity⟩

theorem requested_base (buffer : Buffer) (page request : Nat) (positive : 0<page)
    (capacity : AllocatorSizes.rounded page request ≤ buffer.size) :
    (requested buffer page request positive capacity).base=buffer.base := by
  simp only [requested, Slice.base, Nat.add_zero]

theorem requested_length (buffer : Buffer) (page request : Nat) (positive : 0<page)
    (capacity : AllocatorSizes.rounded page request ≤ buffer.size) :
    (requested buffer page request positive capacity).length=request := rfl

end Inference.Contracts.Mlx.AllocatorRegions
