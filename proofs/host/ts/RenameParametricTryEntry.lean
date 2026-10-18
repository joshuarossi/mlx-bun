import host.ts.RenameParametricHoist
import host.ts.RenameParametricViews
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_try_entry_eq (F : Ffi) (s : St F.S) (body : List Stmt)
    (handler : Option (Option Pat × List Stmt)) (finalizer : Option (List Stmt)) (env : Env)
    (hc : s.ctl = .ex (.try_ body handler finalizer) env) :
    step F s = M.pure (enterBlock (s.push (.s (.try_ handler finalizer env))) body env) := by
  simp only [step,hc,exStep]

/-- The original try entry installs its handler/finalizer frame and executes
the real lexical hoister for the protected body. -/
theorem step_try_entry_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (body : List Stmt) (handler : Option (Option Pat × List Stmt)) (finalizer : Option (List Stmt)) (env : Env)
    (hc₀ : s₀.ctl = .ex (.try_ body handler finalizer) env) (hi : noInitFunctions body = true)
    (sourceBound : s₀.next+(blockNames body).length ≤ 2^64) (targetBound : s.next+(blockNames body).length ≤ 2^64) :
    interpC (step F s₀).run C₀ = some (enterBlock (s₀.push (.s (.try_ handler finalizer env))) body env,C₀) ∧
    interpC (step F s).run C = some (enterBlock (s.push (.s (.try_ handler finalizer (R.env env)))) body (R.env env),C) ∧
    StateR NR FR R (CellsLive live s₀.next (blockNames body)) framed before after old old'
      (enterBlock (s₀.push (.s (.try_ handler finalizer env))) body env)
      (enterBlock (s.push (.s (.try_ handler finalizer (R.env env)))) body (R.env env)) := by
  have hc := (h.control_view hc₀).ex_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have he : treeSupport live (Encode.env env) := hl.2.1
  have hf : FrameR NR R (.s (.try_ handler finalizer env)) (.s (.try_ handler finalizer (R.env env))) :=
    .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _) (.cons (env_roles NR R env) .nil)))) .nil)
  have hfl : treeSupport live (Encode.frame (.s (.try_ handler finalizer env))) :=
    ⟨⟨True.intro,True.intro,he,True.intro⟩,True.intro⟩
  have hs := enterBlock_roles (h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩) body env hi he sourceBound targetBound
  refine ⟨?_,?_,hs⟩
  · rw [step_try_entry_eq F s₀ body handler finalizer env hc₀]; rfl
  · rw [step_try_entry_eq F s body handler finalizer (R.env env) hc]; rfl
end Host.Ts.Owned.Parametric
