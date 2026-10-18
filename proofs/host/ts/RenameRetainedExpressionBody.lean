import host.ts.RenameParametricExpressionBody
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeDispatch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def expressionReturnNote : Tree := .node "Frame.s" [.node "StmtF.ret" []]
theorem expressionReturnNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) :
    expressionReturnNote.Holds ν C R (Encode.frame (.s .ret)) := by repeat constructor

/-- Completing the actual synchronous expression-body parameter frame
evaluates that expression with its captured environment and original return
continuation. Every retained heap meaning survives unchanged. -/
theorem RetainedInventory.parameter_expression_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : Val) (name : Option Name) (params : List Pat) (expression : Expr) (args : List Val) (env : Env)
    (frames : List Frame) (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .k (.params (.mk name params none (.expr expression) false false []) [] args env)::frames)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := expressionBodyState s₀ expression env frames
      let t := expressionBodyState s expression (R.env env) targetFrames
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨expressionNote expression env,expressionReturnNote::tail,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨targetArgs,frameEq,_⟩ := frameRelation.params_view
  rw [frameEq] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have sourceStack := inventory.runtime.source.stack
  have targetStackNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
  have frameRole : Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R (.s .ret) (.s .ret) :=
    .node _ (.cons (.node _ .nil) .nil)
  have post := (h.restack (.cons frameRole tailRelation) ⟨⟨True.intro,True.intro⟩,support.2⟩).go
    (c := .ev expression env) (c' := .ev expression (R.env env))
    (.node _ (.cons (.atom _ _) (.cons (env_roles _ R env) .nil))) ⟨True.intro,support.1.1.2.2.2.1,True.intro⟩
  have runtime : RuntimeInventory ⟨expressionNote expression env,expressionReturnNote::tail,notes.runtime.cells⟩
      ν₀ ν C₀ C R live (expressionBodyState s₀ expression env frames)
      (expressionBodyState s expression (R.env env) targetFrames) :=
    ⟨inventory.runtime.keyLive,
      ⟨expressionNote_source ν₀ C₀ expression env,.cons (expressionReturnNote_holds ν₀ C₀ identity) sourceStack.tail,
        inventory.runtime.source.cells⟩,
      ⟨expressionNote_holds ν C R expression env,.cons (expressionReturnNote_holds ν C R) targetStackNotes.tail,
        inventory.runtime.target.cells⟩⟩
  refine ⟨targetFrames,?_,?_,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
  · rw [step_parameter_expression_eq F s₀ value name params expression args env frames control stack]; rfl
  · rw [step_parameter_expression_eq F s targetValue name params expression targetArgs (R.env env) targetFrames targetControl targetStack]; rfl
end Host.Ts.Owned.Annotated
