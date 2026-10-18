import host.mlx.NativeBufferSlots

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

theorem BufferContents.frame_handle_slot {S : Type} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner handle : Nat} {s t : St S}
    (contents : BufferContents (handleSlotNotes handle) ν C R owner s) (frame : NativeHeapFrame s t)
    (slot : (slotKindRole handle).Holds ν C R (objectKindAt t (R.a owner))) :
    BufferContents (handleSlotNotes handle) ν C R owner t := by
  obtain ⟨object,_,read,_,_⟩ := contents
  obtain ⟨kind,postRead⟩ := frame.headers (R.a owner) object read
  have postSlot : (slotKindRole handle).Holds ν C R (Encode.kind kind) := by
    simpa only [objectKindAt,St.obj?,postRead] using slot
  exact ⟨{object with kind := kind},_,postRead,slot_kind_exact postSlot,cellPartNotes_holds (.handle handle) .u64 8 0⟩

/-- Existing output vectors keep their slot's fixed handle role. Family
execution proofs establish the post-slot role and exact outside writes; this
lemma retains every selected buffer without interpreting future operands. -/
theorem BufferInventory.native_existing_slot {S : Type} {notes : BufferNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (owner handle : Nat) (selected : notes.owners owner = some (handleSlotNotes handle))
    (sourceFrame : NativeHeapFrame s₀ t₀) (targetFrame : NativeHeapFrame s t)
    (sourceSlot : (slotKindRole handle).Holds ν₀ C₀ identity (objectKindAt t₀ owner))
    (targetSlot : (slotKindRole handle).Holds ν C R (objectKindAt t (R.a owner)))
    (sourceOutside : ∀ a, a ≠ owner → t₀.heap.get a = s₀.heap.get a)
    (targetOutside : ∀ a, a ≠ R.a owner → t.heap.get a = s.heap.get a) :
    BufferInventory notes ν₀ ν C₀ C R live t₀ t := by
  refine ⟨inventory.keyLive,?_,?_⟩
  · intro a roles entry
    by_cases same : a = owner
    · subst a
      have equal := Option.some.inj (entry.symm.trans selected)
      subst roles
      exact (inventory.source owner _ selected).frame_handle_slot sourceFrame sourceSlot
    · exact (inventory.source a roles entry).frame (sourceOutside a same)
  · intro a roles entry
    by_cases same : a = owner
    · subst a
      have equal := Option.some.inj (entry.symm.trans selected)
      subst roles
      exact (inventory.target owner _ selected).frame_handle_slot targetFrame targetSlot
    · have mapped : R.a a ≠ R.a owner := fun equal => same
        (heap.inj a owner (inventory.keyLive a roles entry) (inventory.keyLive owner _ selected) equal)
      exact (inventory.target a roles entry).frame (targetOutside (R.a a) mapped)

end Host.Ts.Owned.Annotated
