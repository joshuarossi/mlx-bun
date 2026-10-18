import host.ts.RenameRouteReadFields
import host.ts.RenameParametricForControl
import host.ts.RenameParametricArrayIndex
import host.ts.RenameParametricArrayMethod

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem forBodyState_heap {S : Type} (s : St S) (b : Bool) (test update : Option Expr)
    (body : Stmt) (env : Env) (names labels : List Name) :
    (forBodyState s b test update body env names labels).heap = s.heap := by
  cases b <;> rfl

theorem step_for_body_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (b : Bool) (test update : Option Expr) (body : Stmt) (env : Env)
    (names labels : List Name) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.bool b))
    (hf₀ : s₀.stack = .lp (.forBody test update body env names labels)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.forBody_view] at hf
  rw [step_for_body_eq F s b test update body (R.env env) names labels fs hc hf] at run
  have he := congrArg St.heap (congrArg Prod.fst (Option.some.inj run))
  rw [forBodyState_heap] at he
  exact he.symm

theorem step_index_left_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (receiver₀ : Val) (key : Expr) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret receiver₀)
    (hf₀ : s₀.stack = .e (.indexL key env false)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨receiver,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.indexLeft_view] at hf
  rw [step_index_left_eq F s receiver key (R.env env) fs hc hf] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm

end Host.Ts.Owned.Parametric
