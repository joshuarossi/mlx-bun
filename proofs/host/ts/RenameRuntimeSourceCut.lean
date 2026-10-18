import host.ts.RenameRuntimeArithmetic
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Arithmetic uses the serialized numeric table and consumes no comparison
answers. Its checked source certificate therefore carries no unused oracle. -/
def numberServer (S : SSrv) : SSrv := {S with oracle := []}

theorem numberServer_inst (ν : Nat → F64) (S : SSrv) (C : CSrv)
    (table : C.tab = S.tab.map (SymE.eval ν)) : Inst ν (numberServer S) C :=
  ⟨table,by intro query impossible; cases impossible⟩

inductive NumericRole : Value → SymE → Prop where
  | number (e : SymE) : NumericRole (.num e) e
  | literal (e : SymE) : NumericRole (.literal e) e

theorem Value.Holds.numeric_denote {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {e : SymE} {n : NumV}
    (h : role.Holds ν C R (.num n)) (numeric : NumericRole role e) : NumDenote ν C e n := by
  cases numeric with
  | number e => exact h.num_denote
  | literal e => cases h with | literal _ _ denotation => exact denotation

/-- Arithmetic consumes the meanings fixed in the control and saved operand
notes. The result records their symbolic operation and extends each number
server independently. -/
theorem RuntimeInventory.numeric_arithmetic_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (op : ArithmeticKind) (a₀ b₀ : NumV) (ea eb : SymE) (leftRole rightRole : Value)
    (leftNumeric : NumericRole leftRole ea) (rightNumeric : NumericRole rightRole eb) (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (.num b₀))
    (stack : s₀.stack = .e (.binR op.jsOp (.num a₀))::frames)
    (controlNote : notes.control = returnNote rightRole)
    (stackNote : notes.stack = binaryRightNote op.jsOp leftRole::tailNotes) :
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
    ⟨(binaryRightNote_view sourceStackNotes.head).numeric_denote leftNumeric,
     (binaryRightNote_view targetStackNotes.head).numeric_denote leftNumeric⟩
  have bRole : NumRole ν₀ ν C₀ C eb b₀ b :=
    ⟨(returnNote_view sourceControlNote).numeric_denote rightNumeric,(returnNote_view targetControlNote).numeric_denote rightNumeric⟩
  obtain ⟨v₀,D₀,v,D,left,right,resultRole,related,leftExt,rightExt⟩ :=
    step_arithmetic_roles F FR R ν₀ ν C₀ C live framed before after old old' s₀ s h
      op a₀ a b₀ b ea eb frames targetFrames aRole bRole control targetControl stack targetStack
  refine ⟨v₀,D₀,v,D,targetFrames,left,right,related,?_,leftExt,rightExt⟩
  refine ⟨inventory.keyLive,?_,?_⟩
  · exact ⟨returnNote_holds (.num _ _ resultRole.left),
      sourceStackNotes.tail.mono leftExt,inventory.source.cells.mono leftExt⟩
  · exact ⟨returnNote_holds (.num _ _ resultRole.right),
      targetStackNotes.tail.mono rightExt,inventory.target.cells.mono rightExt⟩


/-- A checked symbolic source step fixes its concrete endpoint and source
number table. Target arithmetic remains independently represented and allocated. -/
theorem RuntimeInventory.arithmetic_cut (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ t₀ s : St F.S)
    (S₀ S₁ : SSrv) (sourceStep : interpS (step F s₀).run S₀ = some (t₀,S₁))
    (inst : Inst ν₀ S₀ C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (op : ArithmeticKind) (a₀ b₀ : NumV) (ea eb : SymE) (leftRole rightRole : Value)
    (leftNumeric : NumericRole leftRole ea) (rightNumeric : NumericRole rightRole eb)
    (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (.num b₀))
    (stack : s₀.stack = .e (.binR op.jsOp (.num a₀))::frames)
    (controlNote : notes.control = returnNote rightRole)
    (stackNote : notes.stack = binaryRightNote op.jsOp leftRole::tailNotes) :
    ∃ result D₀ D,
      interpC (step F s₀).run C₀ = some (t₀,D₀) ∧ interpC (step F s).run C = some (result,D) ∧
      Inst ν₀ S₁ D₀ ∧
      Parametric.StateR (NumberRoles ν₀ ν D₀ D) FR R live framed before after old old' t₀ result ∧
      RuntimeInventory (notes.binaryResult (.num (.bin op.numOp ea eb)) tailNotes) ν₀ ν D₀ D R live t₀ result ∧
      TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨expectedD,sourceRun,expectedInst⟩ := interp_sim ν₀ (step F s₀).run S₀ C₀ t₀ S₁ inst sourceStep
  obtain ⟨v₀,D₀,v,D,targetFrames,left,right,related,annotated,leftExt,rightExt⟩ := inventory.numeric_arithmetic_step F FR
    notes ν₀ ν C₀ C R live framed before after old old' s₀ s h op a₀ b₀ ea eb leftRole rightRole leftNumeric rightNumeric
    frames tailNotes control stack controlNote stackNote
  have both := Option.some.inj (left.symm.trans sourceRun)
  have state := congrArg Prod.fst both
  have table := congrArg Prod.snd both
  dsimp only at state table
  cases table
  rw [state] at related annotated
  exact ⟨_,expectedD,D,sourceRun,right,expectedInst,related,annotated,leftExt,rightExt⟩

end Host.Ts.Owned.Annotated
