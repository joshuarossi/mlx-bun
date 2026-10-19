import host.ts.RenameRetainedInventory
import host.ts.RenameParametricExpressionReturns
import host.ts.RenameRuntimeReturns
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameMaterialize
set_option Elab.async false
namespace Host.Ts.Owned.Parametric
open Host.Ts

theorem FrameR.chain_view {NR : NumV → NumV → Prop} {R : Ren} {f : Frame}
    (h : FrameR NR R (.e .chain) f) : f = .e .chain := by
  obtain ⟨ef', rfl, hh⟩ := h.e_view
  have ht := hh.tag_eq
  cases ef' <;> simp only [Encode.exprF, treeTag] at ht
  all_goals try contradiction
  case chain => rfl

/-- `Machine.retE` sends a returned value straight through `ExprF.chain`. -/
theorem step_chain_return_eq (F : Ffi) (s : St F.S) (v : Val) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .e .chain :: fs) :
    step F s = M.pure ({s with stack := fs}.ret v) := by
  simp only [step, hc, stepRet, hf, retStep, retE, retS, St.ret]

theorem step_chain_return_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ : Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .e .chain :: fs₀) :
    ∃ v fs, s.ctl = .ret v ∧ s.stack = .e .chain :: fs ∧
      interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret v₀, C₀) ∧
      interpC (step F s).run C = some ({s with stack := fs}.ret v, C) ∧
      StateR NR FR R live framed before after old old'
        ({s₀ with stack := fs₀}.ret v₀) ({s with stack := fs}.ret v) := by
  obtain ⟨v, hc, _⟩ := (h.control_view hc₀).ret_view
  obtain ⟨_, fs, hf, frameRelation, tailRelation⟩ := h.stack_view hf₀
  rw [frameRelation.chain_view] at hf
  have liveStack := h.stackLive
  rw [hf₀] at liveStack
  have controlRelation : ControlR NR R (.ret v₀) (.ret v) := hc ▸ h.control_view hc₀
  refine ⟨v, fs, hc, hf, ?_, ?_, (h.restack tailRelation liveStack.2).go controlRelation (hc₀ ▸ h.controlLive)⟩
  · rw [step_chain_return_eq F s₀ v₀ fs₀ hc₀ hf₀]; rfl
  · rw [step_chain_return_eq F s v fs hc hf]; rfl

end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Annotated
open Parametric

def RuntimeNotes.chainReturn (notes : RuntimeNotes) (tail : List Tree) : RuntimeNotes :=
  {notes with stack := tail}

theorem PureRuntimeStep.chain (F : Ffi) (s : St F.S) (value : Val) (frames : List Frame)
    (control : s.ctl = .ret value) (stack : s.stack = .e .chain :: frames) : PureRuntimeStep F s :=
  .of_pure F s _ (step_chain_return_eq F s value frames control stack)
    (RuntimePureEffects.control s (.ret value) frames)

theorem PureRuntimeCase.chain {F : Ffi} {NR : NumV → NumV → Prop} {FR : Ren → F.S → F.S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S} (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (frames : List Frame) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .e .chain :: frames) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue, targetControl, _⟩ := (h.control_view control).ret_view
  obtain ⟨_, targetFrames, targetStack, frameRelation, _⟩ := h.stack_view stack
  rw [frameRelation.chain_view] at targetStack
  exact ⟨.chain F s₀ value frames control stack,
    .chain F s targetValue targetFrames targetControl targetStack⟩

/-- Popping `ExprF.chain` returns the same value. Heap, native state, fresh
counter and every non-runtime inventory stay put. -/
theorem RuntimeInventory.chain_return_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (frames : List Frame) (headNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .e .chain :: frames)
    (controlNote : notes.control = returnNote role)
    (stackNotes : notes.stack = headNote :: tailNotes) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret value, C₀) ∧
      interpC (step F s).run C = some (result, C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret value) result ∧
      RuntimeInventory (notes.chainReturn tailNotes) ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret value) result := by
  obtain ⟨_, _, targetControl, targetStack, left, right, related⟩ :=
    step_chain_return_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
      s₀ s h value frames control stack
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote, control] at sourceControl
  rw [controlNote, targetControl] at targetControlRole
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes, stack, List.map_cons] at sourceStack
  rw [stackNotes, targetStack, List.map_cons] at targetStackRole
  exact ⟨_, left, right, related, inventory.keyLive,
    ⟨by rw [RuntimeNotes.chainReturn, controlNote, St.ret]; exact sourceControl, sourceStack.tail, inventory.source.cells⟩,
    ⟨by rw [RuntimeNotes.chainReturn, controlNote, St.ret]; exact targetControlRole, targetStackRole.tail, inventory.target.cells⟩⟩

theorem RetainedInventory.chain_return (F : Ffi) (notes : RetainedNotes) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (R : Ren) (FR : Ren → F.S → F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S) (S₀ S₁ : SSrv)
    (inst : Inst ν₀ S₀ C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (frames : List Frame) (headNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .e .chain :: frames)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = headNote :: tailNotes)
    (symbolic : interpS (step F s₀).run S₀ = some ({s₀ with stack := frames}.ret value, S₁)) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret value, C₀) ∧
      interpC (step F s).run C = some (result, C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret value) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.chainReturn tailNotes)) ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret value) result ∧
      Inst ν₀ S₁ C₀ := by
  obtain ⟨result, sourceRun, targetRun, related, annotated⟩ := inventory.runtime.chain_return_step F FR
    notes.runtime ν₀ ν C₀ C R live framed before after old old' s₀ s h value role frames headNote tailNotes
    control stack controlNote stackNotes
  exact ⟨result, sourceRun, targetRun, related,
    inventory.pure_step annotated (PureRuntimeCase.chain h value frames control stack) sourceRun targetRun
      (TableExtends.refl C₀) (TableExtends.refl C),
    pure_step_inst F ν₀ S₀ S₁ C₀ s₀ _ inst symbolic sourceRun⟩

end Host.Ts.Owned.Annotated
