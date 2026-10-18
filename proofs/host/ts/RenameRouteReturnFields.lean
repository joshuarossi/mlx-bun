import host.ts.RenameParametricReturnStep
import host.ts.RenameParametricDeclarations
namespace Host.Ts.Owned.Parametric

theorem step_return_exit_control (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v : Val) (exit : ReturnExit) (env : Env) (fs₀ : List Frame)
    (hf₀ : s₀.stack = exit.frame env::fs₀) (hc : s.ctl = .ret v)
    (run : interpC (step F s).run C = some (result,D)) : result.ctl = exit.control v := by
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.returnExit_view] at hf
  rw [step_return_exit_eq F s v (R.env env) exit fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.ctl he).symm

theorem step_return_unwind_control (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v : Val) (unwind : ReturnUnwind) (env : Env) (fs₀ : List Frame)
    (hf₀ : s₀.stack = unwind.frame env::fs₀) (hc : s.ctl = .abr (.ret v))
    (run : interpC (step F s).run C = some (result,D)) : result.ctl = unwind.control v := by
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.returnUnwind_view] at hf
  rw [step_return_unwind_eq F s v (R.env env) unwind fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.ctl he).symm

theorem step_declaration_control (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v : Val) (kind : DeclKind) (p : Pat) (rest : List (Pat × Option Expr)) (env : Env) (fs₀ : List Frame)
    (hf₀ : s₀.stack = .s (.decl kind p rest env)::fs₀) (hc : s.ctl = .ret v)
    (hk : isUsing kind = false) (run : interpC (step F s).run C = some (result,D)) :
    result.ctl = .bind p v (R.env env) .init kind := by
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.decl_view] at hf
  rw [step_declaration_value_eq F s v kind p rest (R.env env) fs hc hf hk] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.ctl he).symm
end Host.Ts.Owned.Parametric
