import host.ts.RenameRetainedPrivateNext

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem RetainedInventory.field_frame_pop {S : Type} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (sourceHead targetHead : Frame) (sourceTail targetTail : List Frame) (head : Tree) (tail : List Tree)
    (sourceStack : s₀.stack = sourceHead::sourceTail) (targetStack : s.stack = targetHead::targetTail)
    (stackNotes : notes.runtime.stack = head::tail) :
    RetainedInventory (notes.withRuntime {notes.runtime with stack := tail}) ν₀ ν C₀ C R live
      {s₀ with stack := sourceTail} {s with stack := targetTail} := by
  have source := inventory.runtime.source.stack
  have target := inventory.runtime.target.stack
  rw [stackNotes,sourceStack,List.map_cons] at source
  rw [stackNotes,targetStack,List.map_cons] at target
  have runtime : RuntimeInventory {notes.runtime with stack := tail} ν₀ ν C₀ C R live
      {s₀ with stack := sourceTail} {s with stack := targetTail} :=
    ⟨inventory.runtime.keyLive,⟨inventory.runtime.source.control,source.tail,inventory.runtime.source.cells⟩,
      ⟨inventory.runtime.target.control,target.tail,inventory.runtime.target.cells⟩⟩
  exact inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)

def RetainedNotes.privateFields (notes : RetainedNotes) (owner brand : Nat) (name : Name) (role : Value)
    (tail : List Tree) (next : PrivateNext) (env : Env) : RetainedNotes :=
  ((notes.withRuntime {notes.runtime with stack := tail}).privateInitialized owner brand name role).withRuntime
    ({notes.runtime with stack := tail}.privateNext next owner env)

