import host.mlx.NativeClosedDimensions
import host.mlx.FixedNativeRoles

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Only an existing literal occurrence with a closed expression qualifies.
Numeric references retain their distinct representation. -/
def ClosedLiteralNote : Value → Prop
  | .literal e => e.closed = true
  | _ => False

/-- The current source literal fixes a closed argument's meaning for every
target valuation. No target numeric value is supplied independently. -/
theorem ClosedLiteralNote.exact {role : Value} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {x : F64} {target : Val} (schema : ClosedLiteralNote role)
    (source : role.Holds ν₀ C₀ identity (.num (.lit x))) (held : role.Holds ν C R target) :
    (Value.literal (.lit x)).Holds ν C R target := by
  cases role <;> try exact False.elim schema
  case literal e =>
    cases source with | literal _ _ sourceValue =>
      cases held with | literal _ y targetValue =>
        have sourceEq := Option.some.inj sourceValue
        have targetEq := Option.some.inj targetValue
        have same : y = x := targetEq.trans ((e.eval_closed schema ν ν₀).trans sourceEq.symm)
        exact .literal _ _ (congrArg some same)

theorem closed_literal_allowed (x : F64) : ClosedLiteralNote (.literal (.lit x)) := rfl

theorem general_number_note_rejected (e : SymE) : ¬ ClosedLiteralNote (.num e) := id

theorem open_literal_note_rejected (i : Nat) : ¬ ClosedLiteralNote (.literal (.var i)) := by change ¬ (false = true); decide

end Host.Ts.Owned.Annotated
