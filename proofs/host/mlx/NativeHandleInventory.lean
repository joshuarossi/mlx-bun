import host.mlx.NativeBufferSlots

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Complete a proved native handle result, updating its buffer-byte note and
retaining every other occurrence family. The written handle determines the
new slot role; no target write, target getter or post-role is a premise. -/
theorem native_handle_write_inventories (F : Ffi) {notes : RuntimeNotes}
    {privates : PrivateNotes} {captures : NativeCaptureNotes} {arrayNotes : ArrayNotes}
    {publicNotes : PublicNotes} {bufferNotes : BufferNotes}
    {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St F.S}
    (runtime : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publicNotes ν₀ ν C₀ C R live s₀ s)
    (bufferInventory : BufferInventory bufferNotes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} {framed : Nat → Prop} {before after : List Val}
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D)
    (owner handle : Nat) (oldRoles : List Byte) (selected : bufferNotes.owners owner = some oldRoles)
    (length : oldRoles.length ≤ 8) (sourceBound : owner < 2^64) (targetBound : R.a owner < 2^64)
    (native₀ native : F.S) (name : Name) (args₀ args : List Arg) :
    ∃ t₀ t, ffiDone F s₀ name args₀ (some (native₀,Host.Mlx.Ffi.status0,[Host.Mlx.Ffi.u64Write owner 0 handle])) = M.pure t₀ ∧
      ffiDone F s name args (some (native,Host.Mlx.Ffi.status0,[Host.Mlx.Ffi.u64Write (R.a owner) 0 (R.handle handle)])) = M.pure t ∧
      RuntimeInventory {notes with control := returnNote nativeStatusRole} ν₀ ν D₀ D R live t₀ t ∧
      HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν D₀ D R live t₀ t ∧
      ArrayInventory arrayNotes ν₀ ν D₀ D R live t₀ t ∧
      PublicInventory publicNotes ν₀ ν D₀ D R live t₀ t ∧
      BufferInventory (bufferNotes.write owner (handleSlotNotes handle)) ν₀ ν D₀ D R live t₀ t ∧
      (slotKindRole handle).Holds ν₀ D₀ identity (objectKindAt t₀ owner) ∧
      (slotKindRole handle).Holds ν D R (objectKindAt t (R.a owner)) := by
  obtain ⟨t₀,t,sourceDone,targetDone,buffers,sourceSlot,targetSlot,sourceFrame,targetFrame,sourceControl,targetControl⟩ :=
    (bufferInventory.mono sourceExtension targetExtension).ffiDone_handle F heap owner handle oldRoles selected length
      sourceBound targetBound native₀ native name args₀ args
  obtain ⟨runtimePost,heapPost,arraysPost,publicPost⟩ := native_status_frame_inventories runtime heapInventory
    arrayInventory publicInventory sourceExtension targetExtension sourceFrame targetFrame sourceControl targetControl
  exact ⟨t₀,t,sourceDone,targetDone,runtimePost,heapPost,arraysPost,publicPost,buffers,sourceSlot,targetSlot⟩

end Host.Ts.Owned.Annotated
