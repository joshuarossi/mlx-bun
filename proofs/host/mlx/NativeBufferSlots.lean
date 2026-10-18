import host.ts.RenameBufferCells
import host.mlx.NativePublicWrites

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

def handleSlotNotes (handle : Nat) : List Byte := cellPartNotes .u64 (.handle handle) 8 0

theorem BufferContents.slot_role {S : Type} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner handle : Nat} {s : St S} (contents : BufferContents (handleSlotNotes handle) ν C R owner s) :
    (slotKindRole handle).Holds ν C R (objectKindAt s (R.a owner)) := by
  obtain ⟨object,bytes,read,kind,held⟩ := contents
  have exactBytes := cellPartNotes_handle_exact .u64 handle 8 0 bytes held
  simp only [objectKindAt,St.obj?,read]
  rw [kind,exactBytes]
  exact Parametric.slot_role ν C R handle

theorem BufferInventory.slot_roles {S : Type} {notes : BufferNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner handle : Nat) (selected : notes.owners owner = some (handleSlotNotes handle)) :
    (slotKindRole handle).Holds ν₀ C₀ identity (objectKindAt s₀ owner) ∧
    (slotKindRole handle).Holds ν C R (objectKindAt s (R.a owner)) :=
  ⟨(inventory.source owner _ selected).slot_role,(inventory.target owner _ selected).slot_role⟩

/-- A native-owned handle write establishes the new fixed slot meaning. The
previous meaning is replaced by the actual native result, even for null slots. -/
theorem BufferInventory.write_handle (F : Ffi) {notes : BufferNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St F.S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (owner handle : Nat) (oldRoles : List Byte) (selected : notes.owners owner = some oldRoles)
    (length : oldRoles.length ≤ 8) (sourceBound : owner < 2^64) (targetBound : R.a owner < 2^64) :
    ∃ t₀ t, applyWrites F s₀ [Host.Mlx.Ffi.u64Write owner 0 handle] = some t₀ ∧
      applyWrites F s [Host.Mlx.Ffi.u64Write (R.a owner) 0 (R.handle handle)] = some t ∧
      BufferInventory (notes.write owner (handleSlotNotes handle)) ν₀ ν C₀ C R live t₀ t := by
  have source : ListR (fun role byte => role.Holds ν₀ C₀ identity byte) (handleSlotNotes handle)
      (cellParts .u64 (.big (Int.ofNat handle)) 8 0) := cellPartNotes_holds (.handle handle) .u64 8 0
  have target : ListR (fun role byte => role.Holds ν C R byte) (handleSlotNotes handle)
      (cellParts .u64 (.big (Int.ofNat (R.handle handle))) 8 0) := cellPartNotes_holds (.handle handle) .u64 8 0
  obtain ⟨t₀,t,sourceWrite,targetWrite,post⟩ := inventory.write_bytes F heap owner 0 oldRoles (handleSlotNotes handle)
    _ _ selected source target sourceBound targetBound
  have drop : oldRoles.drop 8 = [] := List.drop_eq_nil_iff.mpr length
  have patch : oldRoles.take 0 ++ handleSlotNotes handle ++ oldRoles.drop (0 + len (handleSlotNotes handle)) = handleSlotNotes handle := by
    change [] ++ handleSlotNotes handle ++ oldRoles.drop 8 = handleSlotNotes handle
    rw [drop]
    exact List.append_nil _
  rw [patch] at post
  exact ⟨t₀,t,sourceWrite,targetWrite,post⟩

/-- Complete the original FFI result and retain the newly written handle
annotation through trace/return effects. The native family supplies this
result; target memory reads and post-slot roles are derived here. -/
theorem BufferInventory.ffiDone_handle (F : Ffi) {notes : BufferNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St F.S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (owner handle : Nat) (oldRoles : List Byte) (selected : notes.owners owner = some oldRoles)
    (length : oldRoles.length ≤ 8) (sourceBound : owner < 2^64) (targetBound : R.a owner < 2^64)
    (native₀ native : F.S) (name : Name) (args₀ args : List Arg) :
    ∃ t₀ t, ffiDone F s₀ name args₀ (some (native₀,Host.Mlx.Ffi.status0,[Host.Mlx.Ffi.u64Write owner 0 handle])) = M.pure t₀ ∧
      ffiDone F s name args (some (native,Host.Mlx.Ffi.status0,[Host.Mlx.Ffi.u64Write (R.a owner) 0 (R.handle handle)])) = M.pure t ∧
      BufferInventory (notes.write owner (handleSlotNotes handle)) ν₀ ν C₀ C R live t₀ t ∧
      (slotKindRole handle).Holds ν₀ C₀ identity (objectKindAt t₀ owner) ∧
      (slotKindRole handle).Holds ν C R (objectKindAt t (R.a owner)) ∧
      NativeHeapFrame s₀ t₀ ∧ NativeHeapFrame s t ∧
      t₀.ctl = .ret (.num zeroN) ∧ t.ctl = .ret (.num zeroN) := by
  have current : BufferInventory notes ν₀ ν C₀ C R live (s₀.setFfi native₀) (s.setFfi native) :=
    inventory.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have currentHeap : Parametric.HeapR NR R live framed before after (s₀.setFfi native₀) (s.setFfi native) :=
    ⟨heap.lookup,heap.sourceBound,heap.targetBound,heap.prefixLive,heap.inj,heap.fresh⟩
  obtain ⟨u₀,u,sourceWrite,targetWrite,post⟩ := current.write_handle F currentHeap owner handle oldRoles selected length sourceBound targetBound
  let t₀ := (u₀.setTrace (⟨name,args₀,Host.Mlx.Ffi.status0⟩ :: u₀.trace)).ret (.num zeroN)
  let t := (u.setTrace (⟨name,args,Host.Mlx.Ffi.status0⟩ :: u.trace)).ret (.num zeroN)
  have retained : BufferInventory (notes.write owner (handleSlotNotes handle)) ν₀ ν C₀ C R live t₀ t :=
    post.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  have roles := retained.slot_roles owner handle (by simp only [BufferNotes.write,ite_true])
  have sourceDone : ffiDone F s₀ name args₀ (some (native₀,Host.Mlx.Ffi.status0,[Host.Mlx.Ffi.u64Write owner 0 handle])) = M.pure t₀ := by
    rw [ffiDone,sourceWrite]; rfl
  have targetDone : ffiDone F s name args (some (native,Host.Mlx.Ffi.status0,[Host.Mlx.Ffi.u64Write (R.a owner) 0 (R.handle handle)])) = M.pure t := by
    rw [ffiDone,targetWrite]; rfl
  have sourceFrame := (native_ffiDone_frame F s₀ name args₀ native₀ Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write owner 0 handle] C₀ C₀ t₀
    ⟨sourceBound,True.intro⟩ (by intro r a impossible; cases impossible) (by rw [sourceDone]; rfl)).1
  have targetFrame := (native_ffiDone_frame F s name args native Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (R.a owner) 0 (R.handle handle)] C C t
    ⟨targetBound,True.intro⟩ (by intro r a impossible; cases impossible) (by rw [targetDone]; rfl)).1
  exact ⟨t₀,t,sourceDone,targetDone,retained,roles.1,roles.2,sourceFrame,targetFrame,rfl,rfl⟩

end Host.Ts.Owned.Annotated
