import host.ts.RenameParametricParameterStep
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

def expressionBodyState {S : Type} (s : St S) (e : Expr) (env : Env) (fs : List Frame) : St S :=
  ({s with stack := fs}.push (.s .ret)).go (.ev e env)

theorem step_parameter_expression_eq (F : Ffi) (s : St F.S) (v : Val)
    (name : Option Name) (params : List Pat) (e : Expr) (args : List Val) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v)
    (hf : s.stack = .k (.params (.mk name params none (.expr e) false false []) [] args env)::fs) :
    step F s = M.pure (({s with stack := fs}.push (.s .ret)).go (.ev e env)) := by
  simp only [step,hc,stepRet,hf,retStep,retK,paramsNext,fnRest,enterBody,startBody]

/-- Finishing an expression-bodied synchronous closure uses its actual AST
and captured environment. It adds the real return continuation and allocates
no heap object. -/
theorem step_parameter_expression_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (name : Option Name) (params : List Pat) (e : Expr)
    (args₀ : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .k (.params (.mk name params none (.expr e) false false []) [] args₀ env)::fs₀) :
    ∃ result,
      interpC (step F s₀).run C₀ = some (({s₀ with stack := fs₀}.push (.s .ret)).go (.ev e env),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (({s₀ with stack := fs₀}.push (.s .ret)).go (.ev e env)) result ∧ result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  obtain ⟨args,hft,_⟩ := hfr.params_view
  rw [hft] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.1
  have frame : FrameR NR R (.s .ret) (.s .ret) := .node _ (.cons (.node _ .nil) .nil)
  have state : StateR NR FR R live framed before after old old'
      (({s₀ with stack := fs₀}.push (.s .ret)).go (.ev e env))
      (({s with stack := fs}.push (.s .ret)).go (.ev e (R.env env))) :=
    (h.restack (.cons frame htail) ⟨⟨True.intro,True.intro⟩,hl.2⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,hel,True.intro⟩
  refine ⟨({s with stack := fs}.push (.s .ret)).go (.ev e (R.env env)),?_,?_,state,rfl⟩
  · rw [step_parameter_expression_eq F s₀ v₀ name params e args₀ env fs₀ hc₀ hf₀]; rfl
  · rw [step_parameter_expression_eq F s v name params e args (R.env env) fs hc hf]; rfl
end Host.Ts.Owned.Parametric
