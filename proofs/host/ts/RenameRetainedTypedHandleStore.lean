import host.ts.RenameRetainedTypedHandleStoreFrames
import host.ts.RenameParametricPropWrites
import host.ts.RenameRuntimeSourceCut

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def typedHandleStoreBytes (bytes : List Host.Ts.Byte) (off index handle : Nat) : List Host.Ts.Byte :=
  writeCell .u64 (.big (Int.ofNat handle)) bytes (off + index * 8)

def typedHandleStorePost {S : Type} (s : St S) (buffer : Nat) (object : Obj)
    (bytes : List Host.Ts.Byte) (off index handle : Nat) (frames : List Frame) : St S :=
  ({s with stack := frames}.setObj buffer
    {object with kind := .buf (typedHandleStoreBytes bytes off index handle)}).ret (.big (Int.ofNat handle))

def RetainedNotes.typedHandleStored (notes : RetainedNotes) (buffer off index handle : Nat)
    (oldRoles : List Byte) (tail : List Tree) : RetainedNotes :=
  ⟨⟨returnNote (.handle handle),tail,notes.runtime.cells⟩,notes.privates,notes.captures,
    notes.arrays,notes.publicFields,notes.buffers.write buffer
      (oldRoles.take (off + index * 8) ++ cellPartNotes .u64 (.handle handle) 8 0 ++
        oldRoles.drop (off + index * 8 + 8))⟩

/-- The original assignment performs its u64 conversion, checks the element
index, writes the backing buffer, and returns the assigned bigint. -/
theorem step_typed_handle_store_eq (F : Ffi) (s : St F.S)
    (owner buffer off count index handle : Nat) (name : Name) (object bo : Obj)
    (bytes : List Host.Ts.Byte) (frames : List Frame)
    (control : s.ctl = .ret (.big (Int.ofNat handle)))
    (stack : s.stack = .a (.put none (.prop (.obj owner) (.str name)) .undef)::frames)
    (read : s.heap.get owner = some (.obj object)) (kind : object.kind = .typed .u64 buffer off count)
    (key : keyIndex (.str name) = some index) (inside : index < count)
    (bufferRead : s.heap.get buffer = some (.obj bo)) (bufferKind : bo.kind = .buf bytes)
    (word : handle < 2^64) :
    step F s = M.pure (typedHandleStorePost s buffer bo bytes off index handle frames) := by
  have reduced : modInt (Int.ofNat handle) (2^64) = handle := by
    change handle % (2^64) = handle
    exact Nat.mod_eq_of_lt word
  have inside : Nat.blt index count = true := Nat.blt_eq.mpr inside
  funext β k
  simp only [step,control,stepRet,stack,retStep,retA,storeTarget,putV,St.obj?,read,kind,key,
    typedPut,toCell,reduced,inside,Bool.cond_true,bufferRead,bufferKind,retS,M.bind,M.pure,
    typedHandleStorePost,typedHandleStoreBytes,EltK.size]
  rfl

