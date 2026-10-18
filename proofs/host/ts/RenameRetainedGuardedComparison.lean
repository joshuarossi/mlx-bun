import host.ts.RenameRetainedComparison
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Source operands are fixed by their current retained meanings. A pure
semantic guard for the target valuation establishes the same comparison;
neither a target operand nor a target execution is assumed. -/
theorem RetainedInventory.guarded_comparison_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (op : ComparisonKind) (a b : F64) (ea eb : SymE) (leftRole rightRole : Value)
    (leftNumeric : NumericRole leftRole ea) (rightNumeric : NumericRole rightRole eb)
    (frames : List Frame) (tail : List Tree)
    (control : s₀.ctl = .ret (.num (.lit b)))
    (stack : s₀.stack = .e (.binR op.jsOp (.num (.lit a)))::frames)
    (controlNote : notes.runtime.control = returnNote rightRole)
    (stackNote : notes.runtime.stack = binaryRightNote op.jsOp leftRole::tail)
    (guard : F64.test op.numOp (ea.eval ν) (eb.eval ν) = F64.test op.numOp a b) :
    ∃ targetFrames,
      let answer := op.result (F64.test op.numOp a b)
      let t₀ := {s₀ with stack := frames}.ret (.bool answer)
      let t := {s with stack := targetFrames}.ret (.bool answer)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool answer) tail))
        ν₀ ν C₀ C R live t₀ t := by
  have sourceControl := inventory.runtime.source.control
  rw [controlNote,control] at sourceControl
  have sourceStack := inventory.runtime.source.stack
  rw [stackNote,stack,List.map_cons] at sourceStack
  have leftValue : ea.eval ν₀ = a :=
    (Option.some.inj ((binaryRightNote_view sourceStack.head).numeric_denote leftNumeric)).symm
  have rightValue : eb.eval ν₀ = b :=
    (Option.some.inj ((returnNote_view sourceControl).numeric_denote rightNumeric)).symm
  exact inventory.comparison_step h op (.lit a) (.lit b) ea eb leftRole rightRole leftNumeric rightNumeric
    frames tail control stack controlNote stackNote (F64.test op.numOp a b)
    (by rw [leftValue,rightValue]) guard

end Host.Ts.Owned.Annotated
