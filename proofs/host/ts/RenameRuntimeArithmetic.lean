import host.ts.RenameRuntimeDispatch

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Arithmetic consumes the meanings fixed in the control and saved operand
notes. The result records their symbolic operation and extends each number
server independently. -/
theorem RuntimeInventory.arithmetic_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (op : ArithmeticKind) (a₀ b₀ : NumV) (ea eb : SymE) (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (.num b₀))
    (stack : s₀.stack = .e (.binR op.jsOp (.num a₀))::frames)
    (controlNote : notes.control = returnNote (.num eb))
    (stackNote : notes.stack = binaryRightNote op.jsOp (.num ea)::tailNotes) :
    ∃ v₀ D₀ v D targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret (.num v₀),D₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret (.num v),D) ∧
      Parametric.StateR (NumberRoles ν₀ ν D₀ D) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret (.num v₀)) ({s with stack := targetFrames}.ret (.num v)) ∧
      RuntimeInventory (notes.binaryResult (.num (.bin op.numOp ea eb)) tailNotes)
        ν₀ ν D₀ D R live ({s₀ with stack := frames}.ret (.num v₀))
        ({s with stack := targetFrames}.ret (.num v)) ∧
      TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨bv,targetControl,bRoles⟩ := (h.control_view control).ret_view
  obtain ⟨b,rfl,_⟩ := bRoles.num_view
  obtain ⟨frame,targetFrames,targetStack,frameRoles,_⟩ := h.stack_view stack
  obtain ⟨av,frameEquation,aRoles⟩ := frameRoles.binR_view
  obtain ⟨a,rfl,_⟩ := aRoles.num_view
  rw [frameEquation] at targetStack
  have sourceControlNote := inventory.source.control
  rw [controlNote,control] at sourceControlNote
  have targetControlNote := inventory.target.control
  rw [controlNote,targetControl] at targetControlNote
  have sourceStackNotes := inventory.source.stack
  rw [stackNote,stack,List.map_cons] at sourceStackNotes
  have targetStackNotes := inventory.target.stack
  rw [stackNote,targetStack,List.map_cons] at targetStackNotes
  have aRole : NumRole ν₀ ν C₀ C ea a₀ a :=
    ⟨(binaryRightNote_view sourceStackNotes.head).num_denote,
     (binaryRightNote_view targetStackNotes.head).num_denote⟩
  have bRole : NumRole ν₀ ν C₀ C eb b₀ b :=
    ⟨(returnNote_view sourceControlNote).num_denote,(returnNote_view targetControlNote).num_denote⟩
  obtain ⟨v₀,D₀,v,D,left,right,resultRole,related,leftExt,rightExt⟩ :=
    step_arithmetic_roles F FR R ν₀ ν C₀ C live framed before after old old' s₀ s h
      op a₀ a b₀ b ea eb frames targetFrames aRole bRole control targetControl stack targetStack
  refine ⟨v₀,D₀,v,D,targetFrames,left,right,related,?_,leftExt,rightExt⟩
  refine ⟨inventory.keyLive,?_,?_⟩
  · exact ⟨returnNote_holds (.num _ _ resultRole.left),
      sourceStackNotes.tail.mono leftExt,inventory.source.cells.mono leftExt⟩
  · exact ⟨returnNote_holds (.num _ _ resultRole.right),
      targetStackNotes.tail.mono rightExt,inventory.target.cells.mono rightExt⟩

theorem Value.Holds.literal_view {ν : Nat → F64} {C : CSrv} {R : Ren} {meaning : SymE} {v : Val}
    (h : (Value.literal meaning).Holds ν C R v) :
    ∃ x, v = .num (.lit x) ∧ NumDenote ν C meaning (.lit x) := by
  cases h with | literal _ x denotation => exact ⟨x,rfl,denotation⟩

theorem literal_bin_denote {ν : Nat → F64} {C : CSrv} {ea eb : SymE} {a b : F64}
    (left : NumDenote ν C ea (.lit a)) (right : NumDenote ν C eb (.lit b)) (op : NBin) :
    NumDenote ν C (.bin op ea eb) (.lit (F64.bin op a b)) := by
  have ha : a = ea.eval ν := Option.some.inj left
  have hb : b = eb.eval ν := Option.some.inj right
  change some (F64.bin op a b) = some (F64.bin op (ea.eval ν) (eb.eval ν))
  rw [ha,hb]

