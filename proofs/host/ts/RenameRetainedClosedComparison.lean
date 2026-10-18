import host.ts.RenameRetainedComparison
set_option Elab.async false
namespace Host.Ts

/-- Variable-free arithmetic keeps its full floating-point expression. This
test does not identify occurrences by their evaluated bits. -/
def SymE.closed : SymE → Bool
  | .lit _ => true
  | .var _ => false
  | .bin _ a b => a.closed && b.closed
  | .un _ a => a.closed

theorem SymE.eval_closed (e : SymE) (closed : e.closed = true) (ν μ : Nat → F64) : e.eval ν = e.eval μ := by
  induction e with
  | lit x => rfl
  | var i => cases closed
  | bin op a b left right =>
    obtain ⟨ha,hb⟩ := Bool.and_eq_true_iff.mp closed
    simp only [SymE.eval,left ha,right hb]
  | un op a ih => simp only [SymE.eval,ih closed]

end Host.Ts
namespace Host.Ts.Owned.Annotated
open Parametric

/-- A fixed loop comparison needs no independent target guard. Its current
literal operand notes retain variable-free expressions, so their evaluations
agree in both valuations. Source literal values fix the actual answer. -/
theorem RetainedInventory.closed_literal_comparison_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (op : ComparisonKind) (a b : F64) (ea eb : SymE) (frames : List Frame) (tail : List Tree)
    (control : s₀.ctl = .ret (.num (.lit b)))
    (stack : s₀.stack = .e (.binR op.jsOp (.num (.lit a)))::frames)
    (controlNote : notes.runtime.control = returnNote (.literal eb))
    (stackNote : notes.runtime.stack = binaryRightNote op.jsOp (.literal ea)::tail)
    (leftClosed : ea.closed = true) (rightClosed : eb.closed = true) :
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
  have ha : ea.eval ν₀ = a := (Option.some.inj ((binaryRightNote_view sourceStack.head).numeric_denote (.literal ea))).symm
  have hb : eb.eval ν₀ = b := (Option.some.inj ((returnNote_view sourceControl).numeric_denote (.literal eb))).symm
  exact inventory.comparison_step h op (.lit a) (.lit b) ea eb (.literal ea) (.literal eb)
    (.literal ea) (.literal eb) frames tail control stack controlNote stackNote (F64.test op.numOp a b)
    (by rw [ha,hb]) (by rw [ea.eval_closed leftClosed ν ν₀,eb.eval_closed rightClosed ν ν₀,ha,hb])
end Host.Ts.Owned.Annotated
