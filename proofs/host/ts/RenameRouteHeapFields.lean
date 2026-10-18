import host.ts.RenameRouteReturnFields
import host.ts.RenameRouteFields
import host.ts.RenameParametricMapControl
namespace Host.Ts.Owned.Parametric

theorem step_statement_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : StatementAction) (env : Env) (hc₀ : s₀.ctl = .ex a.statement env)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  have hc := (h.control_view hc₀).ex_view
  rw [step_statement_eq F s a (R.env env) hc] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.heap he).symm

theorem step_declaration_next_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (kind : DeclKind) (rest : List (Pat × Option Expr)) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.declNext kind rest env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.declNext_view] at hf
  rw [step_declaration_next_eq F s v kind rest (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.heap he).symm

theorem step_block_next_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (st : Stmt) (rest : List Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.block (st::rest) env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.block_view] at hf
  rw [step_block_next_eq F s v st rest (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.heap he).symm

theorem step_if_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (b : Bool) (yes : Stmt) (no : Option Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.bool b)) (hf₀ : s₀.stack = .s (.if_ yes no env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.if_view] at hf
  rw [step_if_bool_eq F s b yes no (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact (congrArg St.heap he).symm
end Host.Ts.Owned.Parametric
