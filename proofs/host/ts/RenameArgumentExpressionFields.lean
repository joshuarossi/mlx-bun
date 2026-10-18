import host.ts.RenameRouteFields
set_option Elab.async false
namespace Host.Ts.Owned.Parametric
/-- Starting the next ordinary argument saves the current returned occurrence
unchanged in its collector frame, even when the next expression makes calls. -/
theorem step_argument_expression_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (kind : Nat) (fn₀ this₀ : Val) (acc₀ : List Val) (e : Expr) (rest : List Elem) (env : Env) (fs₀ : List Frame)
    (v : Val) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .c (.args kind fn₀ this₀ acc₀ (.expr e::rest) env)::fs₀)
    (hk : kind ≤ 1) (run : interpC (step F s).run C = some (result,D)) :
    ∃ fn this acc fs, result.stack = .c (.args kind fn this (v::acc) rest (R.env env))::fs ∧
      result.ctl = .ev e (R.env env) ∧ result.heap = s.heap := by
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨fn,this,acc,hfe,_,_,_⟩ := hfr.args_view
  rw [hfe] at hf
  rw [step_argument_eq F s v kind fn this acc (.expr e::rest) (R.env env) fs hc hf hk] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  exact ⟨fn,this,acc,fs,(congrArg St.stack he).symm,(congrArg St.ctl he).symm,(congrArg St.heap he).symm⟩
end Host.Ts.Owned.Parametric
