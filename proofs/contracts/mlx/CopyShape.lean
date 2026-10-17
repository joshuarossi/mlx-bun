import Std

namespace Inference.Contracts.Mlx.CopyShape

-- Positive-stride specialization of the two-array overload of
-- collapse_contiguous_dims in mlx/backend/common/utils.cpp. None is its
-- separator; singleton axes are omitted, but still affect the boundary and
-- running size. collect multiplies each segment and retains its last strides.
structure Axis where
  size : Nat
  source : Nat
  destination : Nat
  deriving DecidableEq

structure Scan where
  previous : Axis
  size : Nat
  tokens : List (Option Axis)

def step (limit : Nat) (state : Scan) (axis : Axis) : Scan :=
  let size := state.size*axis.size
  let contiguous := axis.source*axis.size=state.previous.source ∧
    axis.destination*axis.size=state.previous.destination ∧ size ≤ limit
  ⟨axis, if contiguous then size else axis.size,
    (state.tokens ++ if contiguous then [] else [none]) ++ if axis.size=1 then [] else [some axis]⟩

def collect : List (Option Axis) → Option Axis → List Axis
  | [], none => []
  | [], some current => [current]
  | none::rest, none => collect rest none
  | none::rest, some current => current::collect rest none
  | some axis::rest, none => collect rest (some axis)
  | some axis::rest, some current => collect rest (some ⟨current.size*axis.size, axis.source, axis.destination⟩)

def collapse (limit : Nat) : List Axis → List Axis
  | [] => []
  | first::rest =>
    let initial : Scan := ⟨first, first.size, if first.size=1 then [] else [some first]⟩
    let tokens := (rest.foldl (step limit) initial).tokens ++ [none]
    match collect tokens none with
    | [] => [⟨1, 0, 0⟩]
    | result => result

theorem append_axes (capacity : Nat) (largeEnough : 1<capacity)
    (sourceBatch sourceHead sourceTime sourceCoordinate : Nat) :
    collapse (2^31-1) [⟨1, sourceBatch, 4*capacity*256⟩, ⟨4, sourceHead, capacity*256⟩,
      ⟨1, sourceTime, 256⟩, ⟨256, sourceCoordinate, 1⟩]=
      [⟨4, sourceHead, capacity*256⟩, ⟨256, sourceCoordinate, 1⟩] := by
  have boundary : 256 ≠ capacity*256 := by omega
  by_cases first : sourceHead*4=sourceBatch <;> by_cases last : sourceCoordinate*256=sourceTime <;>
    simp [collapse, step, collect, first, last, boundary, Nat.mul_comm, Nat.mul_left_comm, Nat.mul_assoc]

theorem concat_axes (size capacity : Nat) (positive : 0<size) (gap : size<capacity) (supported : size ≤ 262144) :
    collapse (2^31-1) [⟨1, 4*size*256, 4*capacity*256⟩, ⟨4, size*256, capacity*256⟩,
      ⟨size, 256, 256⟩, ⟨256, 1, 1⟩]=
      [⟨4, size*256, capacity*256⟩, ⟨size*256, 1, 1⟩] := by
  have boundary : size*256 ≠ capacity*256 := by omega
  have last : size*256 ≤ 2147483647 := by omega
  by_cases one : size=1
  · subst size
    simpa only [Nat.one_mul] using append_axes capacity (by omega) 1024 256 256 1
  · simp [collapse, step, collect, one, boundary, last, Nat.mul_comm, Nat.mul_left_comm, Nat.mul_assoc]

-- With two collapsed dimensions the host selects copy_gg_nd2 (one scalar
-- element per grid thread), rather than the general >3-dimension loop.
theorem append_dimension (capacity : Nat) (largeEnough : 1<capacity)
    (sourceBatch sourceHead sourceTime sourceCoordinate : Nat) :
    (collapse (2^31-1) [⟨1, sourceBatch, 4*capacity*256⟩, ⟨4, sourceHead, capacity*256⟩,
      ⟨1, sourceTime, 256⟩, ⟨256, sourceCoordinate, 1⟩]).length=2 := by
  rw [append_axes capacity largeEnough]
  rfl

end Inference.Contracts.Mlx.CopyShape
