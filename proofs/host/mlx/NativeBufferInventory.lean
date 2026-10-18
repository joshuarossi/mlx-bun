import host.mlx.NativeRuntimeDispatch
import host.ts.RenameHeapInventory
import host.ts.RenameArrayInventory
import host.ts.RenamePrivateKindFrame
import host.ts.RenameCaptureKindFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Every no-write native return frames all annotation families. Independent
source/target numeric extensions are applied before installing the fixed
return role supplied by the native result theorem. -/
theorem native_no_write_inventories_mono {S : Type} {notes : RuntimeNotes}
    {privates : PrivateNotes} {captures : NativeCaptureNotes} {arrayNotes : ArrayNotes}
    {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (runtime : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D)
    (native₀ native : S) (trace₀ trace : List Event) (role : Value) (value₀ value : Val)
    (sourceRole : role.Holds ν₀ D₀ identity value₀) (targetRole : role.Holds ν D R value) :
    let sourcePost := ((s₀.setFfi native₀).setTrace trace₀).ret value₀
    let targetPost := ((s.setFfi native).setTrace trace).ret value
    RuntimeInventory {notes with control := returnNote role} ν₀ ν D₀ D R live sourcePost targetPost ∧
    HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν D₀ D R live sourcePost targetPost ∧
    ArrayInventory arrayNotes ν₀ ν D₀ D R live sourcePost targetPost := by
  have current := runtime.mono sourceExtension targetExtension
  refine ⟨⟨current.keyLive,⟨returnNote_holds sourceRole,current.source.stack,current.source.cells⟩,
    ⟨returnNote_holds targetRole,current.target.stack,current.target.cells⟩⟩,?_,?_⟩
  · exact (heapInventory.mono sourceExtension targetExtension).frame (fun _ h => h) (fun _ _ => rfl) (fun _ _ => rfl)
  · exact (arrayInventory.mono sourceExtension targetExtension).frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

theorem ArrayInventory.setBuffer {S : Type} {notes : ArrayNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (inventory : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after s₀ s)
    (address : Nat) (old₀ new₀ new : Obj) (bytes : List Host.Ts.Byte) (value₀ value : Val)
    (alive : live address) (object : s₀.heap.get address = some (.obj old₀)) (buffer : old₀.kind = .buf bytes)
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    ArrayInventory notes ν₀ ν C₀ C R live
      ((s₀.setObj address new₀).ret value₀) ((s.setObj (R.a address) new).ret value) := by
  have distinct : ∀ owner roles, notes.owners owner = some roles → owner ≠ address := by
    intro owner roles selected same
    obtain ⟨arrayObject,values,read,kind,_⟩ := inventory.source owner roles selected
    have sourceRead : s₀.heap.get owner = some (.obj arrayObject) := read
    rw [same,object] at sourceRead
    have equal := HObj.obj.inj (Option.some.inj sourceRead)
    subst arrayObject
    rw [buffer] at kind
    cases kind
  apply inventory.frame (fun _ h => h)
  · intro owner roles selected
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right (distinct owner roles selected)]
  · intro owner roles selected
    have targetDistinct : R.a owner ≠ R.a address := fun same => distinct owner roles selected
      (heap.inj owner address (inventory.keyLive owner roles selected) alive same)
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right targetDistinct]

