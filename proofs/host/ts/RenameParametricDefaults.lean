import host.ts.RenameParametricParameters

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

def parameterDefault {S : Type} (s : St S) (f : Func) (p : Pat) (d : Expr) (ps : List Pat)
    (args : List Val) (env : Env) : St S :=
  (s.push (.k (.paramDflt f p ps args.tail env))).go (.ev d env)

theorem step_parameter_default_eq (F : Ffi) (s : St F.S) (v : Val) (f : Func) (p : Pat) (d : Expr)
    (ps : List Pat) (args : List Val) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .k (.params f (.dflt p d::ps) args env)::fs)
    (hv : nthD .undef args 0 = .undef) :
    step F s = M.pure (parameterDefault {s with stack := fs} f p d ps args env) := by
  simp only [step,hc,stepRet,hf,retStep,retK,paramsNext,hv,parameterDefault]

theorem step_parameter_default_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v : Val) (f : Func) (p : Pat) (d : Expr) (ps : List Pat) (args₀ args : List Val) (env : Env) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .k (.params f (.dflt p d::ps) args₀ env)::fs₀)
    (hf : s.stack = .k (.params f (.dflt p d::ps) args (R.env env))::fs)
    (hv₀ : nthD .undef args₀ 0 = .undef) :
    interpC (step F s₀).run C₀ = some (parameterDefault {s₀ with stack := fs₀} f p d ps args₀ env,C₀) ∧
    interpC (step F s).run C = some (parameterDefault {s with stack := fs} f p d ps args (R.env env),C) ∧
    StateR NR FR R live framed before after old old'
      (parameterDefault {s₀ with stack := fs₀} f p d ps args₀ env)
      (parameterDefault {s with stack := fs} f p d ps args (R.env env)) := by
  have hfs := h.stack
  rw [hf₀,hf] at hfs
  have hfl := h.stackLive
  rw [hf₀] at hfl
  cases hfs with | cons hhead htail =>
    have hargs : ListR (ValueR NR R) args₀ args := by
      cases hhead with | node tag hs =>
        cases hs with | cons hp hs =>
          cases hp with | node tag hs =>
            cases hs with | cons hf hs =>
              cases hs with | cons hps hs =>
                cases hs with | cons ha hs => exact vals_roles_of ha
    have hv := (parameter_args_roles hargs).1.undef_iff.mp hv₀
    have hel : treeSupport live (Encode.env env) := hfl.1.1.2.2.2.1
    have hparam : FrameR NR R (.k (.paramDflt f p ps args₀.tail env)) (.k (.paramDflt f p ps args.tail (R.env env))) :=
      .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _) (.cons (.atom _ _)
        (.cons (vals_roles (parameter_args_roles hargs).2) (.cons (env_roles NR R _) .nil)))))) .nil)
    have hparaml : treeSupport live (Encode.frame (.k (.paramDflt f p ps args₀.tail env))) :=
      ⟨⟨True.intro,True.intro,True.intro,vals_support _
        (parameter_args_live args₀ (vals_support_of _ hfl.1.1.2.2.1)).2,hel,True.intro⟩,True.intro⟩
    have hh := h.restack (.cons hparam htail) ⟨hparaml,hfl.2⟩
    refine ⟨?_,?_,hh.go (.node _ (.cons (.atom _ _) (.cons (env_roles NR R _) .nil)))
      ⟨True.intro,hel,True.intro⟩⟩
    · rw [step_parameter_default_eq F s₀ v₀ f p d ps args₀ env fs₀ hc₀ hf₀ hv₀]; rfl
    · rw [step_parameter_default_eq F s v f p d ps args (R.env env) fs hc hf hv]; rfl

def parameterDefaultReturn {S : Type} (s : St S) (f : Func) (p : Pat) (ps : List Pat)
    (args : List Val) (env : Env) (v : Val) : St S :=
  (s.push (.k (.params f ps args env))).go (.bind p v env .init .let_)

theorem step_parameter_default_return_eq (F : Ffi) (s : St F.S) (v : Val) (f : Func) (p : Pat)
    (ps : List Pat) (args : List Val) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .k (.paramDflt f p ps args env)::fs) :
    step F s = M.pure (parameterDefaultReturn {s with stack := fs} f p ps args env v) := by
  simp only [step,hc,stepRet,hf,retStep,retK,parameterDefaultReturn]

