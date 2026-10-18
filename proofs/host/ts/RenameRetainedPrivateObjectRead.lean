import host.ts.RenameRuntimeStaticRead
import host.ts.RenameRouteComposition

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Object-valued private fields have an address role forced by the current
heap relation. Reading the constructor's token therefore retains the owner's
independent handle note; it cannot replace that note or reinterpret bigint
contents as an object/native handle. -/
theorem RetainedInventory.private_object_read_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (owner brand resultAddress : Nat) (field : Name) (w e : Bool) (object : Obj)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : source.ctl = .ret (.obj owner)) (stack : source.stack = .e (.priv brand field false)::frames)
    (read : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (descriptor : findPriv brand field object.priv = some (.data (.obj resultAddress) w e))
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      interpC (step F source).run C₀ = some ({source with stack := frames}.ret (.obj resultAddress),C₀) ∧
      interpC (step F target).run C = some ({target with stack := targetFrames}.ret (.obj (R.a resultAddress)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({source with stack := frames}.ret (.obj resultAddress)) ({target with stack := targetFrames}.ret (.obj (R.a resultAddress))) ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj resultAddress), stack := tail})
        ν₀ ν C₀ C R live ({source with stack := frames}.ret (.obj resultAddress))
        ({target with stack := targetFrames}.ret (.obj (R.a resultAddress))) := by
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRole,_⟩ := h.stack_view stack
  rw [frameRole.private_view] at targetStack
  have alive : live owner := by
    have support := h.controlLive
    rw [control] at support
    exact support.1
  have stackLive := h.stackLive
  rw [stack] at stackLive
  have brandLive : live brand := stackLive.1.1.1
  obtain ⟨property,left,right,post,propertyRole⟩ := step_private_read_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' source target h owner brand field object (.data (.obj resultAddress) w e) frames targetFrames
    control targetControl stack targetStack alive brandLive read ordinary descriptor
  obtain ⟨targetValue,rfl,valueRole⟩ := propertyRole.data
  cases valueRole
  have sourceStack := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have runtime : RuntimeInventory {notes.runtime with control := returnNote (.obj resultAddress), stack := tail}
      ν₀ ν C₀ C R live ({source with stack := frames}.ret (.obj resultAddress))
      ({target with stack := targetFrames}.ret (.obj (R.a resultAddress))) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (Value.Holds.obj resultAddress),sourceStack.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (Value.Holds.obj resultAddress),targetNotes.tail,inventory.runtime.target.cells⟩⟩
  exact ⟨targetFrames,left,right,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

private theorem object_read_one (F : Ffi) (source target : St F.S) (C : CSrv)
    (active : isHalt source.ctl = false) (execution : interpC (step F source).run C = some (target,C)) :
    runC F 1 source C = some (target,C) := runC_cons F 0 source target target C C C active execution rfl

/-- Object-valued `this.#field`, including the original receiver evaluation.
The owning handle annotation remains available after the token read. -/
theorem RetainedInventory.this_private_object_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (thisCell owner brand token : Nat) (name : Name) (object : Obj) (w e : Bool)
    (control : source.ctl = .ev (.priv .this name false) env)
    (thisLookup : lookupEnv nThis env = some thisCell) (brandLookup : lookupEnv (privName name) env = some brand)
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (descriptor : findPriv brand name object.priv = some (.data (.obj token) w e))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner)) :
    ∃ result,
      runC F 3 source C₀ = some (source.ret (.obj token),C₀) ∧
      runC F 3 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (source.ret (.obj token)) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.returning (.obj token))) ν₀ ν C₀ C R live
        (source.ret (.obj token)) result ∧ result.heap = target.heap ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨left1,right1,h1,runtime1⟩ := inventory.runtime.private_descent_step F FR notes.runtime ν₀ ν C₀ C R live framed
    before after old old' source target h .this brand name false env control brandLookup
  have inv1 := inventory.heap_step runtime1 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨_,left2,right2,h2,runtime2⟩ := runtime1.this_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 env thisCell (.obj owner) (.obj owner) rfl thisLookup thisRead thisNote
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨_,left3,right3,h3,inv3⟩ := inv2.private_object_read_step h2 owner brand token name w e object source.stack
    (privateReadFrameNote brand name false) notes.runtime.stack rfl rfl objectRead ordinary descriptor rfl
  have l1 := object_read_one F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := object_read_one F _ _ C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have l2 := object_read_one F _ _ C₀ rfl left2
  have r2 := object_read_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have l3 := object_read_one F _ _ C₀ rfl left3
  have r3 := object_read_one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  exact ⟨_,runC_join F (runC_join F l1 l2) l3,runC_join F (runC_join F r1 r2) r3,h3,inv3,rfl,rfl,rfl⟩

end Host.Ts.Owned.Annotated