/-- Literal arithmetic keeps its literal representation, which the original
FFI offset/count decoders require. This follows from the actual folding rule,
without identifying unrelated equal literal occurrences. -/
theorem RuntimeInventory.literal_arithmetic_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (op : ArithmeticKind) (a₀ b₀ : F64) (ea eb : SymE) (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (.num (.lit b₀)))
    (stack : s₀.stack = .e (.binR op.jsOp (.num (.lit a₀)))::frames)
    (controlNote : notes.control = returnNote (.literal eb))
    (stackNote : notes.stack = binaryRightNote op.jsOp (.literal ea)::tailNotes) :
    ∃ a b targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret (.num (.lit (F64.bin op.numOp a₀ b₀))),C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret (.num (.lit (F64.bin op.numOp a b))),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret (.num (.lit (F64.bin op.numOp a₀ b₀))))
        ({s with stack := targetFrames}.ret (.num (.lit (F64.bin op.numOp a b)))) ∧
      RuntimeInventory (notes.binaryResult (.literal (.bin op.numOp ea eb)) tailNotes)
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret (.num (.lit (F64.bin op.numOp a₀ b₀))))
        ({s with stack := targetFrames}.ret (.num (.lit (F64.bin op.numOp a b)))) ∧
      s.stack = .e (.binR op.jsOp (.num (.lit a)))::targetFrames := by
  obtain ⟨bv,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRoles,tailRoles⟩ := h.stack_view stack
  obtain ⟨av,frameEquation,_⟩ := frameRoles.binR_view
  rw [frameEquation] at targetStack
  have sourceControlNote := inventory.source.control
  rw [controlNote,control] at sourceControlNote
  have targetControlNote := inventory.target.control
  rw [controlNote,targetControl] at targetControlNote
  have sourceStackNotes := inventory.source.stack
  rw [stackNote,stack,List.map_cons] at sourceStackNotes
  have targetStackNotes := inventory.target.stack
  rw [stackNote,targetStack,List.map_cons] at targetStackNotes
  obtain ⟨b,rfl,bMeaning⟩ := (returnNote_view targetControlNote).literal_view
  obtain ⟨a,rfl,aMeaning⟩ := (binaryRightNote_view targetStackNotes.head).literal_view
  have aSource := (binaryRightNote_view sourceStackNotes.head).literal_view
  have bSource := (returnNote_view sourceControlNote).literal_view
  obtain ⟨a₀',ha₀,ma₀⟩ := aSource
  obtain ⟨b₀',hb₀,mb₀⟩ := bSource
  cases ha₀
  cases hb₀
  have sourceRole : (Value.literal (.bin op.numOp ea eb)).Holds ν₀ C₀ identity
      (.num (.lit (F64.bin op.numOp a₀ b₀))) := .literal _ _ (literal_bin_denote ma₀ mb₀ op.numOp)
  have targetRole : (Value.literal (.bin op.numOp ea eb)).Holds ν C R
      (.num (.lit (F64.bin op.numOp a b))) := .literal _ _ (literal_bin_denote aMeaning bMeaning op.numOp)
  have support := h.stackLive
  rw [stack] at support
  refine ⟨a,b,targetFrames,?_,?_,?_,?_,targetStack⟩
  · rw [step_arithmetic_eq F s₀ op _ _ frames control stack]
    rfl
  · rw [step_arithmetic_eq F s op _ _ targetFrames targetControl targetStack]
    rfl
  · exact (h.restack tailRoles support.2).go (.node _ (.cons (.value (Value.paired sourceRole targetRole)) .nil))
      ⟨True.intro,True.intro⟩
  · exact ⟨inventory.keyLive,
      ⟨returnNote_holds sourceRole,sourceStackNotes.tail,inventory.source.cells⟩,
      ⟨returnNote_holds targetRole,targetStackNotes.tail,inventory.target.cells⟩⟩

end Host.Ts.Owned.Annotated
