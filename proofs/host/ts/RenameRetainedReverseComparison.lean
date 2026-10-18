import host.ts.RenameRetainedClosedComparison
import host.ts.RenameRetainedHeapFrame
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

inductive ReverseComparisonKind where | gt | ge

def ReverseComparisonKind.jsOp : ReverseComparisonKind → BinOp
  | .gt => .gt | .ge => .ge

def ReverseComparisonKind.numOp : ReverseComparisonKind → NTest
  | .gt => .lt | .ge => .le

theorem step_reverse_literal_comparison_eq (F : Ffi) (s : St F.S)
    (op : ReverseComparisonKind) (a b : F64) (frames : List Frame)
    (control : s.ctl = .ret (.num (.lit b)))
    (stack : s.stack = .e (.binR op.jsOp (.num (.lit a)))::frames) :
    step F s = M.pure ({s with stack := frames}.ret (.bool (F64.test op.numOp b a))) := by
  cases op <;> funext β k <;>
    simp only [step,control,stepRet,stack,retStep,retE,ReverseComparisonKind.jsOp,
      ReverseComparisonKind.numOp,binOp,compare,toNum,numTest,M.bind,M.pure,retS,
      Bool.cond_true,Bool.cond_false]

theorem RetainedInventory.closed_reverse_literal_comparison_step
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (op : ReverseComparisonKind) (a₀ b₀ : F64) (ea eb : SymE) (frames : List Frame) (tail : List Tree)
    (control : s₀.ctl = .ret (.num (.lit b₀)))
    (stack : s₀.stack = .e (.binR op.jsOp (.num (.lit a₀)))::frames)
    (controlNote : notes.runtime.control = returnNote (.literal eb))
    (stackNote : notes.runtime.stack = binaryRightNote op.jsOp (.literal ea)::tail)
    (leftClosed : ea.closed = true) (rightClosed : eb.closed = true) :
    ∃ targetFrames,
      let answer := F64.test op.numOp b₀ a₀
      let t₀ := {s₀ with stack := frames}.ret (.bool answer)
      let t := {s with stack := targetFrames}.ret (.bool answer)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool answer) tail))
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨right,targetControl,rightRelation⟩ := (h.control_view control).ret_view
  obtain ⟨b,rfl,_⟩ := rightRelation.num_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨left,frameEq,leftRelation⟩ := frameRelation.binR_view
  obtain ⟨a,rfl,_⟩ := leftRelation.num_view
  rw [frameEq] at targetStack
  have sourceControl := inventory.runtime.source.control
  have targetControlRole := inventory.runtime.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceStack := inventory.runtime.source.stack
  have targetStackRole := inventory.runtime.target.stack
  rw [stackNote,stack,List.map_cons] at sourceStack
  rw [stackNote,targetStack,List.map_cons] at targetStackRole
  have sourceA : ea.eval ν₀ = a₀ :=
    (Option.some.inj ((binaryRightNote_view sourceStack.head).numeric_denote (.literal ea))).symm
  have sourceB : eb.eval ν₀ = b₀ :=
    (Option.some.inj ((returnNote_view sourceControl).numeric_denote (.literal eb))).symm
  have targetA := binaryRightNote_view targetStackRole.head
  have targetB := returnNote_view targetControlRole
  cases targetA with | literal _ av denoteA =>
    cases targetB with | literal _ bv denoteB =>
      have sameA : av = a₀ := (Option.some.inj denoteA).trans ((ea.eval_closed leftClosed ν ν₀).trans sourceA)
      have sameB : bv = b₀ := (Option.some.inj denoteB).trans ((eb.eval_closed rightClosed ν ν₀).trans sourceB)
      subst av; subst bv
      have active := h.stackLive
      rw [stack] at active
      have post : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
          ({s₀ with stack := frames}.ret (.bool (F64.test op.numOp b₀ a₀)))
          ({s with stack := targetFrames}.ret (.bool (F64.test op.numOp b₀ a₀))) :=
        (h.restack tailRelation active.2).go (.node _ (.cons (.value (.bool _)) .nil)) ⟨True.intro,True.intro⟩
      have runtime : RuntimeInventory (notes.runtime.binaryResult (.bool (F64.test op.numOp b₀ a₀)) tail)
          ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret (.bool (F64.test op.numOp b₀ a₀)))
          ({s with stack := targetFrames}.ret (.bool (F64.test op.numOp b₀ a₀))) :=
        ⟨inventory.runtime.keyLive,
          ⟨returnNote_holds (.bool _),sourceStack.tail,inventory.runtime.source.cells⟩,
          ⟨returnNote_holds (.bool _),targetStackRole.tail,inventory.runtime.target.cells⟩⟩
      refine ⟨targetFrames,?_,?_,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
      · rw [step_reverse_literal_comparison_eq F s₀ op a₀ b₀ frames control stack]; rfl
      · rw [step_reverse_literal_comparison_eq F s op a₀ b₀ targetFrames targetControl targetStack]; rfl
