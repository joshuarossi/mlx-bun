import host.ts.RenameParametricBuffer
import host.ts.RenameBranch
namespace Host.Ts.Owned.Parametric

theorem env_roles (NR : NumV → NumV → Prop) (R : Ren) (env : Env) :
    TreeR NR R (Encode.env env) (Encode.env (R.env env)) := by
  induction env with
  | nil => exact .node _ .nil
  | cons p env ih =>
    obtain ⟨name,a⟩ := p
    cases ih with
    | node tag htail =>
      exact .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.address a) .nil))) htail)

/-- Actual source `if` control transfer after its guard has been established. -/
theorem step_if_bool_eq (F : Ffi) (s : St F.S) (b : Bool) (yes : Stmt) (no : Option Stmt)
    (env : Env) (fs : List Frame) (hc : s.ctl = .ret (.bool b))
    (hf : s.stack = .s (.if_ yes no env) :: fs) :
    step F s = M.pure {s with ctl := branchCtl b yes no env, stack := fs} := by
  cases b <;> cases no <;> funext β k <;>
    simp only [step,hc,stepRet,hf,retStep,retSt,truthy,M.bind,M.pure,
      Bool.cond_true,Bool.cond_false,retS,St.ret,St.go,branchCtl]

/-- The true source branch preserves the complete runtime relation. Numeric
comparisons establish the common boolean separately for each valuation. -/
theorem step_if_bool_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (b : Bool) (yes : Stmt) (no : Option Stmt) (env : Env) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret (.bool b)) (hc : s.ctl = .ret (.bool b))
    (hf₀ : s₀.stack = .s (.if_ yes no env) :: fs₀)
    (hf : s.stack = .s (.if_ yes no (R.env env)) :: fs) :
    interpC (step F s₀).run C₀ = some ({s₀ with ctl := branchCtl b yes no env,stack := fs₀},C₀) ∧
    interpC (step F s).run C = some ({s with ctl := branchCtl b yes no (R.env env),stack := fs},C) ∧
    StateR NR FR R live framed before after old old'
      {s₀ with ctl := branchCtl b yes no env,stack := fs₀}
      {s with ctl := branchCtl b yes no (R.env env),stack := fs} := by
  refine ⟨?_,?_,?_⟩
  · rw [step_if_bool_eq F s₀ b yes no env fs₀ hc₀ hf₀]; rfl
  · rw [step_if_bool_eq F s b yes no (R.env env) fs hc hf]; rfl
  · have hs := h.stack
    have hsl := h.stackLive
    rw [hf₀,hf] at hs
    rw [hf₀] at hsl
    have he : treeSupport live (Encode.env env) := hsl.1.1.2.2.1
    cases hs with
    | cons hhead htail =>
      have hh := h.restack htail hsl.2
      have henv := env_roles NR R env
      cases b <;> cases no <;> dsimp only [branchCtl] <;>
        first
        | exact hh.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
        | exact hh.go (.node _ (.cons (.atom _ _) (.cons henv .nil))) ⟨True.intro,he,True.intro⟩

end Host.Ts.Owned.Parametric
