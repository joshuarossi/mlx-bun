import host.mlx.NativeBufferSlotFrame
import host.ts.RenameRetainedInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

theorem BufferContents.written_handle_slot {S : Type} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner handle : Nat} {oldRoles : List Byte} {s t : St S}
    (contents : BufferContents oldRoles ν C R owner s) (frame : NativeHeapFrame s t)
    (slot : (slotKindRole handle).Holds ν C R (objectKindAt t (R.a owner))) :
    BufferContents (handleSlotNotes handle) ν C R owner t := by
  obtain ⟨object,_,read,_,_⟩ := contents
  obtain ⟨kind,postRead⟩ := frame.headers (R.a owner) object read
  have postSlot : (slotKindRole handle).Holds ν C R (Encode.kind kind) := by
    simpa only [objectKindAt,St.obj?,postRead] using slot
  exact ⟨{object with kind := kind},_,postRead,slot_kind_exact postSlot,cellPartNotes_holds (.handle handle) .u64 8 0⟩

/-- Replacing a slot installs the native family's actual output handle note;
every other selected buffer retains its prior byte occurrences. -/
theorem BufferInventory.native_written_slot {S : Type} {notes : BufferNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (owner handle : Nat) (oldRoles : List Byte) (selected : notes.owners owner = some oldRoles)
    (sourceFrame : NativeHeapFrame s₀ t₀) (targetFrame : NativeHeapFrame s t)
    (sourceSlot : (slotKindRole handle).Holds ν₀ C₀ identity (objectKindAt t₀ owner))
    (targetSlot : (slotKindRole handle).Holds ν C R (objectKindAt t (R.a owner)))
    (sourceOutside : ∀ a, a ≠ owner → t₀.heap.get a = s₀.heap.get a)
    (targetOutside : ∀ a, a ≠ R.a owner → t.heap.get a = s.heap.get a) :
    BufferInventory (notes.write owner (handleSlotNotes handle)) ν₀ ν C₀ C R live t₀ t := by
  apply inventory.replace_owner owner (handleSlotNotes handle) (inventory.keyLive owner oldRoles selected)
  · exact (inventory.source owner oldRoles selected).written_handle_slot sourceFrame sourceSlot
  · exact (inventory.target owner oldRoles selected).written_handle_slot targetFrame targetSlot
  · intro a _ _ different; exact sourceOutside a different
  · intro a roles entry different
    have mapped : R.a a ≠ R.a owner := fun equal => different
      (heap.inj a owner (inventory.keyLive a roles entry) (inventory.keyLive owner oldRoles selected) equal)
    exact targetOutside (R.a a) mapped

def RetainedNotes.nativeHandleResult (notes : RetainedNotes) (owner handle : Nat) : RetainedNotes :=
  {notes with runtime := {notes.runtime with control := returnNote nativeStatusRole},buffers := notes.buffers.write owner (handleSlotNotes handle)}

/-- A checked normal native result frames all retained families and updates
only its written slot. Neither target return roles nor future buffer contents
are selected by this inventory adapter. -/
theorem RetainedInventory.native_handle_result {S : Type} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (owner handle : Nat) (oldRoles : List Byte) (selected : notes.buffers.owners owner = some oldRoles)
    (sourceFrame : NativeHeapFrame s₀ t₀) (targetFrame : NativeHeapFrame s t)
    (sourceSlot : (slotKindRole handle).Holds ν₀ C₀ identity (objectKindAt t₀ owner))
    (targetSlot : (slotKindRole handle).Holds ν C R (objectKindAt t (R.a owner)))
    (sourceOutside : ∀ a, a ≠ owner → t₀.heap.get a = s₀.heap.get a)
    (targetOutside : ∀ a, a ≠ R.a owner → t.heap.get a = s.heap.get a)
    (sourceControl : t₀.ctl = .ret (.num zeroN)) (targetControl : t.ctl = .ret (.num zeroN)) :
    RetainedInventory (notes.nativeHandleResult owner handle) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨runtime,retainedHeap,retainedArrays,publicFields⟩ := native_status_frame_inventories inventory.runtime inventory.heapInventory
    inventory.arrays inventory.publicFields (TableExtends.refl C₀) (TableExtends.refl C) sourceFrame targetFrame sourceControl targetControl
  exact ⟨runtime,retainedHeap.privates,retainedHeap.captures,retainedArrays,publicFields,
    inventory.buffers.native_written_slot heap owner handle oldRoles selected sourceFrame targetFrame sourceSlot targetSlot sourceOutside targetOutside⟩

end Host.Ts.Owned.Annotated
