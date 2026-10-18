import host.ts.RenameParametricArrayBuffer

import host.ts.RenameIdentifierArguments
import host.ts.RenameRouteFields
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- The last continuation of a one-argument call retains that exact value in
argument slot zero; no new numeric or ownership meaning is selected. -/
theorem step_single_argument_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (fn₀ this₀ v : Val) (env : Env) (fs₀ : List Frame)
    (hf₀ : s₀.stack = .c (.args 0 fn₀ this₀ [] [] env)::fs₀) (hc : s.ctl = .ret v)
    (run : interpC (step F s).run C = some (result,D)) : callArgument result.ctl 0 = v := by
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨fn,this,acc,hframe,_,_,hacc⟩ := hfr.args_view
  cases hacc
  rw [hframe] at hf
  rw [step_argument_eq F s v 0 fn this [] [] (R.env env) fs hc hf (by decide)] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [← he]
  rfl
end Host.Ts.Owned.Parametric
