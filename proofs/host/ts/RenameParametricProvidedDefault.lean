import host.ts.RenameParametricParameters

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Ts.Owned.Parametric

/-- The current machine code leaves a provided default-pattern argument under
the original `.dflt` binding control for one transition. -/
theorem step_parameter_provided_default_actual_eq (F : Ffi) (s : St F.S) (value : Val)
    (fn : Func) (name : Name) (default : Expr) (params : List Pat)
    (args : List Val) (env : Env) (frames : List Frame)
    (control : s.ctl = .ret value)
    (stack : s.stack = .k (.params fn (.dflt (.id name) default::params) args env)::frames)
    (provided : nthD .undef args 0 ≠ .undef) :
    step F s = M.pure
      (({s with stack := frames}.push (.k (.params fn params args.tail env))).go
        (.bind (.dflt (.id name) default) (nthD .undef args 0) env .init .let_)) := by
  cases args with
  | nil => simp [nthD] at provided
  | cons first rest =>
    cases first <;> simp_all [step,stepRet,retStep,retK,paramsNext]

/-- The unchanged interpreter enters binding control with the original default
pattern when an argument is supplied for a defaulted parameter. -/
def parameterProvidedDefault {S : Type} (s : St S) (fn : Func) (name : Name)
    (default : Expr) (params : List Pat) (args : List Val) (env : Env) : St S :=
  (s.push (.k (.params fn params args.tail env))).go
    (.bind (.dflt (.id name) default) (nthD .undef args 0) env .init .let_)

/-- A provided argument advances the original parameter dispatcher by one
step. The source argument role determines the target's non-undefined branch. -/
theorem step_parameter_provided_default_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v : Val) (fn : Func) (name : Name) (default : Expr) (params : List Pat)
    (args₀ args : List Val) (env : Env) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .k (.params fn (.dflt (.id name) default::params) args₀ env)::fs₀)
    (hf : s.stack = .k (.params fn (.dflt (.id name) default::params) args (R.env env))::fs)
    (provided : nthD .undef args₀ 0 ≠ .undef) :
    interpC (step F s₀).run C₀ =
      some (parameterProvidedDefault {s₀ with stack := fs₀} fn name default params args₀ env,C₀) ∧
    interpC (step F s).run C =
      some (parameterProvidedDefault {s with stack := fs} fn name default params args (R.env env),C) ∧
    nthD .undef args 0 ≠ .undef ∧
    StateR NR FR R live framed before after old old'
      (parameterProvidedDefault {s₀ with stack := fs₀} fn name default params args₀ env)
      (parameterProvidedDefault {s with stack := fs} fn name default params args (R.env env)) := by
  have hfs := h.stack
  rw [hf₀,hf] at hfs
  have hfl := h.stackLive
  rw [hf₀] at hfl
  cases hfs with
  | cons hhead htail =>
    have hargs : ListR (ValueR NR R) args₀ args := by
      cases hhead with | node tag hs =>
        cases hs with | cons hframe hs =>
          cases hframe with | node tag hs =>
            cases hs with | cons hfn hs =>
              cases hs with | cons hparams hs =>
                cases hs with | cons hargs hs => exact vals_roles_of hargs
    have hargl : listSupport (valueSupport live) args₀ :=
      vals_support_of _ hfl.1.1.2.2.1
    have hfirst := parameter_args_roles hargs
    have hfirstl := parameter_args_live args₀ hargl
    have targetProvided : nthD .undef args 0 ≠ .undef := by
      intro missing
      exact provided ((hfirst.1.undef_iff).mpr missing)
    have hel : treeSupport live (Encode.env env) := hfl.1.1.2.2.2.1
    have hparam : FrameR NR R (.k (.params fn params args₀.tail env))
        (.k (.params fn params args.tail (R.env env))) :=
      .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _)
        (.cons (vals_roles hfirst.2) (.cons (env_roles NR R _) .nil))))) .nil)
    have hparaml : treeSupport live (Encode.frame (.k (.params fn params args₀.tail env))) :=
      ⟨⟨True.intro,True.intro,vals_support _ hfirstl.2,hel,True.intro⟩,True.intro⟩
    have hh := h.restack (.cons hparam htail) ⟨hparaml,hfl.2⟩
    have hcontrol : ControlR NR R
        (.bind (.dflt (.id name) default) (nthD .undef args₀ 0) env .init .let_)
        (.bind (.dflt (.id name) default) (nthD .undef args 0) (R.env env) .init .let_) :=
      .node _ (.cons (.atom _ _) (.cons (.value hfirst.1)
        (.cons (env_roles NR R env) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))))
    have hcontrolLive : treeSupport live
        (Encode.ctl (.bind (.dflt (.id name) default) (nthD .undef args₀ 0) env .init .let_)) :=
      ⟨True.intro,hfirstl.1,hel,True.intro,True.intro,True.intro⟩
    refine ⟨?_,?_,targetProvided,hh.go hcontrol hcontrolLive⟩
    · rw [step_parameter_provided_default_actual_eq F s₀ v₀ fn name default params args₀ env fs₀
        hc₀ hf₀ provided]
      rfl
    · rw [step_parameter_provided_default_actual_eq F s v fn name default params args (R.env env) fs
        hc hf targetProvided]
      rfl

/-- For a non-undefined argument, that actual transition has a different
control from the ordinary identifier `parameterArgument` endpoint. -/
theorem step_parameter_provided_default_not_parameterArgument (F : Ffi) (s : St F.S)
    (value : Val) (fn : Func) (name : Name) (default : Expr) (params : List Pat)
    (args : List Val) (env : Env) (frames : List Frame) (server : CSrv)
    (control : s.ctl = .ret value)
    (stack : s.stack = .k (.params fn (.dflt (.id name) default::params) args env)::frames)
    (provided : nthD .undef args 0 ≠ .undef) :
    interpC (step F s).run server ≠ some
      (parameterArgument {s with stack := frames} fn name params args env,server) := by
  let actual :=
    ({s with stack := frames}.push (.k (.params fn params args.tail env))).go
      (.bind (.dflt (.id name) default) (nthD .undef args 0) env .init .let_)
  have actualRun : interpC (step F s).run server = some (actual,server) := by
    rw [step_parameter_provided_default_actual_eq F s value fn name default params args env frames
      control stack provided]
    rfl
  have controlsDiffer : actual ≠ parameterArgument {s with stack := frames} fn name params args env := by
    intro same
    have controlEq := congrArg St.ctl same
    simp [actual,parameterArgument,St.push,St.go] at controlEq
  intro claimed
  have statesEqual := congrArg Prod.fst (Option.some.inj (actualRun.symm.trans claimed))
  exact controlsDiffer statesEqual

end Host.Ts.Owned.Parametric
