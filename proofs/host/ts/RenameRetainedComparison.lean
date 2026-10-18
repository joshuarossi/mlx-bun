import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeComparison
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem PureRuntimeStep.comparison (F : Ffi) (s : St F.S) (op : ComparisonKind) (a b : NumV)
    (frames : List Frame) (control : s.ctl = .ret (.num b))
    (stack : s.stack = .e (.binR op.jsOp (.num a))::frames) : PureRuntimeStep F s := by
  intro C target D run
  rw [step_comparison_eq F s op a b frames control stack,numTest_map] at run
  cases primitive : interpC (numTest op.numOp a b).run C with
  | none => simp only [primitive,Option.map_none] at run; contradiction
  | some value =>
    obtain ⟨value,table⟩ := value
    simp only [primitive,Option.map_some] at run
    have eq : ({s with stack := frames}.ret (.bool (op.result value))) = target := congrArg Prod.fst (Option.some.inj run)
    exact eq ▸ (show RuntimePureEffects s ({s with stack := frames}.ret (.bool (op.result value))) from ⟨rfl,rfl,rfl⟩)

theorem PureRuntimeCase.comparison {F : Ffi} {NR : NumV → NumV → Prop} {FR : Ren → F.S → F.S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (op : ComparisonKind) (a b : NumV) (frames : List Frame) (control : s₀.ctl = .ret (.num b))
    (stack : s₀.stack = .e (.binR op.jsOp (.num a))::frames) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,rightRelation⟩ := (h.control_view control).ret_view
  obtain ⟨targetB,rfl,_⟩ := rightRelation.num_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetLeft,frameEq,leftRelation⟩ := frameRelation.binR_view
  obtain ⟨targetA,rfl,_⟩ := leftRelation.num_view
  rw [frameEq] at targetStack
  exact ⟨.comparison F s₀ op a b frames control stack,
    .comparison F s op targetA targetB targetFrames targetControl targetStack⟩

theorem RetainedInventory.comparison_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (op : ComparisonKind) (a₀ b₀ : NumV) (ea eb : SymE) (leftRole rightRole : Value)
    (leftNumeric : NumericRole leftRole ea) (rightNumeric : NumericRole rightRole eb)
    (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (.num b₀)) (stack : s₀.stack = .e (.binR op.jsOp (.num a₀))::frames)
    (controlNote : notes.runtime.control = returnNote rightRole)
    (stackNote : notes.runtime.stack = binaryRightNote op.jsOp leftRole::tailNotes)
    (answer : Bool) (sourceGuard : F64.test op.numOp (ea.eval ν₀) (eb.eval ν₀) = answer)
    (targetGuard : F64.test op.numOp (ea.eval ν) (eb.eval ν) = answer) :
    ∃ targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret (.bool (op.result answer)),C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret (.bool (op.result answer)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret (.bool (op.result answer))) ({s with stack := targetFrames}.ret (.bool (op.result answer))) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool (op.result answer)) tailNotes)) ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret (.bool (op.result answer))) ({s with stack := targetFrames}.ret (.bool (op.result answer))) := by
  obtain ⟨targetFrames,sourceRun,targetRun,post,runtime⟩ := inventory.runtime.comparison_step F FR notes.runtime ν₀ ν C₀ C R
    live framed before after old old' s₀ s h op a₀ b₀ ea eb leftRole rightRole leftNumeric rightNumeric frames tailNotes
    control stack controlNote stackNote answer sourceGuard targetGuard
  exact ⟨targetFrames,sourceRun,targetRun,post,inventory.pure_step runtime
    (.comparison h op a₀ b₀ frames control stack) sourceRun targetRun (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
