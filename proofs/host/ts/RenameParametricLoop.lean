import host.ts.RenameParametricControl
namespace Host.Ts.Owned.Parametric

def afterWhileTest {S : Type} (s : St S) (b : Bool) (c : Expr) (body : Stmt)
    (env : Env) (labels : List Name) (fs : List Frame) : St S :=
  if b then {s with ctl := .ex body env,stack := .lp (.whileBody c body env labels) :: fs}
  else {s with ctl := .ret .undef,stack := fs}

/-- Real source while-test dispatch, including the exit arm. -/
theorem step_while_test_eq (F : Ffi) (s : St F.S) (b : Bool) (c : Expr) (body : Stmt)
    (env : Env) (labels : List Name) (fs : List Frame)
    (hc : s.ctl = .ret (.bool b)) (hf : s.stack = .lp (.whileTest c body env labels) :: fs) :
    step F s = M.pure (afterWhileTest s b c body env labels fs) := by
  cases b <;> funext β k <;>
    simp only [step,hc,stepRet,hf,retStep,retLp,truthy,M.bind,M.pure,
      Bool.cond_true,Bool.cond_false,retS,St.ret,St.go,St.push,afterWhileTest,
      Bool.false_eq_true,↓reduceIte]

/-- Actual source-loop continuation/exit preserves full runtime roles. The
boolean is the already evaluated source condition, not an assumed loop step. -/
theorem step_while_test_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (b : Bool) (c : Expr) (body : Stmt) (env : Env) (labels : List Name) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret (.bool b)) (hc : s.ctl = .ret (.bool b))
    (hf₀ : s₀.stack = .lp (.whileTest c body env labels) :: fs₀)
    (hf : s.stack = .lp (.whileTest c body (R.env env) labels) :: fs) :
    interpC (step F s₀).run C₀ = some (afterWhileTest s₀ b c body env labels fs₀,C₀) ∧
    interpC (step F s).run C = some (afterWhileTest s b c body (R.env env) labels fs,C) ∧
    StateR NR FR R live framed before after old old'
      (afterWhileTest s₀ b c body env labels fs₀)
      (afterWhileTest s b c body (R.env env) labels fs) := by
  refine ⟨?_,?_,?_⟩
  · rw [step_while_test_eq F s₀ b c body env labels fs₀ hc₀ hf₀]; rfl
  · rw [step_while_test_eq F s b c body (R.env env) labels fs hc hf]; rfl
  · have hs := h.stack
    have hsl := h.stackLive
    rw [hf₀,hf] at hs
    rw [hf₀] at hsl
    have he : treeSupport live (Encode.env env) := hsl.1.1.2.2.1
    cases hs with
    | cons hhead htail =>
      have hh := h.restack htail hsl.2
      have henv := env_roles NR R env
      cases b
      · exact hh.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
      · have hframe : FrameR NR R (.lp (.whileBody c body env labels))
            (.lp (.whileBody c body (R.env env) labels)) :=
          .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _) (.cons henv (.cons (.atom _ _) .nil))))) .nil)
        have hfl : treeSupport live (Encode.frame (.lp (.whileBody c body env labels))) :=
          ⟨⟨True.intro,True.intro,he,True.intro,True.intro⟩,True.intro⟩
        exact (h.restack (.cons hframe htail) ⟨hfl,hsl.2⟩).go
          (.node _ (.cons (.atom _ _) (.cons henv .nil))) ⟨True.intro,he,True.intro⟩

/-- A completed ordinary while body reevaluates its source condition. -/
theorem step_while_body_eq (F : Ffi) (s : St F.S) (v : Val) (c : Expr) (body : Stmt)
    (env : Env) (labels : List Name) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .lp (.whileBody c body env labels) :: fs) :
    step F s = M.pure {s with ctl := .ev c env,stack := .lp (.whileTest c body env labels) :: fs} := by
  simp only [step,hc,stepRet,hf,retStep,retLp,St.push,St.go]

/-- Exact loop-back control transfer, retaining the related tail stack and all
live state. The discarded body's value need not be used by the condition. -/
theorem step_while_body_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ v : Val) (c : Expr) (body : Stmt) (env : Env) (labels : List Name) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .lp (.whileBody c body env labels) :: fs₀)
    (hf : s.stack = .lp (.whileBody c body (R.env env) labels) :: fs) :
    interpC (step F s₀).run C₀ = some ({s₀ with ctl := .ev c env,stack := .lp (.whileTest c body env labels) :: fs₀},C₀) ∧
    interpC (step F s).run C = some ({s with ctl := .ev c (R.env env),stack := .lp (.whileTest c body (R.env env) labels) :: fs},C) ∧
    StateR NR FR R live framed before after old old'
      {s₀ with ctl := .ev c env,stack := .lp (.whileTest c body env labels) :: fs₀}
      {s with ctl := .ev c (R.env env),stack := .lp (.whileTest c body (R.env env) labels) :: fs} := by
  refine ⟨?_,?_,?_⟩
  · rw [step_while_body_eq F s₀ v₀ c body env labels fs₀ hc₀ hf₀]; rfl
  · rw [step_while_body_eq F s v c body (R.env env) labels fs hc hf]; rfl
  · have hs := h.stack
    have hsl := h.stackLive
    rw [hf₀,hf] at hs
    rw [hf₀] at hsl
    have he : treeSupport live (Encode.env env) := hsl.1.1.2.2.1
    cases hs with
    | cons hhead htail =>
      have henv := env_roles NR R env
      have hframe : FrameR NR R (.lp (.whileTest c body env labels))
          (.lp (.whileTest c body (R.env env) labels)) :=
        .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _) (.cons henv (.cons (.atom _ _) .nil))))) .nil)
      have hfl : treeSupport live (Encode.frame (.lp (.whileTest c body env labels))) :=
        ⟨⟨True.intro,True.intro,he,True.intro,True.intro⟩,True.intro⟩
      exact (h.restack (.cons hframe htail) ⟨hfl,hsl.2⟩).go
        (.node _ (.cons (.atom _ _) (.cons henv .nil))) ⟨True.intro,he,True.intro⟩

end Host.Ts.Owned.Parametric