/-- An original private initializer consumes its current retained return role,
defines that field, and schedules the next source initializer or constructor
body. The saved constructor argument notes remain unchanged in the tail. -/
theorem RetainedInventory.private_initializer_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (owner brand : Nat) (name : Name) (object : Obj) (next : PrivateNext) (env : Env) (frames₀ : List Frame)
    (role : Value) (head : Tree) (tail : List Tree) (valid : next.valid)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .k (.privVal owner brand name next.members env)::frames₀)
    (read : s₀.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ (targetValue : Val) (targetObject : Obj) (frames : List Frame),
      let source := next.advance ({s₀ with stack := frames₀}.setObj owner
        {object with priv := setPrivL brand name (.data value true false) object.priv}) owner env
      let target := (next.map R).advance ({s with stack := frames}.setObj (R.a owner)
        {targetObject with priv := setPrivL (R.a brand) name (.data targetValue true false) targetObject.priv}) (R.a owner) (R.env env)
      interpC (step F s₀).run C₀ = some (source,C₀) ∧ interpC (step F s).run C = some (target,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target ∧
      RetainedInventory (notes.privateFields owner brand name role tail next env) ν₀ ν C₀ C R live source target := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,frames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨members,frameEq,memberRoles⟩ := frameRelation.privateInitializer_view
  rw [frameEq] at targetStack
  have mapped : members = (next.map R).members :=
    (privateFields_target (next.onlyPrivate valid) memberRoles).trans (next.members_map R).symm
  rw [mapped] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have ownerLive : live owner := support.1.1.1
  have brandLive : live brand := support.1.1.2.1
  obtain ⟨targetObject,targetRead,_,_⟩ := h.heap.readOrdinary owner object ownerLive read ordinary
  have left : interpC (step F s₀).run C₀ = some
      (next.advance ({s₀ with stack := frames₀}.setObj owner
        {object with priv := setPrivL brand name (.data value true false) object.priv}) owner env,C₀) := by
    rw [step_private_initializer_eq F s₀ owner brand name next.members env frames₀ object value control stack read,
      next.advance_eq]; rfl
  have right : interpC (step F s).run C = some
      ((next.map R).advance ({s with stack := frames}.setObj (R.a owner)
        {targetObject with priv := setPrivL (R.a brand) name (.data targetValue true false) targetObject.priv}) (R.a owner) (R.env env),C) := by
    rw [step_private_initializer_eq F s (R.a owner) (R.a brand) name (next.map R).members (R.env env)
      frames targetObject targetValue targetControl targetStack targetRead,(next.map R).advance_eq]; rfl
  obtain ⟨_,sourcePost,targetPost,_,sourceRun,targetRun,post,_,_⟩ := step_private_initializer_from_source F
    (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s₀ s h value owner brand name object
    next.members env frames₀ control stack (next.onlyPrivate valid) read ordinary sourceBound targetBound
  have sourceEq := congrArg Prod.fst (Option.some.inj (sourceRun.symm.trans left))
  have targetEq := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans right))
  dsimp only at sourceEq targetEq
  rw [sourceEq,targetEq] at post
  have sourceMeaning := inventory.runtime.source.control
  have targetMeaning := inventory.runtime.target.control
  rw [controlNote,control] at sourceMeaning
  rw [controlNote,targetControl] at targetMeaning
  have popped := inventory.field_frame_pop _ _ frames₀ frames head tail stack targetStack stackNotes
  have poppedHeap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after
      {s₀ with stack := frames₀} {s with stack := frames} :=
    ⟨h.heap.lookup,h.heap.sourceBound,h.heap.targetBound,h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩
  have defined := popped.initialize_private poppedHeap owner brand name role value targetValue object targetObject ownerLive brandLive
    read targetRead ordinary (returnNote_view sourceMeaning) (returnNote_view targetMeaning)
    (Nat.lt_of_lt_of_le (h.heap.sourceBound owner ownerLive) sourceBound)
    (Nat.lt_of_lt_of_le (h.heap.targetBound owner ownerLive) targetBound)
  exact ⟨targetValue,targetObject,frames,left,right,post,defined.private_next next valid owner env⟩

/-- The first source field without an initializer is defined as undefined
before the next actual initializer is scheduled. Its role comes from the
language rule; no return-operand or future private-field role is assumed. -/
theorem RetainedInventory.private_fields_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (owner brand : Nat) (name : Name) (object : Obj) (next : PrivateNext) (env : Env) (frames₀ : List Frame)
    (head : Tree) (tail : List Tree) (valid : next.valid)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .k (.fields owner (.privField brand name none::next.members) env)::frames₀)
    (read : s₀.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (stackNotes : notes.runtime.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ (targetObject : Obj) (frames : List Frame),
      let source := next.advance ({s₀ with stack := frames₀}.setObj owner
        {object with priv := setPrivL brand name (.data .undef true false) object.priv}) owner env
      let target := (next.map R).advance ({s with stack := frames}.setObj (R.a owner)
        {targetObject with priv := setPrivL (R.a brand) name (.data .undef true false) targetObject.priv}) (R.a owner) (R.env env)
      interpC (step F s₀).run C₀ = some (source,C₀) ∧ interpC (step F s).run C = some (target,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target ∧
      RetainedInventory (notes.privateFields owner brand name .undef tail next env) ν₀ ν C₀ C R live source target := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,frames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨members,frameEq,memberRoles⟩ := frameRelation.fields_view
  rw [frameEq] at targetStack
  have onlyPrivate := PrivateFields.cons brand name none (next.onlyPrivate valid)
  have mapped : members = .privField (R.a brand) name none::(next.map R).members := by
    rw [privateFields_target onlyPrivate memberRoles]
    rw [List.map_cons,← next.members_map R]
    rfl
  rw [mapped] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have ownerLive : live owner := support.1.1.1
  have brandLive : live brand := support.1.1.2.1.1.1
  obtain ⟨targetObject,targetRead,_,_⟩ := h.heap.readOrdinary owner object ownerLive read ordinary
  have left : interpC (step F s₀).run C₀ = some
      (next.advance ({s₀ with stack := frames₀}.setObj owner
        {object with priv := setPrivL brand name (.data .undef true false) object.priv}) owner env,C₀) := by
    rw [step_class_fields_eq F s₀ value owner _ env frames₀ control stack]
    simp only [fieldsNext,St.obj?,read]
    rw [next.advance_eq]; rfl
  have right : interpC (step F s).run C = some
      ((next.map R).advance ({s with stack := frames}.setObj (R.a owner)
        {targetObject with priv := setPrivL (R.a brand) name (.data .undef true false) targetObject.priv}) (R.a owner) (R.env env),C) := by
    rw [step_class_fields_eq F s targetValue (R.a owner) _ (R.env env) frames targetControl targetStack]
    simp only [fieldsNext,St.obj?,targetRead]
    rw [(next.map R).advance_eq]; rfl
  obtain ⟨sourcePost,targetPost,sourceRun,targetRun,post,_,_⟩ := step_class_fields_from_source F
    (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s₀ s h value owner object
    (.privField brand name none::next.members) env frames₀ control stack onlyPrivate read ordinary sourceBound targetBound
  have sourceEq := congrArg Prod.fst (Option.some.inj (sourceRun.symm.trans left))
  have targetEq := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans right))
  dsimp only at sourceEq targetEq
  rw [sourceEq,targetEq] at post
  have popped := inventory.field_frame_pop _ _ frames₀ frames head tail stack targetStack stackNotes
  have poppedHeap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after
      {s₀ with stack := frames₀} {s with stack := frames} :=
    ⟨h.heap.lookup,h.heap.sourceBound,h.heap.targetBound,h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩
  have defined := popped.initialize_private poppedHeap owner brand name .undef .undef .undef object targetObject ownerLive brandLive
    read targetRead ordinary .undef .undef
    (Nat.lt_of_lt_of_le (h.heap.sourceBound owner ownerLive) sourceBound)
    (Nat.lt_of_lt_of_le (h.heap.targetBound owner ownerLive) targetBound)
  exact ⟨targetObject,frames,left,right,post,defined.private_next next valid owner env⟩

end Host.Ts.Owned.Annotated