/-- Current source metadata, a retained handle return, and the current buffer
inventory determine both original stores. No target operand, target buffer,
post-state, or future annotation is an input. -/
theorem RetainedInventory.typed_handle_store_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner buffer off count index handle : Nat) (name : Name) (object bo : Obj)
    (bytes : List Host.Ts.Byte) (frames : List Frame) (oldRoles : List Byte) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret (.big (Int.ofNat handle)))
    (stack : s₀.stack = .a (.put none (.prop (.obj owner) (.str name)) .undef)::frames)
    (read : s₀.heap.get owner = some (.obj object)) (kind : object.kind = .typed .u64 buffer off count)
    (key : keyIndex (.str name) = some index) (inside : index < count)
    (bufferRead : s₀.heap.get buffer = some (.obj bo)) (bufferKind : bo.kind = .buf bytes)
    (selected : notes.buffers.owners buffer = some oldRoles)
    (controlNote : notes.runtime.control = returnNote (.handle handle))
    (stackNotes : notes.runtime.stack = head::tail)
    (notFramed : ¬ framed buffer)
    (sourceBound : buffer < 2^64) (targetBound : R.a buffer < 2^64)
    (sourceWord : handle < 2^64) (targetWord : R.handle handle < 2^64) :
    ∃ targetBuffer targetBytes targetFrames,
      let sourcePost := typedHandleStorePost s₀ buffer bo bytes off index handle frames
      let targetPost := typedHandleStorePost s (R.a buffer) targetBuffer targetBytes off index (R.handle handle) targetFrames
      interpC (step F s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step F s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.typedHandleStored buffer off index handle oldRoles tail)
        ν₀ ν C₀ C R live sourcePost targetPost := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  have valueRole := inventory.runtime.target.control
  rw [controlNote,targetControl] at valueRole
  have exactHandle : targetValue = .big (Int.ofNat (R.handle handle)) := by
    have meaning := returnNote_view valueRole
    cases meaning
    rfl
  subst targetValue
  obtain ⟨targetFrame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [typed_store_put_view frameRelation] at targetStack
  have support := h.stackLive
  rw [stack] at support
  have ownerLive : live owner := support.1.1.2.1.1
  obtain ⟨targetView,targetViewRead,targetViewKind,bufferLive⟩ :=
    h.heap.read_typedBuffer owner buffer off count object .u64 ownerLive read kind
  obtain ⟨sourceBuffer,sourceBytes,sourceRead,sourceKind,sourceRoles⟩ := inventory.buffers.source buffer oldRoles selected
  change s₀.heap.get buffer = some (.obj sourceBuffer) at sourceRead
  have sourceEqual := HObj.obj.inj (Option.some.inj (sourceRead.symm.trans bufferRead))
  subst sourceBuffer
  have bytesEqual := Kind.buf.inj (sourceKind.symm.trans bufferKind)
  subst sourceBytes
  obtain ⟨targetBuffer,targetBytes,targetRead,targetKind,targetRoles⟩ := inventory.buffers.target buffer oldRoles selected
  obtain ⟨relatedBuffer,relatedRead,objectRelation,objectLive⟩ := h.heap.readObject buffer bo bufferLive notFramed bufferRead
  have targetEqual := HObj.obj.inj (Option.some.inj (relatedRead.symm.trans targetRead))
  subst relatedBuffer
  let new₀ : Obj := {bo with kind := .buf (typedHandleStoreBytes bytes off index handle)}
  let new : Obj := {targetBuffer with kind := .buf (typedHandleStoreBytes targetBytes off index (R.handle handle))}
  have writeRoles₀ := cellPartNotes_holds (Cell.Holds.handle (ν := ν₀) (C := C₀) (R := identity) handle) .u64 8 0
  have writeRoles := cellPartNotes_holds (Cell.Holds.handle (ν := ν) (C := C) (R := R) handle) .u64 8 0
  have oldPair := typed_store_bytes_paired sourceRoles targetRoles
  have writePair := typed_store_bytes_paired writeRoles₀ writeRoles
  have patched : ListR (Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R)
      (typedHandleStoreBytes bytes off index handle) (typedHandleStoreBytes targetBytes off index (R.handle handle)) :=
    typed_store_patch_related oldPair writePair (off + index * 8)
  have post := ((h.restack tailRelation support.2).setObject buffer new₀ new bufferLive notFramed
    (typed_store_replace_buffer objectRelation patched) (Owned.objectBufferSupport live bo objectLive _)
    sourceBound targetBound).go
      (c := .ret (.big (Int.ofNat handle))) (c' := .ret (.big (Int.ofNat (R.handle handle))))
      (.node _ (.cons (.value (.handle handle)) .nil)) ⟨True.intro,True.intro⟩
  have cells := inventory.runtime.cellInventory.setObject h.heap buffer bo targetBuffer new₀ new
    (.big (Int.ofNat handle)) (.big (Int.ofNat (R.handle handle))) bufferLive bufferRead targetRead sourceBound targetBound
  have privateFields := inventory.privates.setKind buffer bo targetBuffer new₀.kind new.kind
    bufferRead targetRead sourceBound targetBound
  have publicFields := inventory.publicFields.setKind buffer bo targetBuffer new₀.kind new.kind
    bufferRead targetRead sourceBound targetBound
  have nonNative : ∀ code data, bo.kind ≠ .fn (.native code data) := by
    intro code data impossible; rw [bufferKind] at impossible; cases impossible
  have captures := inventory.captures.setNonNativeKind h.heap buffer bo new₀ new
    (.big (Int.ofNat handle)) (.big (Int.ofNat (R.handle handle))) bufferLive bufferRead nonNative sourceBound targetBound
  have arrays := typed_store_array_frame inventory.arrays h.heap buffer bo new₀ new bytes
    bufferLive bufferRead bufferKind sourceBound targetBound
  let sourcePost := typedHandleStorePost s₀ buffer bo bytes off index handle frames
  let targetPost := typedHandleStorePost s (R.a buffer) targetBuffer targetBytes off index (R.handle handle) targetFrames
  have buffers : BufferInventory
      (notes.buffers.write buffer (oldRoles.take (off + index * 8) ++ cellPartNotes .u64 (.handle handle) 8 0 ++
        oldRoles.drop (off + index * 8 + 8))) ν₀ ν C₀ C R live sourcePost targetPost := by
    apply inventory.buffers.replace_owner buffer _ bufferLive
    · refine ⟨new₀,_,?_,rfl,byte_roles_patch sourceRoles writeRoles₀ (off + index * 8)⟩
      simp only [sourcePost,typedHandleStorePost,St.setObj,St.ret,identity,id_eq,PTrie.get_set_u64 _ _ _ sourceBound,ite_true,new₀]
    · refine ⟨new,_,?_,rfl,byte_roles_patch targetRoles writeRoles (off + index * 8)⟩
      simp only [targetPost,typedHandleStorePost,St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_true,new]
    · intro a other entry different
      simp only [sourcePost,typedHandleStorePost,St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right different]
    · intro a other entry different
      have mapped : R.a a ≠ R.a buffer := fun same => different
        (h.heap.inj a buffer (inventory.buffers.keyLive a other entry) bufferLive same)
      simp only [targetPost,typedHandleStorePost,St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right mapped]
  have sourceStackNotes := inventory.runtime.source.stack
  rw [stackNotes,stack,List.map_cons] at sourceStackNotes
  have targetStackNotes := inventory.runtime.target.stack
  rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
  refine ⟨targetBuffer,targetBytes,targetFrames,?_,?_,post,?_,?_,?_,?_,?_,buffers⟩
  · rw [step_typed_handle_store_eq F s₀ owner buffer off count index handle name object bo bytes frames
      control stack read kind key inside bufferRead bufferKind sourceWord]; rfl
  · rw [step_typed_handle_store_eq F s (R.a owner) (R.a buffer) off count index (R.handle handle) name targetView targetBuffer targetBytes targetFrames
      targetControl targetStack targetViewRead targetViewKind key inside targetRead targetKind targetWord]; rfl
  · exact ⟨cells.keyLive,
      ⟨returnNote_holds (.handle handle),sourceStackNotes.tail,cells.source⟩,
      ⟨returnNote_holds (.handle handle),targetStackNotes.tail,cells.target⟩⟩
  · exact privateFields.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact captures.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact arrays.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact publicFields.frame (fun _ h => h) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)

end Host.Ts.Owned.Annotated
