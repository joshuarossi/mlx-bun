import host.mlx.NativeReshapeRoles
import host.mlx.NativeFixedSliceGeometry

set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated
theorem reshape_nonnegative_of_all (xs : List Int)
    (nonnegative : xs.all (fun i => decide (0 ≤ i)) = true) :
    Host.Ts.Owned.listSupport (fun i => 0 ≤ i) xs := by
  induction xs with
  | nil => trivial
  | cons i rest ih =>
    obtain ⟨head,tail⟩ := Bool.and_eq_true_iff.mp nonnegative
    exact ⟨of_decide_eq_true head,ih tail⟩

theorem ReshapeGeometry.constants (ν : Nat → Host.Ts.F64) (old new : List Int)
    (oldExact : ExactDimensions old) (newExact : ExactDimensions new)
    (nonnegative : Host.Ts.Owned.listSupport (fun i => 0 ≤ i) new)
    (products : old.foldr (· * ·) 1 = new.foldr (· * ·) 1) :
    ReshapeGeometry ν (constantShape old) (constantShape new) :=
  ⟨old,new,(LiteralDimensions.constants ν old oldExact).literalValues,
    (LiteralDimensions.constants ν new newExact).literalValues,nonnegative,products⟩
end Host.Mlx.Ffi.Annotated
