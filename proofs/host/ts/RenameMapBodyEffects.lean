import host.ts.RenameRouteReadFields
import host.ts.RenameParametricForControl
import host.ts.RenameParametricArrayIndex
import host.ts.RenameParametricArrayMethod
import host.ts.RenameParameterEffects

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

theorem parameterArgument_heap {S : Type} (s : St S) (fn : Func) (name : Name)
    (ps : List Pat) (args : List Val) (env : Env) :
    (parameterArgument s fn name ps args env).heap = s.heap := by
  cases args <;> rfl

theorem step_parameter_id_heap_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (fn : Func) (name : Name) (ps : List Pat) (args₀ : List Val)
    (env : Env) (fs₀ : List Frame) (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .k (.params fn (.id name::ps) args₀ env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨args,hft,_⟩ := hfr.params_view
  rw [hft] at hf
  rw [step_parameter_id_eq F s v fn name ps args (R.env env) fs hc hf] at run
  have he := congrArg St.heap (congrArg Prod.fst (Option.some.inj run))
  rw [parameterArgument_heap] at he
  exact he.symm

theorem enterBlock_heap_empty {S : Type} (s : St S) (ss : List Stmt) (env : Env)
    (empty : blockNames ss = []) (hoist : noInitFunctions ss = true) :
    (enterBlock s ss env).heap = s.heap := by
  change (Host.Ts.hoist s ss env).2.heap = _
  rw [hoist_inert_eq s env ss hoist]
  rw [empty]
  rfl

theorem step_parameter_body_heap_empty_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (name : Option Name) (ps : List Pat) (ss : List Stmt) (args₀ : List Val)
    (env : Env) (fs₀ : List Frame) (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .k (.params (.mk name ps none (.block ss) false false []) [] args₀ env)::fs₀)
    (empty : blockNames ss = []) (hoist : noInitFunctions ss = true)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨args,hft,_⟩ := hfr.params_view
  rw [hft] at hf
  rw [step_parameter_body_eq F s v name ps ss args (R.env env) fs hc hf] at run
  have he := congrArg St.heap (congrArg Prod.fst (Option.some.inj run))
  rw [enterBlock_heap_empty _ ss _ empty hoist] at he
  exact he.symm

end Host.Ts.Owned.Parametric
