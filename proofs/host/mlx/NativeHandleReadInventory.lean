import host.mlx.NativeHandleInventory
import host.ts.RenameParametricBufferRead

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- The actual Bun read.u64 wrapper consumes retained argument and buffer
meanings. Both original machine steps, the owned-handle return note and every
inventory are derived without a target read, offset or post-role premise. -/
theorem native_readU64_inventory_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RuntimeNotes} {privates : PrivateNotes} {captures : NativeCaptureNotes}
    {arrayNotes : ArrayNotes} {publicNotes : PublicNotes} {bufferNotes : BufferNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (runtime : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publicNotes ν₀ ν C₀ C R live s₀ s)
    (bufferInventory : BufferInventory bufferNotes ν₀ ν C₀ C R live s₀ s)
    (fn buffer handle : Nat) (object : Obj) (data : List Val) (this : Val) (fnRole thisRole : Value)
    (control : s₀.ctl = .call (.obj fn) this [.ptr (.js buffer) 0,.num zeroN])
    (read : s₀.heap.get fn = some (.obj object)) (kind : object.kind = .fn (.native (.ffi .readU64) data))
    (callNote : notes.control = Annotated.callNote fnRole thisRole
      ([FixedArgument.pointer buffer 0,FixedArgument.literal (F64.zero false)].map FixedArgument.role))
    (selected : bufferNotes.owners buffer = some (handleSlotNotes handle)) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.big (Int.ofNat handle)),C₀) ∧
      interpC (step F s).run C = some (s.ret (.big (Int.ofNat (R.handle handle))),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) ∧
      RuntimeInventory {notes with control := returnNote (.handle handle)} ν₀ ν C₀ C R live
        (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) ∧
      HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live
        (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) ∧
      ArrayInventory arrayNotes ν₀ ν C₀ C R live
        (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) ∧
      PublicInventory publicNotes ν₀ ν C₀ C R live
        (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) ∧
      BufferInventory bufferNotes ν₀ ν C₀ C R live
        (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) := by
  have argumentRoles := (runtime.native_arguments fnRole thisRole
    [.pointer buffer 0,.literal (F64.zero false)] (.obj fn) this _ control callNote).2
  have paired := runtime.control_pair
  rw [control] at paired
  obtain ⟨targetFn,targetThis,targetArgs,targetControl,_,_,_⟩ := paired.call_view
  simp only [targetControl,callArguments] at argumentRoles
  have offset : (Value.literal (.lit (F64.zero false))).Holds ν C R (callArgument s.ctl 1) := by
    cases argumentRoles with | cons pointer rest =>
      cases rest with | cons literal tail =>
        cases tail
        simpa only [targetControl,callArgument,Host.Ts.arg,nthD,FixedArgument.role] using literal
  obtain ⟨sourceBuffer,_,sourceBytes,_,sourceRead,sourceKind,_,_,sourceRoles,_⟩ :=
    bufferInventory.selected buffer _ selected
  have bytes := cellPartNotes_handle_exact .u64 handle 8 0 sourceBytes sourceRoles
  rw [bytes] at sourceKind
  have targetSlot := (bufferInventory.slot_roles buffer handle selected).2
  obtain ⟨sourceRun,targetRun,post⟩ := step_readU64_buffer_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν
    live framed before after old old' s₀ s h fn buffer handle object sourceBuffer data this
    control read kind sourceRead sourceKind offset targetSlot
  exact ⟨sourceRun,targetRun,post,runtime.returning (.handle handle) (.handle handle),
    heapInventory.frame (fun _ alive => alive) (fun _ _ => rfl) (fun _ _ => rfl),
    arrayInventory.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
    publicInventory.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
    bufferInventory.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩

end Host.Ts.Owned.Annotated
