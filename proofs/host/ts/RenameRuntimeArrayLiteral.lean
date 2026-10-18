import host.ts.RenameRuntimeArguments
import host.ts.RenameArrayAllocation
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def arrayLiteralFrameNote (roles : List Value) (rest : List Elem) (env : Env) : Tree :=
  .node "Frame.l" [.node "LitF.array" [valuesNote roles,.atom (List Elem) rest,environmentNote env]]

theorem arrayLiteralFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : List Value} {values : List Val}
    (rest : List Elem) (env : Env) (h : ListR (fun role value => role.Holds ν C R value) roles values) :
    (arrayLiteralFrameNote roles rest env).Holds ν C R (Encode.frame (.l (.array values rest (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (valuesNote_holds h) (.cons (.atom (List Elem) rest)
    (.cons (environmentNote_holds ν C R env) .nil)))) .nil)

theorem arrayLiteralFrameNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : List Value} {values : List Val}
    {rest : List Elem} {env : Env}
    (h : (arrayLiteralFrameNote roles rest env).Holds ν C R (Encode.frame (.l (.array values rest (R.env env))))) :
    ListR (fun role value => role.Holds ν C R value) roles values := by
  cases h with | node _ outer =>
    cases outer with | cons inner _ =>
      cases inner with | node _ fields =>
        cases fields with | cons values _ => exact valuesNote_view values

/-- The final actual literal element allocates an array whose fixed element
annotations are the accumulated operand annotations in source order. -/
theorem RuntimeInventory.array_final_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (arrays : ArrayNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (acc : List Val) (roles : List Value) (env : Env) (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .l (.array acc [] env)::frames)
    (controlNote : notes.control = returnNote role)
    (stackNotes : notes.stack = arrayLiteralFrameNote roles [] env::tailNotes)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    ∃ (targetValue : Val) (targetAcc : List Val) (targetFrames : List Frame),
      interpC (step F s₀).run C₀ = some (({s₀ with stack := frames}.alloc (valueArray (value::acc).reverse)).2.ret (.obj s₀.next),C₀) ∧
      interpC (step F s).run C = some (({s with stack := targetFrames}.alloc (valueArray (targetValue::targetAcc).reverse)).2.ret (.obj s.next),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old'
        (({s₀ with stack := frames}.alloc (valueArray (value::acc).reverse)).2.ret (.obj s₀.next))
        (({s with stack := targetFrames}.alloc (valueArray (targetValue::targetAcc).reverse)).2.ret (.obj s.next)) ∧
      RuntimeInventory {notes with control := returnNote (.obj s₀.next),stack := tailNotes} ν₀ ν C₀ C R (LiveAfter live s₀.next)
        (({s₀ with stack := frames}.alloc (valueArray (value::acc).reverse)).2.ret (.obj s₀.next))
        (({s with stack := targetFrames}.alloc (valueArray (targetValue::targetAcc).reverse)).2.ret (.obj s.next)) ∧
      ArrayInventory (arrays.write s₀.next (role::roles).reverse) ν₀ ν C₀ C R (LiveAfter live s₀.next)
        (({s₀ with stack := frames}.alloc (valueArray (value::acc).reverse)).2.ret (.obj s₀.next))
        (({s with stack := targetFrames}.alloc (valueArray (targetValue::targetAcc).reverse)).2.ret (.obj s.next)) := by
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
      (arrayLiteralFrameNote roles [] env).Holds ν₀ C₀ identity (Encode.frame (.l (.array acc [] env))) ∧
      ForestHolds ν₀ C₀ identity tailNotes (frames.map Encode.frame) := by
    cases sourceStack with | cons head tail => exact ⟨head,tail⟩
  obtain ⟨targetHead,targetTail⟩ :
      (arrayLiteralFrameNote roles [] env).Holds ν C R (Encode.frame (.l (.array targetAcc [] (R.env env)))) ∧
      ForestHolds ν C R tailNotes (targetFrames.map Encode.frame) := by
    cases targetStackRole with | cons head tail => exact ⟨head,tail⟩
  have sourceAcc := arrayLiteralFrameNote_view (ν:=ν₀) (C:=C₀) (R:=identity)
    (by simpa only [identity_environment] using sourceHead)
  have targetAccRoles := arrayLiteralFrameNote_view targetHead
  have support := h.stackLive
  rw [stack] at support
  have valueLive := (h.return_values value targetValue control targetControl).2
  have valuesLiveBefore : listSupport (valueSupport live) (value::acc) := ⟨valueLive,vals_support_of acc support.1.1.1⟩
  have valuesLive : listSupport (valueSupport live) (value::acc).reverse := listSupport_reverse valuesLiveBefore
  have popped := h.restack tailRelation support.2
  have arraysPopped : ArrayInventory arrays ν₀ ν C₀ C R live {s₀ with stack := frames} {s with stack := targetFrames} :=
    arrayInventory.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have cellsPopped : CellInventory notes.cells ν₀ ν C₀ C R live {s₀ with stack := frames} {s with stack := targetFrames} :=
    inventory.cellInventory.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have cells := cellsPopped.alloc popped.heap (valueArray (value::acc).reverse) (valueArray (targetValue::targetAcc).reverse)
    (.obj s₀.next) (.obj s.next) sourceBound targetBound
  have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  refine ⟨targetValue,targetAcc,targetFrames,?_,?_,?_,?_,?_⟩
  · rw [step_array_final_eq F s₀ value acc env frames control stack]; rfl
  · rw [step_array_final_eq F s targetValue targetAcc (R.env env) targetFrames targetControl targetStack]; rfl
  · exact popped.alloc_valueArray _ _ (values_reverse_roles (.cons valueRelation accRelation)) valuesLive prototypeLive prototypeFixed sourceBound targetBound
  · refine ⟨cells.keyLive,⟨returnNote_holds (Value.Holds.obj s₀.next),sourceTail,cells.source⟩,?_⟩
    refine ⟨?_,targetTail,cells.target⟩
    apply returnNote_holds
    simpa only [fresh] using (Value.Holds.obj (ν:=ν) (C:=C) (R:=R) s₀.next)
  · exact arraysPopped.allocate popped.heap (role::roles).reverse (value::acc).reverse (targetValue::targetAcc).reverse
      (value_roles_reverse (.cons sourceRole sourceAcc)) (value_roles_reverse (.cons targetRole targetAccRoles))
      valuesLive sourceBound targetBound
end Host.Ts.Owned.Annotated
