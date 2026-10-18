import host.ts.RenameParametricMapControl
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_if_undefined_eq (F : Ffi) (s : St F.S) (yes : Stmt) (no : Option Stmt)
    (env : Env) (fs : List Frame) (hc : s.ctl = .ret .undef)
    (hf : s.stack = .s (.if_ yes no env)::fs) :
    step F s = M.pure {s with ctl := branchCtl false yes no env,stack := fs} := by
  cases no <;> funext β k <;>
    simp only [step,hc,stepRet,hf,retStep,retSt,truthy,M.bind,M.pure,
      Bool.cond_false,retS,St.ret,St.go,branchCtl]

/-- Undefined is rigid under the value relation, so its real if branch is
derived without a numeric guard or target-branch premise. -/
theorem step_if_undefined_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (yes : Stmt) (no : Option Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret .undef) (hf₀ : s₀.stack = .s (.if_ yes no env)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with ctl := branchCtl false yes no env,stack := fs₀},C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        {s₀ with ctl := branchCtl false yes no env,stack := fs₀} result ∧ result.heap = s.heap := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  rw [hfr.if_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have he : treeSupport live (Encode.env env) := hl.1.1.2.2.1
  have hs : StateR NR FR R live framed before after old old'
      {s₀ with ctl := branchCtl false yes no env,stack := fs₀}
      {s with ctl := branchCtl false yes no (R.env env),stack := fs} := by
    have hh := h.restack htail hl.2
    cases no <;> dsimp only [branchCtl]
    · exact hh.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
    · exact hh.go (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩
  refine ⟨_,?_,?_,hs,rfl⟩
  · rw [step_if_undefined_eq F s₀ yes no env fs₀ hc₀ hf₀]; rfl
  · rw [step_if_undefined_eq F s yes no (R.env env) fs hc hf]; rfl
end Host.Ts.Owned.Parametric