theorem step_parameter_default_return_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v : Val) (f : Func) (p : Pat) (ps : List Pat) (args₀ args : List Val) (env : Env) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .k (.paramDflt f p ps args₀ env)::fs₀)
    (hf : s.stack = .k (.paramDflt f p ps args (R.env env))::fs) :
    interpC (step F s₀).run C₀ = some (parameterDefaultReturn {s₀ with stack := fs₀} f p ps args₀ env v₀,C₀) ∧
    interpC (step F s).run C = some (parameterDefaultReturn {s with stack := fs} f p ps args (R.env env) v,C) ∧
    StateR NR FR R live framed before after old old'
      (parameterDefaultReturn {s₀ with stack := fs₀} f p ps args₀ env v₀)
      (parameterDefaultReturn {s with stack := fs} f p ps args (R.env env) v) := by
  have hfs := h.stack
  rw [hf₀,hf] at hfs
  have hfl := h.stackLive
  rw [hf₀] at hfl
  have hv : ValueR NR R v₀ v := by
    have hh := h.control
    rw [hc₀,hc] at hh
    cases hh with | node tag hs =>
      cases hs with | cons hv hs =>
        cases hv with | value hv => exact hv
  have hvl : valueSupport live v₀ := by
    have hh := h.controlLive; rw [hc₀] at hh; exact hh.1
  cases hfs with | cons hhead htail =>
    have hargs : ListR (ValueR NR R) args₀ args := by
      cases hhead with | node tag hs =>
        cases hs with | cons hp hs =>
          cases hp with | node tag hs =>
            cases hs with | cons hf hs =>
              cases hs with | cons hp hs =>
                cases hs with | cons hps hs =>
                  cases hs with | cons ha hs => exact vals_roles_of ha
    have hel : treeSupport live (Encode.env env) := hfl.1.1.2.2.2.2.1
    have hparam : FrameR NR R (.k (.params f ps args₀ env)) (.k (.params f ps args (R.env env))) :=
      .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _)
        (.cons (vals_roles hargs) (.cons (env_roles NR R _) .nil))))) .nil)
    have hparaml : treeSupport live (Encode.frame (.k (.params f ps args₀ env))) :=
      ⟨⟨True.intro,True.intro,hfl.1.1.2.2.2.1,hel,True.intro⟩,True.intro⟩
    have hh := h.restack (.cons hparam htail) ⟨hparaml,hfl.2⟩
    refine ⟨?_,?_,hh.go (.node _ (.cons (.atom _ _) (.cons (.value hv)
      (.cons (env_roles NR R _) (.cons (.atom _ _) (.cons (.atom _ _) .nil))))))
      ⟨True.intro,hvl,hel,True.intro,True.intro,True.intro⟩⟩
    · rw [step_parameter_default_return_eq F s₀ v₀ f p ps args₀ env fs₀ hc₀ hf₀]; rfl
    · rw [step_parameter_default_return_eq F s v f p ps args (R.env env) fs hc hf]; rfl

theorem step_parameter_body_eq (F : Ffi) (s : St F.S) (v : Val)
    (name : Option Name) (params : List Pat) (ss : List Stmt) (args : List Val) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v)
    (hf : s.stack = .k (.params (.mk name params none (.block ss) false false []) [] args env)::fs) :
    step F s = M.pure (enterBlock {s with stack := fs} ss env) := by
  simp only [step,hc,stepRet,hf,retStep,retK,paramsNext,fnRest,enterBody,startBody]

/-- Finishing the actual parameter list enters the synchronous function body,
including its lexical hoisting, under the checked source-AST guard. -/
theorem step_parameter_body_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v : Val) (name : Option Name) (params : List Pat) (ss : List Stmt)
    (args₀ args : List Val) (env : Env) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .k (.params (.mk name params none (.block ss) false false []) [] args₀ env)::fs₀)
    (hf : s.stack = .k (.params (.mk name params none (.block ss) false false []) [] args (R.env env))::fs)
    (hi : noInitFunctions ss = true)
    (hs : s₀.next + (blockNames ss).length ≤ 2^64) (ht : s.next + (blockNames ss).length ≤ 2^64) :
    interpC (step F s₀).run C₀ = some (enterBlock {s₀ with stack := fs₀} ss env,C₀) ∧
    interpC (step F s).run C = some (enterBlock {s with stack := fs} ss (R.env env),C) ∧
    StateR NR FR R (CellsLive live s₀.next (blockNames ss)) framed before after old old'
      (enterBlock {s₀ with stack := fs₀} ss env)
      (enterBlock {s with stack := fs} ss (R.env env)) := by
  have hfs := h.stack
  rw [hf₀,hf] at hfs
  have hfl := h.stackLive
  rw [hf₀] at hfl
  cases hfs with | cons _ htail =>
    have hel : treeSupport live (Encode.env env) := hfl.1.1.2.2.2.1
    refine ⟨?_,?_,enterBlock_roles (h.restack htail hfl.2) ss env hi hel hs ht⟩
    · rw [step_parameter_body_eq F s₀ v₀ name params ss args₀ env fs₀ hc₀ hf₀]; rfl
    · rw [step_parameter_body_eq F s v name params ss args (R.env env) fs hc hf]; rfl

end Host.Ts.Owned.Parametric
