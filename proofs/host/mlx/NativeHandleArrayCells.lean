import host.mlx.NativeBufferSlots
import host.ts.RenameParametricTypedArray

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

def handleArrayValues (R : Ren) (handles : List Nat) : List Val :=
  handles.map (fun handle => .big (Int.ofNat (R.handle handle)))

def handleValueLabels (values : List Val) : List Nat :=
  values.filterMap (fun value => match value with | .big (.ofNat n) => some n | _ => none)

def handleArrayCells (R : Ren) (handles : List Nat) : List Host.Ts.Cell :=
  handles.map (fun handle => .big (Int.ofNat (R.handle handle)))

def handleArrayBytes (handles : List Nat) : List Byte :=
  match handles with
  | [] => []
  | handle::rest => handleSlotNotes handle ++ handleArrayBytes rest

theorem handle_values_exact {ν : Nat → F64} {C : CSrv} {R : Ren} (handles : List Nat) (values : List Val)
    (held : ListR (fun role value => role.Holds ν C R value) (handles.map Value.handle) values) :
    values = handleArrayValues R handles := by
  induction handles generalizing values with
  | nil => cases held; rfl
  | cons handle rest ih =>
    cases held with | cons head tail =>
      cases head
      exact congrArg (Val.big (Int.ofNat (R.handle handle)) :: ·) (ih _ tail)

/-- The original uint64 conversion takes a modulus. Native ownership bounds
are required before the bytes can retain the same owned-handle meaning. -/
theorem toCell_u64_handle (handle : Nat) (bound : handle < 2^64) :
    toCell .u64 (.big (Int.ofNat handle)) = M.pure (some (.big (Int.ofNat handle))) := by
  have remainder : modInt (Int.ofNat handle) (2^64) = handle := by
    rw [modInt,Int.ofNat_eq_natCast,←Int.natCast_emod,Int.toNat_natCast,Nat.mod_eq_of_lt bound]
  simp only [toCell,remainder]
  rfl

theorem cellsOf_u64_handles (R : Ren) (handles : List Nat)
    (bounded : listSupport (fun handle => R.handle handle < 2^64) handles) :
    cellsOf .u64 (handleArrayValues R handles) = M.pure (some (handleArrayCells R handles)) := by
  induction handles with
  | nil => rfl
  | cons handle rest ih =>
    have convert := toCell_u64_handle (R.handle handle) bounded.1
    have suffix := ih bounded.2
    change M.bind (toCell .u64 (.big (Int.ofNat (R.handle handle)))) (fun cell =>
      match cell with
      | some cell => M.bind (cellsOf .u64 (handleArrayValues R rest)) (fun suffix => M.pure (suffix.map (cell::·)))
      | none => M.pure none) = _
    rw [convert]
    change M.bind (cellsOf .u64 (handleArrayValues R rest)) (fun suffix => M.pure (suffix.map ((.big (Int.ofNat (R.handle handle)))::·))) = _
    rw [suffix]
    rfl

theorem handle_array_byte_roles (ν : Nat → F64) (C : CSrv) (R : Ren) (handles : List Nat) :
    ListR (fun role byte => role.Holds ν C R byte) (handleArrayBytes handles)
      (cellBytes .u64 (handleArrayCells R handles)) := by
  induction handles with
  | nil => exact .nil
  | cons handle rest ih =>
    exact (cellPartNotes_holds (Cell.Holds.handle (ν := ν) (C := C) (R := R) handle) .u64 8 0).append ih

theorem handle_array_bytes_paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (handles : List Nat) :
    ListR (Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
      (cellBytes .u64 (handleArrayCells identity handles)) (cellBytes .u64 (handleArrayCells R handles)) := by
  have left := handle_array_byte_roles ν₀ C₀ identity handles
  have right := handle_array_byte_roles ν C R handles
  generalize handleArrayBytes handles = roles at left right
  generalize cellBytes .u64 (handleArrayCells identity handles) = source at left ⊢
  generalize cellBytes .u64 (handleArrayCells R handles) = target at right ⊢
  induction left generalizing target with
  | nil => cases right; exact .nil
  | cons head tail ih =>
    cases right with | cons other rest => exact .cons (Byte.paired head other) (ih _ rest)

end Host.Ts.Owned.Annotated
