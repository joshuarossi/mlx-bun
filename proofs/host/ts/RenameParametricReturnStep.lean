import host.ts.RenameParametricViews

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem ControlR.returnAbrupt_view {NR : NumV → NumV → Prop} {R : Ren}
    {v : Val} {c : Ctl} (h : ControlR NR R (.abr (.ret v)) c) :
    ∃ v', c = .abr (.ret v') ∧ ValueR NR R v v' := by
  obtain ⟨a,rfl,ha⟩ := h.abr_view
  have ht := ha.tag_eq
  cases a <;> simp only [Encode.abr,treeTag] at ht
  all_goals try contradiction
  case ret v' =>
    cases ha with | node tag hs =>
      cases hs with | cons hv hs =>
        cases hv with | value hv => exact ⟨v',rfl,hv⟩

theorem FrameR.returnExit_view {NR : NumV → NumV → Prop} {R : Ren}
    {exit : ReturnExit} {env : Env} {f : Frame}
    (h : FrameR NR R (exit.frame env) f) : f = exit.frame (R.env env) := by
  cases exit with
  | explicitReturn => exact h.ret_view
  | emptyBlock => exact h.block_view
  | emptyScope => exact h.emptyScope_view
  | implicitCall => exact h.call_view

theorem FrameR.returnUnwind_view {NR : NumV → NumV → Prop} {R : Ren}
    {unwind : ReturnUnwind} {env : Env} {f : Frame}
    (h : FrameR NR R (unwind.frame env) f) : f = unwind.frame (R.env env) := by
  cases unwind with
  | block ss => exact h.block_view
  | scope => exact h.emptyScope_view
  | call => exact h.call_view

/-- The actual source return frame determines the target return transition.
The returned value and remaining target stack are obtained from the state
relation, rather than supplied as additional execution premises. -/
theorem step_return_exit_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (exit : ReturnExit) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = exit.frame env::fs₀) :
    ∃ (v : Val) (fs : List Frame),
      interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.go (exit.control v₀),C₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.go (exit.control v),C) ∧
      StateR NR FR R live framed before after old old'
        ({s₀ with stack := fs₀}.go (exit.control v₀))
        ({s with stack := fs}.go (exit.control v)) ∧ ValueR NR R v₀ v := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.returnExit_view] at hf
  obtain ⟨hr₀,hr,hpost⟩ := step_return_exit_roles F NR FR R C₀ C live framed
    before after old old' s₀ s h v₀ v exit env fs₀ fs hc₀ hc hf₀ hf
  exact ⟨v,fs,hr₀,hr,hpost,hv⟩

/-- A returned completion unwinds the target lexical/function frames selected
by the source execution, preserving the related return value and full state. -/
theorem step_return_unwind_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (unwind : ReturnUnwind) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .abr (.ret v₀)) (hf₀ : s₀.stack = unwind.frame env::fs₀) :
    ∃ (v : Val) (fs : List Frame),
      interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.go (unwind.control v₀),C₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.go (unwind.control v),C) ∧
      StateR NR FR R live framed before after old old'
        ({s₀ with stack := fs₀}.go (unwind.control v₀))
        ({s with stack := fs}.go (unwind.control v)) ∧ ValueR NR R v₀ v := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).returnAbrupt_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.returnUnwind_view] at hf
  obtain ⟨hr₀,hr,hpost⟩ := step_return_unwind_roles F NR FR R C₀ C live framed
    before after old old' s₀ s h v₀ v unwind env fs₀ fs hc₀ hc hf₀ hf
  exact ⟨v,fs,hr₀,hr,hpost,hv⟩

end Host.Ts.Owned.Parametric
