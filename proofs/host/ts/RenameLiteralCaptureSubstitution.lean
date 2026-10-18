import host.ts.RenameLiteralCaptureSeed
import host.ts.RenameCaptureRebase

set_option Elab.async false
namespace Host.Ts.Owned.Annotated

theorem literalCaptureRole_subst (θ : Nat → SymE) (value : Val) :
    (literalCaptureRole value).map (Value.subst θ) = literalCaptureRole value := by
  cases value <;> try rfl
  case num number => cases number <;> rfl

/-- Substituting oracle variables preserves the initialized builtin's literal
numeric captures, including typed-constructor code and prototype notes. -/
theorem literalNativeNote_subst (θ : Nat → SymE) (code : Native) (data : List Val) :
    (literalNativeNote code data).mapRoles (Value.subst θ) = literalNativeNote code data := by
  have roles : (fun i => (literalCaptureRole (Host.Ts.arg data i)).map (Value.subst θ)) =
      (fun i => literalCaptureRole (Host.Ts.arg data i)) :=
    funext (fun i => literalCaptureRole_subst θ (Host.Ts.arg data i))
  exact congrArg (NativeCaptureNote.mk code) roles

end Host.Ts.Owned.Annotated
