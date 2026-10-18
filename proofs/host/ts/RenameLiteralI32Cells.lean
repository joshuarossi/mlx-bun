import host.mlx.NativeShapeBufferInventory
import host.ts.RenameParametricTypedArray

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Extract only meanings already attached to strict numeric literals. -/
def literalArrayExpressions (roles : List Value) : List SymE :=
  roles.filterMap fun role => match role with | .literal e => some e | _ => none

def literalArrayValues (ν : Nat → F64) (expressions : List SymE) : List Val :=
  expressions.map fun e => .num (.lit (e.eval ν))

def literalI32Cells (ν : Nat → F64) (expressions : List SymE) : List Host.Ts.Cell :=
  expressions.map fun e => .num (.lit (F64.un .int32 (e.eval ν)))

def literalI32Bytes (expressions : List SymE) : List Byte :=
  literalShapeByteNotes (expressions.map (SymE.un .int32))

theorem literal_array_values_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (expressions : List SymE) (values : List Val)
    (held : ListR (fun role value => role.Holds ν C R value) (expressions.map Value.literal) values) :
    values = literalArrayValues ν expressions := by
  induction expressions generalizing values with
  | nil => cases held; rfl
  | cons e expressions ih =>
    cases held with | cons head tail =>
      cases head with | literal _ x denote =>
        have equal : x = e.eval ν := Option.some.inj denote
        subst x
        exact congrArg (Val.num (.lit (e.eval ν)) :: ·) (ih _ tail)

theorem cellsOf_i32_literals (ν : Nat → F64) (expressions : List SymE) :
    cellsOf .i32 (literalArrayValues ν expressions) = M.pure (some (literalI32Cells ν expressions)) := by
  induction expressions with
  | nil => rfl
  | cons e expressions ih =>
    change M.bind (toCell .i32 (.num (.lit (e.eval ν)))) (fun cell =>
      match cell with
      | some cell => M.bind (cellsOf .i32 (literalArrayValues ν expressions)) (fun suffix => M.pure (suffix.map (cell::·)))
      | none => M.pure none) = _
    have cast : toCell .i32 (.num (.lit (e.eval ν))) =
        M.pure (some (.num (.lit (F64.un .int32 (e.eval ν))))) := rfl
    rw [cast]
    change M.bind (cellsOf .i32 (literalArrayValues ν expressions))
      (fun suffix => M.pure (suffix.map ((.num (.lit (F64.un .int32 (e.eval ν))))::·))) = _
    rw [ih]
    rfl

theorem literal_i32_byte_roles (ν : Nat → F64) (C : CSrv) (R : Ren) (expressions : List SymE) :
    ListR (fun role byte => role.Holds ν C R byte) (literalI32Bytes expressions)
      (cellBytes .i32 (literalI32Cells ν expressions)) := by
  induction expressions with
  | nil => exact .nil
  | cons e expressions ih =>
    have meaning : NumDenote ν C (.un .int32 e) (.lit (F64.un .int32 (e.eval ν))) := rfl
    exact (cellPartNotes_holds (Cell.Holds.literal _ _ meaning) .i32 4 0).append ih

theorem literal_i32_bytes_paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (expressions : List SymE) :
    ListR (Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
      (cellBytes .i32 (literalI32Cells ν₀ expressions)) (cellBytes .i32 (literalI32Cells ν expressions)) := by
  have left := literal_i32_byte_roles ν₀ C₀ identity expressions
  have right := literal_i32_byte_roles ν C R expressions
  generalize literalI32Bytes expressions = roles at left right
  generalize cellBytes .i32 (literalI32Cells ν₀ expressions) = source at left ⊢
  generalize cellBytes .i32 (literalI32Cells ν expressions) = target at right ⊢
  induction left generalizing target with
  | nil => cases right; exact .nil
  | cons head tail ih =>
    cases right with | cons other rest => exact .cons (Byte.paired head other) (ih _ rest)

end Host.Ts.Owned.Annotated
