import host.ts.RenameRuntimeArrayLiteral
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RuntimeNotes.arrayElement (notes : RuntimeNotes) (roles : List Value) (e : Expr) (rest : List Elem) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote e env,stack := arrayLiteralFrameNote roles rest env::notes.stack}

theorem RuntimeNotes.Holds.arrayElement {S : Type} {notes : RuntimeNotes} {ν : Nat → F64} {C : CSrv} {R : Ren} {s : St S}
    (h : notes.Holds ν C R s) (roles : List Value) (values : List Val) (e : Expr) (rest : List Elem) (env : Env)
    (ha : ListR (fun role value => role.Holds ν C R value) roles values) :
    (notes.arrayElement roles e rest env).Holds ν C R (Parametric.arrayElement s values e rest (R.env env)) :=
  ⟨expressionNote_holds ν C R e env,.cons (arrayLiteralFrameNote_holds rest env ha) h.stack,h.cells⟩

/-- Starting a source array literal fixes an empty operand accumulator. -/
theorem RuntimeInventory.array_entry_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (e : Expr) (rest : List Elem) (env : Env) (control : s₀.ctl = .ev (.array (.expr e::rest)) env) :
    interpC (step F s₀).run C₀ = some (Parametric.arrayElement s₀ [] e rest env,C₀) ∧
    interpC (step F s).run C = some (Parametric.arrayElement s [] e rest (R.env env),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (Parametric.arrayElement s₀ [] e rest env) (Parametric.arrayElement s [] e rest (R.env env)) ∧
    RuntimeInventory (notes.arrayElement [] e rest env) ν₀ ν C₀ C R live
      (Parametric.arrayElement s₀ [] e rest env) (Parametric.arrayElement s [] e rest (R.env env)) := by
  obtain ⟨sourceRun,targetRun,post⟩ := step_array_entry_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h e rest env control
  refine ⟨sourceRun,targetRun,post,inventory.keyLive,?_,inventory.target.arrayElement [] [] e rest env .nil⟩
  simpa only [identity_environment] using inventory.source.arrayElement [] [] e rest env .nil

/-- Every following source element retains the current operand's meaning in
the saved array accumulator before evaluating the next expression. -/
theorem RuntimeInventory.array_next_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (acc : List Val) (roles : List Value) (e : Expr) (rest : List Elem)
    (env : Env) (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .l (.array acc (.expr e::rest) env)::frames)
    (controlNote : notes.control = returnNote role)
    (stackNotes : notes.stack = arrayLiteralFrameNote roles (.expr e::rest) env::tailNotes) :
    ∃ (targetValue : Val) (targetAcc : List Val) (targetFrames : List Frame),
      interpC (step F s₀).run C₀ = some (Parametric.arrayElement {s₀ with stack := frames} (value::acc) e rest env,C₀) ∧
      interpC (step F s).run C = some (Parametric.arrayElement {s with stack := targetFrames} (targetValue::targetAcc) e rest (R.env env),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (Parametric.arrayElement {s₀ with stack := frames} (value::acc) e rest env)
        (Parametric.arrayElement {s with stack := targetFrames} (targetValue::targetAcc) e rest (R.env env)) ∧
      RuntimeInventory ({notes with stack := tailNotes}.arrayElement (role::roles) e rest env) ν₀ ν C₀ C R live
        (Parametric.arrayElement {s₀ with stack := frames} (value::acc) e rest env)
        (Parametric.arrayElement {s with stack := targetFrames} (targetValue::targetAcc) e rest (R.env env)) := by
  obtain ⟨targetValue,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨targetAcc,frameEq,accRelation⟩ := frameRelation.arrayLiteral_view
  rw [frameEq] at targetStack
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceRole := returnNote_view sourceControl
  have targetRole := returnNote_view targetControlRole
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  obtain ⟨sourceHead,sourceTail⟩ :
      (arrayLiteralFrameNote roles (.expr e::rest) env).Holds ν₀ C₀ identity (Encode.frame (.l (.array acc (.expr e::rest) env))) ∧
      ForestHolds ν₀ C₀ identity tailNotes (frames.map Encode.frame) := by
    cases sourceStack with | cons head tail => exact ⟨head,tail⟩
  obtain ⟨targetHead,targetTail⟩ :
      (arrayLiteralFrameNote roles (.expr e::rest) env).Holds ν C R (Encode.frame (.l (.array targetAcc (.expr e::rest) (R.env env)))) ∧
      ForestHolds ν C R tailNotes (targetFrames.map Encode.frame) := by
    cases targetStackRole with | cons head tail => exact ⟨head,tail⟩
  have sourceAcc := arrayLiteralFrameNote_view (ν:=ν₀) (C:=C₀) (R:=identity)
    (by simpa only [identity_environment] using sourceHead)
  have targetAccRoles := arrayLiteralFrameNote_view targetHead
  have support := h.stackLive
  rw [stack] at support
  have valueLive := (h.return_values value targetValue control targetControl).2
  refine ⟨targetValue,targetAcc,targetFrames,?_,?_,?_,inventory.keyLive,?_,?_⟩
  · rw [step_array_next_eq F s₀ value acc e rest env frames control stack]; rfl
  · rw [step_array_next_eq F s targetValue targetAcc e rest (R.env env) targetFrames targetControl targetStack]; rfl
  · exact arrayElement_roles (h.restack tailRelation support.2) (value::acc) (targetValue::targetAcc) e rest env
      (.cons valueRelation accRelation) ⟨valueLive,vals_support_of acc support.1.1.1⟩ support.1.1.2.2.1
  · have popped : ({notes with stack := tailNotes}).Holds ν₀ C₀ identity {s₀ with stack := frames} :=
      ⟨inventory.source.control,sourceTail,inventory.source.cells⟩
    simpa only [identity_environment] using popped.arrayElement (role::roles) (value::acc) e rest env (.cons sourceRole sourceAcc)
  · have popped : ({notes with stack := tailNotes}).Holds ν C R {s with stack := targetFrames} :=
      ⟨inventory.target.control,targetTail,inventory.target.cells⟩
    exact popped.arrayElement (role::roles) (targetValue::targetAcc) e rest env (.cons targetRole targetAccRoles)
end Host.Ts.Owned.Annotated
