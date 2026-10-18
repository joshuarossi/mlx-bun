import host.ts.RenameParametricArrayBuffer
import host.ts.RenameParametricArguments
namespace Host.Ts.Owned.Parametric

theorem nthD_append_length {α : Type} (d : α) (xs : List α) (v : α) :
    nthD d (xs ++ [v]) xs.length = v := by
  induction xs with
  | nil => rfl
  | cons x xs ih => exact ih

theorem value_roles_length {NR : NumV → NumV → Prop} {R : Ren} {xs ys : List Val}
    (h : ListR (ValueR NR R) xs ys) : xs.length = ys.length := by
  induction h with
  | nil => rfl
  | cons _ _ ih => exact congrArg Nat.succ ih

/-- The value returned for the final ordinary argument occupies the last call
slot. Its exact occurrence meaning follows the executed continuation. -/
theorem step_argument_last (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v fn₀ this₀ : Val) (acc₀ : List Val) (env : Env) (fs₀ : List Frame)
    (_hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .c (.args 0 fn₀ this₀ acc₀ [] env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) :
    callArgument result.ctl acc₀.length = v := by
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨fn,this,acc,hframe,_,_,hacc⟩ := hfr.args_view
  rw [hframe] at hf
  rw [step_argument_eq F s v 0 fn this acc [] (R.env env) fs hc hf (by decide)] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  change argumentState {s with stack := fs} 0 fn this (v::acc) [] (R.env env) = result at he
  rw [← he]
  change nthD .undef (v::acc).reverse acc₀.length = v
  rw [List.reverse_cons,value_roles_length hacc,← List.length_reverse (as := acc)]
  exact nthD_append_length .undef acc.reverse v

end Host.Ts.Owned.Parametric
