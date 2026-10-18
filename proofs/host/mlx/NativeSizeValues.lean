import host.mlx.NativeSizeGeometry
import host.mlx.NativeClosedDimensions
set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def NaturalSizeBounds : List Nat → Prop
  | [] => True
  | n::ns => n < 2^53 ∧ n * ns.foldr (·*·) 1 < 2^53 ∧ NaturalSizeBounds ns

instance naturalSizeBoundsDecidable : (ns : List Nat) → Decidable (NaturalSizeBounds ns)
  | [] => isTrue True.intro
  | n::ns => by
    letI := naturalSizeBoundsDecidable ns
    change Decidable (n < 2^53 ∧ n * ns.foldr (·*·) 1 < 2^53 ∧ NaturalSizeBounds ns)
    infer_instance

theorem NaturalSize.of_values {ν : Nat → F64} {shape : Shape} {ns : List Nat}
    (values : LiteralDimensions ν shape (ns.map Int.ofNat))
    (bounds : NaturalSizeBounds ns) : NaturalSize ν shape ns := by
  induction ns generalizing shape with
  | nil => cases values; exact .nil
  | cons n ns ih =>
    cases values with
    | cons e i meaning exact tail =>
      exact .cons e n meaning
        bounds.1 bounds.2.1 (ih tail bounds.2.2)

theorem NaturalSize.closed_transfer {ν μ : Nat → F64} {shape : Shape} {ns : List Nat}
    (values : NaturalSize ν shape ns) (closed : closedLiteralShape shape = true) :
    NaturalSize μ shape ns := by
  induction values with
  | nil => exact .nil
  | cons e n meaning bound product tail ih =>
    obtain ⟨head,rest⟩ := Bool.and_eq_true_iff.mp closed
    exact .cons e n ((e.eval_closed head μ ν).trans meaning) bound product (ih rest)
end Host.Mlx.Ffi.Annotated
