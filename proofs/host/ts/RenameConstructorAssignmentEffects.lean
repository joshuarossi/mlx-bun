import host.ts.RenameParametricPrivateAssign
import host.ts.RenameParametricConstructorBody
import host.ts.RenameParameterEffects
import host.ts.RenameParametricStatements
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Preserve the exact first argument occurrence while the actual parameter
scheduler places it into binding control. -/
theorem step_parameter_argument_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (initial : Val) (fn : Func) (name : Name) (params : List Pat) (args₀ : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret initial)
    (hf₀ : s₀.stack = .k (.params fn (.id name::params) args₀ env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) :
    result.ctl = .bind (.id name) (constructorParameterArgument s.stack) (R.env env) .init .let_ ∧
      result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨args,hframe,_⟩ := hfr.params_view
  rw [hframe] at hf
  rw [step_parameter_id_eq F s v fn name params args (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [← he,hf]
  exact ⟨rfl,rfl⟩

/-- Real body hoisting frames every previously allocated cell. -/
theorem step_parameter_body_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (initial : Val) (name : Option Name) (params : List Pat) (body : List Stmt)
    (args₀ : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret initial)
    (hf₀ : s₀.stack = .k (.params (.mk name params none (.block body) false false []) [] args₀ env)::fs₀)
    (inert : noInitFunctions body = true) (a : Nat) (below : a < s.next)
    (bound : s.next+(blockNames body).length ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) : result.heap.get a = s.heap.get a := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨args,hframe,_⟩ := hfr.params_view
  rw [hframe] at hf
  rw [step_parameter_body_eq F s v name params body args (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [← he]
  exact enterBlock_heap_below {s with stack := fs} body (R.env env) a below bound inert

end Host.Ts.Owned.Parametric
