import host.ts.RenameRouteReadFields
import host.ts.RenameParametricDescent
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem readProp_stack (F : Ffi) (s : St F.S) (v : Val) (p : Option PropV) :
    (Host.Ts.readProp F s v p).stack = s.stack := by
  cases p with
  | none => rfl
  | some p => cases p with
    | data v w e => rfl
    | acc getter setter e => cases getter <;> rfl

theorem step_member_lookup_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (name : Name) (p₀ : Option PropV) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .e (.member (.str name) false)::fs₀)
    (path : OrdinaryLookup s₀ name 16 a p₀)
    (run : interpC (step F s).run C = some (result,D)) :
    result.stack = s.stack.tail := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.member_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨p,_,hr,_,_⟩ := step_member_lookup_roles F NR FR R C₀ C live framed before after old old'
    s₀ s h a name p₀ fs₀ fs hc₀ hc hf₀ hf ha path
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  have hs := congrArg St.stack he
  rw [readProp_stack] at hs
  rw [hf]
  exact hs

theorem step_descent_stack (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (d : Descent) (env : Env) (hc₀ : s₀.ctl = .ev d.whole env)
    (run : interpC (step F s).run C = some (result,D)) :
    result.stack = d.frame (R.env env)::s.stack := by
  rw [step_descent_eq F s d (R.env env) (h.control_view hc₀).ev_view] at run
  exact (congrArg St.stack (congrArg Prod.fst (Option.some.inj run))).symm
end Host.Ts.Owned.Parametric
