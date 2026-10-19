import host.ts.RenameCstrCachedData

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def cstrBodyNotes (notes : RetainedNotes) (localCell buffer : Nat) (callerNotes : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.obj buffer),callerNotes,notes.runtime.cells.write localCell (.obj buffer)⟩

/-- The complete cached body preserves every annotation family, writes the
real local variable and returns to an arbitrary caller in 25 source steps.
All target lexical, map, method and buffer facts follow from current ownership. -/
theorem RetainedInventory.cstr_cached_body
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (env : Env) (caller targetCaller : List Frame) (key : Name) (localCell buffer : Nat)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live
      (cstrBodyState source env caller) (cstrBodyState target (R.env env) targetCaller))
    (relation : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (cstrBodyState source env caller) (cstrBodyState target (R.env env) targetCaller))
    (current : CstrCachedData source env key localCell buffer)
    (blockNote scopeNote callNote : Tree) (callerNotes : List Tree)
    (stackNotes : notes.runtime.stack = blockNote::scopeNote::callNote::callerNotes)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    runC F 25 (cstrBodyState source env caller) C₀ = some (cstrBodyResult source localCell buffer caller,C₀) ∧
    runC F 25 (cstrBodyState target (R.env env) targetCaller) C =
      some (cstrBodyResult target (R.a localCell) (R.a buffer) targetCaller,C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (cstrBodyResult source localCell buffer caller) (cstrBodyResult target (R.a localCell) (R.a buffer) targetCaller) ∧
    RetainedInventory (cstrBodyNotes notes localCell buffer callerNotes) ν₀ ν C₀ C R live
      (cstrBodyResult source localCell buffer caller) (cstrBodyResult target (R.a localCell) (R.a buffer) targetCaller) := by
  have environmentLive : treeSupport live (Encode.env env) := relation.stackLive.1.1.2.1
  have heapRelation : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after source target :=
    ⟨relation.heap.lookup,relation.heap.sourceBound,relation.heap.targetBound,relation.heap.prefixLive,
      relation.heap.inj,relation.heap.fresh⟩
  obtain ⟨localLive,bufferLive,⟨mapped⟩⟩ :=
    current.transport heapRelation environmentLive
  have leftBound : localCell < 2^64 := Nat.lt_of_lt_of_le (relation.heap.sourceBound localCell localLive) sourceBound
  have rightBound : R.a localCell < 2^64 := Nat.lt_of_lt_of_le (relation.heap.targetBound localCell localLive) targetBound
  have callers : ListR (Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R) caller targetCaller := by
    have frames := relation.stack
    cases frames with | cons _ tail => cases tail with | cons _ tail => cases tail with | cons _ tail => exact tail
  have callerLive : listSupport (fun frame => treeSupport live (Encode.frame frame)) caller := relation.stackLive.2.2.2
  have stored := relation.setCell localCell (.obj buffer) (.obj (R.a buffer)) localLive
    (relation.heap.cell_notFramed localCell none localLive current.localRead) (.obj buffer) bufferLive leftBound rightBound
  have post := (stored.restack callers callerLive).go
    (c:=.ret (.obj buffer)) (c':=.ret (.obj (R.a buffer)))
    (.node _ (.cons (.value (.obj buffer)) .nil)) ⟨bufferLive,True.intro⟩
  have heap := inventory.heapInventory.setCell relation.heap localCell none (.obj buffer)
    (.obj buffer) (.obj (R.a buffer)) localLive current.localRead (.obj buffer) (.obj buffer) leftBound rightBound
  have sourceStack := inventory.runtime.source.stack
  have targetStack := inventory.runtime.target.stack
  rw [stackNotes] at sourceStack targetStack
  have runtime : RuntimeInventory (cstrBodyNotes notes localCell buffer callerNotes).runtime ν₀ ν C₀ C R live
      (cstrBodyResult source localCell buffer caller) (cstrBodyResult target (R.a localCell) (R.a buffer) targetCaller) :=
    ⟨heap.cells.keyLive,
      ⟨returnNote_holds (.obj buffer),sourceStack.tail.tail.tail,heap.cells.source⟩,
      ⟨returnNote_holds (.obj buffer),targetStack.tail.tail.tail,heap.cells.target⟩⟩
  refine ⟨current.execution C₀ caller leftBound,mapped.execution C targetCaller rightBound,post,
    runtime,?_,?_,?_,?_,?_⟩
  · exact heap.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact heap.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact (inventory.arrays.setCell relation.heap localCell none (.obj buffer) (.obj (R.a buffer)) localLive
      current.localRead leftBound rightBound).frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact (inventory.publicFields.setCell relation.heap localCell none (.obj buffer) (.obj (R.a buffer)) localLive
      current.localRead leftBound rightBound).frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
  · exact (inventory.buffers.setCell relation.heap localCell none (.obj buffer) (.obj (R.a buffer)) localLive
      current.localRead leftBound rightBound).frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

/-- The original source boundary determines the target body and caller shape;
callers of this rule provide no independently assumed target continuation. -/
theorem RetainedInventory.cstr_cached_body_from_source
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (relation : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (caller : List Frame) (key : Name) (localCell buffer : Nat)
    (current : CstrCachedData source env key localCell buffer)
    (control : source.ctl = .ret .undef)
    (stack : source.stack = .s (.block cstrStatements env)::.s (.scope [])::.k (.fn .call)::caller)
    (blockNote scopeNote callNote : Tree) (callerNotes : List Tree)
    (stackNotes : notes.runtime.stack = blockNote::scopeNote::callNote::callerNotes)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    ∃ result,
      runC F 25 source C₀ = some (cstrBodyResult source localCell buffer caller,C₀) ∧
      runC F 25 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (cstrBodyResult source localCell buffer caller) result ∧
      RetainedInventory (cstrBodyNotes notes localCell buffer callerNotes) ν₀ ν C₀ C R live
        (cstrBodyResult source localCell buffer caller) result ∧
      result.next = target.next ∧ result.ffi = target.ffi := by
  obtain ⟨_,targetControl,controlRelation⟩ := (relation.control_view control).ret_view
  cases controlRelation
  have frames := relation.stack
  rw [stack] at frames
  obtain ⟨first,tail,targetStack,firstRelation,tailRelation⟩ := frames_cons_view frames
  obtain ⟨second,tail',tailEq,secondRelation,tailRelation'⟩ := frames_cons_view tailRelation
  obtain ⟨third,targetCaller,tailEq',thirdRelation,_⟩ := frames_cons_view tailRelation'
  rw [firstRelation.block_view,tailEq,secondRelation.emptyScope_view,tailEq',thirdRelation.call_view] at targetStack
  have leftShape : cstrBodyState source env caller = source := by
    cases source
    simp_all only [cstrBodyState,St.mk.injEq]
  have rightShape : cstrBodyState target (R.env env) targetCaller = target := by
    cases target
    simp_all only [cstrBodyState,St.mk.injEq]
  have held : RetainedInventory notes ν₀ ν C₀ C R live
      (cstrBodyState source env caller) (cstrBodyState target (R.env env) targetCaller) := by rw [leftShape,rightShape]; exact inventory
  have paired : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (cstrBodyState source env caller) (cstrBodyState target (R.env env) targetCaller) := by rw [leftShape,rightShape]; exact relation
  obtain ⟨left,right,post,retained⟩ := held.cstr_cached_body env caller targetCaller key localCell buffer paired
    current blockNote scopeNote callNote callerNotes stackNotes sourceBound targetBound
  rw [leftShape] at left
  rw [rightShape] at right
  exact ⟨_,left,right,post,retained,rfl,rfl⟩

end Host.Ts.Owned.Annotated