theorem RetainedInventory.reverse_literal_comparison_step
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (op : ReverseComparisonKind) (a₀ b₀ : F64) (ea eb : SymE) (frames : List Frame) (tail : List Tree)
    (control : s₀.ctl = .ret (.num (.lit b₀)))
    (stack : s₀.stack = .e (.binR op.jsOp (.num (.lit a₀)))::frames)
    (controlNote : notes.runtime.control = returnNote (.literal eb))
    (stackNote : notes.runtime.stack = binaryRightNote op.jsOp (.literal ea)::tail)
    (answer : Bool)
    (sourceGuard : F64.test op.numOp (eb.eval ν₀) (ea.eval ν₀) = answer)
    (targetGuard : F64.test op.numOp (eb.eval ν) (ea.eval ν) = answer) :
    ∃ targetFrames,
      let t₀ := {s₀ with stack := frames}.ret (.bool answer)
      let t := {s with stack := targetFrames}.ret (.bool answer)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool answer) tail))
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨right,targetControl,rightRelation⟩ := (h.control_view control).ret_view
  obtain ⟨b,rfl,_⟩ := rightRelation.num_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨left,frameEq,leftRelation⟩ := frameRelation.binR_view
  obtain ⟨a,rfl,_⟩ := leftRelation.num_view
  rw [frameEq] at targetStack
  have sourceControl := inventory.runtime.source.control
  have targetControlRole := inventory.runtime.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceStack := inventory.runtime.source.stack
  have targetStackRole := inventory.runtime.target.stack
  rw [stackNote,stack,List.map_cons] at sourceStack
  rw [stackNote,targetStack,List.map_cons] at targetStackRole
  have sourceA : ea.eval ν₀ = a₀ :=
    (Option.some.inj ((binaryRightNote_view sourceStack.head).numeric_denote (.literal ea))).symm
  have sourceB : eb.eval ν₀ = b₀ :=
    (Option.some.inj ((returnNote_view sourceControl).numeric_denote (.literal eb))).symm
  have targetA := binaryRightNote_view targetStackRole.head
  have targetB := returnNote_view targetControlRole
  cases targetA with | literal _ av denoteA =>
    cases targetB with | literal _ bv denoteB =>
      have targetA : av = ea.eval ν := Option.some.inj denoteA
      have targetB : bv = eb.eval ν := Option.some.inj denoteB
      have sourceAnswer : F64.test op.numOp b₀ a₀ = answer := by
        simpa only [sourceA,sourceB] using sourceGuard
      have targetAnswer : F64.test op.numOp bv av = answer := by
        simpa only [targetA,targetB] using targetGuard
      have active := h.stackLive
      rw [stack] at active
      have post : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
          ({s₀ with stack := frames}.ret (.bool answer))
          ({s with stack := targetFrames}.ret (.bool answer)) :=
        (h.restack tailRelation active.2).go (.node _ (.cons (.value (.bool _)) .nil)) ⟨True.intro,True.intro⟩
      have runtime : RuntimeInventory (notes.runtime.binaryResult (.bool answer) tail)
          ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret (.bool answer))
          ({s with stack := targetFrames}.ret (.bool answer)) :=
        ⟨inventory.runtime.keyLive,
          ⟨returnNote_holds (.bool _),sourceStack.tail,inventory.runtime.source.cells⟩,
          ⟨returnNote_holds (.bool _),targetStackRole.tail,inventory.runtime.target.cells⟩⟩
      refine ⟨targetFrames,?_,?_,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
      · rw [step_reverse_literal_comparison_eq F s₀ op a₀ b₀ frames control stack,sourceAnswer]; rfl
      · rw [step_reverse_literal_comparison_eq F s op av bv targetFrames targetControl targetStack,targetAnswer]; rfl
end Host.Ts.Owned.Annotated