theorem HeapInventory.finishBuffer {S : Type} {notes : HeapNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (inventory : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after s₀ s)
    (address off : Nat) (object₀ object : Obj) (bytes₀ bytes writes₀ writes : List Host.Ts.Byte)
    (native₀ native : S) (name : Name) (args₀ args : List Arg)
    (alive : live address) (source : s₀.heap.get address = some (.obj object₀))
    (target : s.heap.get (R.a address) = some (.obj object)) (buffer : object₀.kind = .buf bytes₀)
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    HeapInventory notes ν₀ ν C₀ C R live
      (finishBuffer s₀ native₀ address off object₀ bytes₀ writes₀ name args₀)
      (finishBuffer s native (R.a address) off object bytes writes name args) := by
  let kind₀ := Kind.buf (bytes₀.take off ++ writes₀ ++ bytes₀.drop (off + len writes₀))
  let kind := Kind.buf (bytes.take off ++ writes ++ bytes.drop (off + len writes))
  have cells := inventory.cells.setObject heap address object₀ object {object₀ with kind := kind₀}
    {object with kind := kind} (.num zeroN) (.num zeroN) alive source target sourceBound targetBound
  have privates := inventory.privates.setKind address object₀ object kind₀ kind source target sourceBound targetBound
  have nonNative : ∀ code data, object₀.kind ≠ .fn (.native code data) := by
    intro code data equal
    rw [buffer] at equal
    cases equal
  have captures := inventory.captures.setNonNativeKind heap address object₀ {object₀ with kind := kind₀}
    {object with kind := kind} (.num zeroN) (.num zeroN) alive source nonNative sourceBound targetBound
  exact ⟨cells.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    privates.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    captures.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩

theorem RuntimeInventory.finishBuffer {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR (NumberRoles ν₀ ν C₀ C) R live framed before after s₀ s)
    (address off : Nat) (object₀ object : Obj) (bytes₀ bytes writes₀ writes : List Host.Ts.Byte)
    (native₀ native : S) (name : Name) (args₀ args : List Arg)
    (alive : live address) (source : s₀.heap.get address = some (.obj object₀))
    (target : s.heap.get (R.a address) = some (.obj object))
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    RuntimeInventory {notes with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live
      (finishBuffer s₀ native₀ address off object₀ bytes₀ writes₀ name args₀)
      (finishBuffer s native (R.a address) off object bytes writes name args) := by
  let kind₀ := Kind.buf (bytes₀.take off ++ writes₀ ++ bytes₀.drop (off + len writes₀))
  let kind := Kind.buf (bytes.take off ++ writes ++ bytes.drop (off + len writes))
  have cells := inventory.cellInventory.setObject heap address object₀ object {object₀ with kind := kind₀}
    {object with kind := kind} (.num zeroN) (.num zeroN) alive source target sourceBound targetBound
  exact ⟨cells.keyLive,
    ⟨returnNote_holds (nativeStatusRole_holds ν₀ C₀ identity),inventory.source.stack,cells.source⟩,
    ⟨returnNote_holds (nativeStatusRole_holds ν C R),inventory.target.stack,cells.target⟩⟩

/-- A source buffer selects the actual target buffer and frames every retained
inventory through the native write. The caller's native family supplies the
write bytes; target object/byte lookup and all post inventories are derived. -/
theorem native_buffer_inventories_from_source {S : Type} {FR : Ren → S → S → Prop}
    {notes : RuntimeNotes} {privates : PrivateNotes} {captures : NativeCaptureNotes} {arrayNotes : ArrayNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (runtime : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (address off : Nat) (object₀ : Obj) (bytes₀ writes₀ writes : List Host.Ts.Byte)
    (native₀ native : S) (name : Name) (args₀ args : List Arg)
    (alive : live address) (source : s₀.heap.get address = some (.obj object₀)) (buffer : object₀.kind = .buf bytes₀)
    (sourceBound : address < 2^64) (targetBound : R.a address < 2^64) :
    ∃ object bytes, s.heap.get (R.a address) = some (.obj object) ∧ object.kind = .buf bytes ∧
      ListR (Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R) bytes₀ bytes ∧
      let sourcePost := finishBuffer s₀ native₀ address off object₀ bytes₀ writes₀ name args₀
      let targetPost := finishBuffer s native (R.a address) off object bytes writes name args
      RuntimeInventory {notes with control := returnNote nativeStatusRole} ν₀ ν C₀ C R live sourcePost targetPost ∧
      HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live sourcePost targetPost ∧
      ArrayInventory arrayNotes ν₀ ν C₀ C R live sourcePost targetPost := by
  obtain ⟨object,target,related,_⟩ := h.heap.readObject address object₀ alive
    (h.heap.buffer_notFramed address object₀ bytes₀ alive source buffer) source
  have kind := related.kind
  rw [buffer] at kind
  obtain ⟨bytes,targetKind,byteRoles⟩ := kind_buffer kind
  have arrayPost := arrayInventory.setBuffer h.heap address object₀
    {object₀ with kind := .buf (bytes₀.take off ++ writes₀ ++ bytes₀.drop (off + len writes₀))}
    {object with kind := .buf (bytes.take off ++ writes ++ bytes.drop (off + len writes))}
    bytes₀ (.num zeroN) (.num zeroN) alive source buffer sourceBound targetBound
  refine ⟨object,bytes,target,targetKind,byteRoles,
    runtime.finishBuffer h.heap address off object₀ object bytes₀ bytes writes₀ writes native₀ native name args₀ args
      alive source target sourceBound targetBound,
    heapInventory.finishBuffer h.heap address off object₀ object bytes₀ bytes writes₀ writes native₀ native name args₀ args
      alive source target buffer sourceBound targetBound,?_⟩
  exact arrayPost.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

end Host.Ts.Owned.Annotated
