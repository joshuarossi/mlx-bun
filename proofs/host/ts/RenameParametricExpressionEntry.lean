import host.ts.RenameParametricCallback
import host.ts.RenameParametricParameters
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Private-name lookup selects the runtime brand from the captured source
lexical environment. The target lookup is obtained by mapping that environment. -/
theorem step_private_descent_eq (F : Ffi) (s : St F.S) (obj : Expr) (name : Name)
    (opt : Bool) (env : Env) (brand : Nat)
    (hc : s.ctl = .ev (.priv obj name opt) env)
    (hb : lookupEnv (privName name) env = some brand) :
    step F s = M.pure ((s.push (.e (.priv brand name opt))).go (.ev obj env)) := by
  simp only [step,hc,evStep,hb]

theorem step_private_descent_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (obj : Expr) (name : Name) (opt : Bool) (env : Env) (brand : Nat)
    (hc₀ : s₀.ctl = .ev (.priv obj name opt) env)
    (hb₀ : lookupEnv (privName name) env = some brand) :
    interpC (step F s₀).run C₀ = some ((s₀.push (.e (.priv brand name opt))).go (.ev obj env),C₀) ∧
      interpC (step F s).run C = some ((s.push (.e (.priv (R.a brand) name opt))).go (.ev obj (R.env env)),C) ∧
      StateR NR FR R live framed before after old old'
        ((s₀.push (.e (.priv brand name opt))).go (.ev obj env))
        ((s.push (.e (.priv (R.a brand) name opt))).go (.ev obj (R.env env))) := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have he := hl.2.1
  have hb := env_lookup_live (privName name) env brand he hb₀
  have hlookup : lookupEnv (privName name) (R.env env) = some (R.a brand) := by
    rw [lookupEnv_map,hb₀]; rfl
  have hf : FrameR NR R (.e (.priv brand name opt)) (.e (.priv (R.a brand) name opt)) := by
    repeat constructor
  have hfl : treeSupport live (Encode.frame (.e (.priv brand name opt))) := by
    exact ⟨⟨hb,True.intro,True.intro,True.intro⟩,True.intro⟩
  refine ⟨?_,?_,(h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩⟩
  · rw [step_private_descent_eq F s₀ obj name opt env brand hc₀ hb₀]; rfl
  · rw [step_private_descent_eq F s obj name opt (R.env env) (R.a brand) hc hlookup]; rfl

/-- Bare identifier calls retain their ordinary callee continuation. Member,
index and private calls have distinct receiver semantics in evCall. -/
theorem step_identifier_call_descent_eq (F : Ffi) (s : St F.S) (name : Name)
    (args : List Elem) (opt : Bool) (env : Env)
    (hc : s.ctl = .ev (.call (.id name) args opt) env) :
    step F s = M.pure ((s.push (.c (.callee args env opt))).go (.ev (.id name) env)) := by
  simp only [step,hc,evStep,evCall]

theorem step_identifier_call_descent_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (args : List Elem) (opt : Bool) (env : Env)
    (hc₀ : s₀.ctl = .ev (.call (.id name) args opt) env) :
    interpC (step F s₀).run C₀ = some ((s₀.push (.c (.callee args env opt))).go (.ev (.id name) env),C₀) ∧
      interpC (step F s).run C = some ((s.push (.c (.callee args (R.env env) opt))).go (.ev (.id name) (R.env env)),C) ∧
      StateR NR FR R live framed before after old old'
        ((s₀.push (.c (.callee args env opt))).go (.ev (.id name) env))
        ((s.push (.c (.callee args (R.env env) opt))).go (.ev (.id name) (R.env env))) := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have he := hl.2.1
  have hf : FrameR NR R (.c (.callee args env opt)) (.c (.callee args (R.env env) opt)) := by
    repeat first | exact env_roles NR R env | constructor
  have hfl : treeSupport live (Encode.frame (.c (.callee args env opt))) := by
    exact ⟨⟨True.intro,he,True.intro,True.intro⟩,True.intro⟩
  refine ⟨?_,?_,(h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩⟩
  · rw [step_identifier_call_descent_eq F s₀ name args opt env hc₀]; rfl
  · rw [step_identifier_call_descent_eq F s name args opt (R.env env) hc]; rfl
theorem step_array_spread_entry_eq (F : Ffi) (s : St F.S) (e : Expr)
    (rest : List Elem) (env : Env) (hc : s.ctl = .ev (.array (.spread e::rest)) env) :
    step F s = M.pure ((s.push (.l (.spread [] rest env))).go (.ev e env)) := by
  simp only [step,hc,evStep,arrayNext]

theorem step_array_spread_entry_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (e : Expr) (rest : List Elem) (env : Env)
    (hc₀ : s₀.ctl = .ev (.array (.spread e::rest)) env) :
    interpC (step F s₀).run C₀ = some ((s₀.push (.l (.spread [] rest env))).go (.ev e env),C₀) ∧
      interpC (step F s).run C = some ((s.push (.l (.spread [] rest (R.env env)))).go (.ev e (R.env env)),C) ∧
      StateR NR FR R live framed before after old old'
        ((s₀.push (.l (.spread [] rest env))).go (.ev e env))
        ((s.push (.l (.spread [] rest (R.env env)))).go (.ev e (R.env env))) := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have he := hl.2.1
  have hf : FrameR NR R (.l (.spread [] rest env)) (.l (.spread [] rest (R.env env))) := by
    repeat first | exact env_roles NR R env | constructor
  have hfl : treeSupport live (Encode.frame (.l (.spread [] rest env))) := by
    exact ⟨⟨True.intro,True.intro,he,True.intro⟩,True.intro⟩
  refine ⟨?_,?_,(h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩⟩
  · rw [step_array_spread_entry_eq F s₀ e rest env hc₀]; rfl
  · rw [step_array_spread_entry_eq F s e rest (R.env env) hc]; rfl
end Host.Ts.Owned.Parametric
