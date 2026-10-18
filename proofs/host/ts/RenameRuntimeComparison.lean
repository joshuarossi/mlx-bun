import host.ts.RenameRuntimeSourceCut
import host.ts.RenameParametricTests
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- A comparison consumes the saved operand meanings. Its two guard proofs
must be established for the supported source and target valuations; they are
facts about symbolic arithmetic, not supplied target values or executions. -/
theorem RuntimeInventory.comparison_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (op : ComparisonKind) (a₀ b₀ : NumV) (ea eb : SymE) (leftRole rightRole : Value)
    (leftNumeric : NumericRole leftRole ea) (rightNumeric : NumericRole rightRole eb)
    (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (.num b₀)) (stack : s₀.stack = .e (.binR op.jsOp (.num a₀))::frames)
    (controlNote : notes.control = returnNote rightRole)
    (stackNote : notes.stack = binaryRightNote op.jsOp leftRole::tailNotes)
    (answer : Bool) (sourceGuard : F64.test op.numOp (ea.eval ν₀) (eb.eval ν₀) = answer)
    (targetGuard : F64.test op.numOp (ea.eval ν) (eb.eval ν) = answer) :
    ∃ targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret (.bool (op.result answer)),C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret (.bool (op.result answer)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret (.bool (op.result answer))) ({s with stack := targetFrames}.ret (.bool (op.result answer))) ∧
      RuntimeInventory (notes.binaryResult (.bool (op.result answer)) tailNotes) ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.ret (.bool (op.result answer))) ({s with stack := targetFrames}.ret (.bool (op.result answer))) := by
  obtain ⟨right,targetControl,rightRelation⟩ := (h.control_view control).ret_view
  obtain ⟨b,rfl,_⟩ := rightRelation.num_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨left,frameEq,leftRelation⟩ := frameRelation.binR_view
  obtain ⟨a,rfl,_⟩ := leftRelation.num_view
  rw [frameEq] at targetStack
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceStack := inventory.source.stack
  have targetStackRoles := inventory.target.stack
  rw [stackNote,stack,List.map_cons] at sourceStack
  rw [stackNote,targetStack,List.map_cons] at targetStackRoles
  have aRole : NumRole ν₀ ν C₀ C ea a₀ a :=
    ⟨(binaryRightNote_view sourceStack.head).numeric_denote leftNumeric,
      (binaryRightNote_view targetStackRoles.head).numeric_denote leftNumeric⟩
  have bRole : NumRole ν₀ ν C₀ C eb b₀ b :=
    ⟨(returnNote_view sourceControl).numeric_denote rightNumeric,
      (returnNote_view targetControlRole).numeric_denote rightNumeric⟩
  obtain ⟨sourceRun,targetRun,post⟩ := step_comparison_roles F FR R ν₀ ν C₀ C live framed before after old old'
    s₀ s h op a₀ a b₀ b ea eb frames targetFrames aRole bRole control targetControl stack targetStack answer sourceGuard targetGuard
  exact ⟨targetFrames,sourceRun,targetRun,post,inventory.keyLive,
    ⟨returnNote_holds (.bool _),sourceStack.tail,inventory.source.cells⟩,
    ⟨returnNote_holds (.bool _),targetStackRoles.tail,inventory.target.cells⟩⟩
end Host.Ts.Owned.Annotated
