import host.ts.RenameRuntimeArrayIndex
import host.ts.RenameRetainedClosedComparison
import host.ts.RenameRetainedHeapFrame
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def indexRightFrameNote (role : Value) : Tree := .node "Frame.e" [.node "ExprF.indexR" [.value role]]
theorem indexRightFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (holds : role.Holds ν C R value) :
    (indexRightFrameNote role).Holds ν C R (Encode.frame (.e (.indexR value))) :=
  .node _ (.cons (.node _ (.cons (.value holds) .nil)) .nil)

/-- Save the existing receiver occurrence while evaluating the original
computed key. Its meaning is taken only from the current return note. -/
theorem RetainedInventory.index_left_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (receiver : Val) (role : Value) (key : Expr) (env : Env) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret receiver) (stack : s₀.stack = .e (.indexL key env false)::frames)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetReceiver targetFrames,
      let t₀ := ({s₀ with stack := frames}.push (.e (.indexR receiver))).go (.ev key env)
      let t := ({s with stack := targetFrames}.push (.e (.indexR targetReceiver))).go (.ev key (R.env env))
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime
        ⟨expressionNote key env,indexRightFrameNote role::tail,notes.runtime.cells⟩) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetReceiver,targetControl,receiverRelation⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.indexLeft_view] at targetStack
  have sourceRole := inventory.runtime.source.control
  have targetRole := inventory.runtime.target.control
  rw [controlNote,control] at sourceRole
  rw [controlNote,targetControl] at targetRole
  have sourceStack := inventory.runtime.source.stack
  have targetStackNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
  have support := h.stackLive
  rw [stack] at support
  have receiverLive := (h.return_values receiver targetReceiver control targetControl).2
  have frameRole : Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R (.e (.indexR receiver)) (.e (.indexR targetReceiver)) :=
    Tree.paired (indexRightFrameNote_holds (returnNote_view sourceRole)) (indexRightFrameNote_holds (returnNote_view targetRole))
  have frameLive : treeSupport live (Encode.frame (.e (.indexR receiver))) := ⟨⟨receiverLive,True.intro⟩,True.intro⟩
  have post := (h.restack (.cons frameRole tailRelation) ⟨frameLive,support.2⟩).go
    (c := .ev key env) (c' := .ev key (R.env env))
    (.node _ (.cons (.atom _ _) (.cons (env_roles _ R env) .nil))) ⟨True.intro,support.1.1.2.1,True.intro⟩
  have runtime : RuntimeInventory ⟨expressionNote key env,indexRightFrameNote role::tail,notes.runtime.cells⟩
      ν₀ ν C₀ C R live (({s₀ with stack := frames}.push (.e (.indexR receiver))).go (.ev key env))
      (({s with stack := targetFrames}.push (.e (.indexR targetReceiver))).go (.ev key (R.env env))) :=
    ⟨inventory.runtime.keyLive,
      ⟨expressionNote_source ν₀ C₀ key env,.cons (indexRightFrameNote_holds (returnNote_view sourceRole)) sourceStack.tail,
        inventory.runtime.source.cells⟩,
      ⟨expressionNote_holds ν C R key env,.cons (indexRightFrameNote_holds (returnNote_view targetRole)) targetStackNotes.tail,
        inventory.runtime.target.cells⟩⟩
  refine ⟨targetReceiver,targetFrames,?_,?_,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
  · rw [step_index_left_eq F s₀ receiver key env frames control stack]; rfl
  · rw [step_index_left_eq F s targetReceiver key (R.env env) targetFrames targetControl targetStack]; rfl

/-- A fixed computed index is proved from its retained closed expression.
The current array inventory supplies the selected element's fixed meaning. -/
theorem RetainedInventory.closed_array_index_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a i : Nat) (roles : List Value) (role : Value) (meaning : SymE) (key : F64)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (entry : notes.arrays.owners a = some roles) (element : nth? roles i = some role)
    (control : s₀.ctl = .ret (.num (.lit key))) (stack : s₀.stack = .e (.indexR (.obj a))::frames)
    (index : numIndex (.num (.lit key)) = some i) (closed : meaning.closed = true)
    (controlNote : notes.runtime.control = returnNote (.literal meaning)) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ value targetValue targetFrames,
      let t₀ := {s₀ with stack := frames}.ret value
      let t := {s with stack := targetFrames}.ret targetValue
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,tail,notes.runtime.cells⟩) ν₀ ν C₀ C R live t₀ t := by
  have sourceRole := inventory.runtime.source.control
  rw [controlNote,control] at sourceRole
  have sourceValue : meaning.eval ν₀ = key :=
    (Option.some.inj ((returnNote_view sourceRole).numeric_denote (.literal meaning))).symm
  have targetIndex : numIndex (.num (.lit (meaning.eval ν))) = some i := by
    rw [meaning.eval_closed closed ν ν₀,sourceValue]
    exact index
  obtain ⟨value,targetValue,targetFrames,left,right,post,runtime,_⟩ := inventory.runtime.array_index_step F FR
    notes.runtime notes.arrays ν₀ ν C₀ C R live framed before after old old' s₀ s h inventory.arrays
    a i roles role meaning (.num (.lit key)) frames head tail entry element control stack index targetIndex controlNote stackNotes
  exact ⟨value,targetValue,targetFrames,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
