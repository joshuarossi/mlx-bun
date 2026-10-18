import host.mlx.NativeFixedSliceGeometry
import host.ts.RenameRetainedClosedComparison

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- Closure is checked on each selected literal occurrence. Symbolic native
dimensions remain a distinct representation and are not normalized here. -/
def closedLiteralShape : Shape → Bool
  | [] => true
  | .literal e::rest => e.closed && closedLiteralShape rest
  | .symbolic _::_ => false

theorem LiteralDimensions.of_holds {ν : Nat → F64} {C : CSrv} {shape : Shape} {ints : List Int}
    (held : Shape.Holds ν C shape (ints.map Dim.lit)) : LiteralDimensions ν shape ints := by
  induction shape generalizing ints with
  | nil => cases ints <;> cases held; exact .nil
  | cons role rest ih =>
    cases ints with
    | nil => cases held
    | cons i ints =>
      cases held with | cons head tail =>
        cases head with
        | literal e i value exact => exact .cons e i (Option.some.inj value).symm exact (ih tail)

theorem LiteralDimensions.exact {ν : Nat → F64} {shape : Shape} {ints : List Int}
    (values : LiteralDimensions ν shape ints) : ExactDimensions ints := by
  induction values with
  | nil => trivial
  | cons e i value hi tail ih => exact ⟨by rw [←value]; exact hi,ih⟩

theorem LiteralDimensions.closed_transfer {ν μ : Nat → F64} {shape : Shape} {ints : List Int}
    (values : LiteralDimensions ν shape ints) (closed : closedLiteralShape shape = true) :
    LiteralDimensions μ shape ints := by
  induction values with
  | nil => exact .nil
  | cons e i value hi tail ih =>
    obtain ⟨head,rest⟩ := Bool.and_eq_true_iff.mp closed
    have same := e.eval_closed head μ ν
    exact .cons e i (same.trans value) (by rw [same]; exact hi) (ih rest)

end Host.Mlx.Ffi.Annotated
