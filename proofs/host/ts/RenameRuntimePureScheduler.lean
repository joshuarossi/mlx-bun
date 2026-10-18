import host.ts.RenameRuntimePureCases
import host.ts.RenameParametricExpressionEntry
import host.ts.RenameParametricParameterStep
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

section
variable {F : Ffi} {NR : NumV → NumV → Prop} {FR : Ren → F.S → F.S → Prop} {R : Ren}
  {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}

theorem PureRuntimeCase.privateDescent (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (obj : Expr) (name : Name) (optional : Bool) (env : Env) (brand : Nat)
    (control : s₀.ctl = .ev (.priv obj name optional) env)
    (lookup : lookupEnv (privName name) env = some brand) : PureRuntimeCase F s₀ s := by
  have targetLookup : lookupEnv (privName name) (R.env env) = some (R.a brand) := by rw [lookupEnv_map,lookup]; rfl
  exact ⟨.of_pure F s₀ _ (step_private_descent_eq F s₀ obj name optional env brand control lookup) ⟨rfl,rfl,rfl⟩,
    .of_pure F s _ (step_private_descent_eq F s obj name optional (R.env env) (R.a brand)
      (h.control_view control).ev_view targetLookup) ⟨rfl,rfl,rfl⟩⟩

theorem PureRuntimeCase.identifierCall (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (args : List Elem) (optional : Bool) (env : Env)
    (control : s₀.ctl = .ev (.call (.id name) args optional) env) : PureRuntimeCase F s₀ s :=
  ⟨.of_pure F s₀ _ (step_identifier_call_descent_eq F s₀ name args optional env control) ⟨rfl,rfl,rfl⟩,
    .of_pure F s _ (step_identifier_call_descent_eq F s name args optional (R.env env)
      (h.control_view control).ev_view) ⟨rfl,rfl,rfl⟩⟩

theorem PureRuntimeCase.parameterId (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (fn : Func) (name : Name) (params : List Pat) (args : List Val) (env : Env) (frames : List Frame)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .k (.params fn (.id name::params) args env)::frames) :
    PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetArgs,frameEq,_⟩ := frameRelation.params_view
  rw [frameEq] at targetStack
  exact ⟨.of_pure F s₀ _ (step_parameter_id_eq F s₀ value fn name params args env frames control stack) ⟨rfl,rfl,rfl⟩,
    .of_pure F s _ (step_parameter_id_eq F s targetValue fn name params targetArgs (R.env env) targetFrames
      targetControl targetStack) ⟨rfl,rfl,rfl⟩⟩

theorem PureRuntimeCase.parameterDefault (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (fn : Func) (pattern : Pat) (fallback : Expr) (params : List Pat) (args : List Val)
    (env : Env) (frames : List Frame) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .k (.params fn (.dflt pattern fallback::params) args env)::frames)
    (missing : nthD .undef args 0 = .undef) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetArgs,frameEq,argumentRoles⟩ := frameRelation.params_view
  rw [frameEq] at targetStack
  have targetMissing := (parameter_args_roles argumentRoles).1.undef_iff.mp missing
  exact ⟨.of_pure F s₀ _ (step_parameter_default_eq F s₀ value fn pattern fallback params args env frames control stack missing) ⟨rfl,rfl,rfl⟩,
    .of_pure F s _ (step_parameter_default_eq F s targetValue fn pattern fallback params targetArgs (R.env env) targetFrames
      targetControl targetStack targetMissing) ⟨rfl,rfl,rfl⟩⟩

theorem PureRuntimeCase.parameterDefaultReturn (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (fn : Func) (pattern : Pat) (params : List Pat) (args : List Val) (env : Env) (frames : List Frame)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .k (.paramDflt fn pattern params args env)::frames) :
    PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetArgs,frameEq,_⟩ := frameRelation.paramDefault_view
  rw [frameEq] at targetStack
  exact ⟨.of_pure F s₀ _ (step_parameter_default_return_eq F s₀ value fn pattern params args env frames control stack) ⟨rfl,rfl,rfl⟩,
    .of_pure F s _ (step_parameter_default_return_eq F s targetValue fn pattern params targetArgs (R.env env) targetFrames
      targetControl targetStack) ⟨rfl,rfl,rfl⟩⟩
end
end Host.Ts.Owned.Annotated
