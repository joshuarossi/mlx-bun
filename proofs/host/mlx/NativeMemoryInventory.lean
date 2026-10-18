import host.mlx.NativeHandleReadInventory
import host.ts.RenameRetainedInventory
import host.ts.RenameParametricPointer

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- The original pointer builtin follows a live typed view to its backing
buffer. The resource note is derived from that source heap path, and every
existing annotation family is preserved. -/
theorem RetainedInventory.pointer_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn view buffer off count : Nat) (function object backing : Obj) (kind : EltK)
    (data : List Val) (this : Val) (bytes : List Host.Ts.Byte)
    (control : s₀.ctl = .call (.obj fn) this [.obj view])
    (functionRead : s₀.heap.get fn = some (.obj function)) (functionKind : function.kind = .fn (.native (.ffi .ptr) data))
    (viewRead : s₀.heap.get view = some (.obj object)) (viewKind : object.kind = .typed kind buffer off count)
    (bufferRead : s₀.heap.get buffer = some (.obj backing)) (bufferKind : backing.kind = .buf bytes)
    (nonempty : count ≠ 0) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.ptr (.js buffer) off),C₀) ∧
      interpC (step F s).run C = some (s.ret (.ptr (.js (R.a buffer)) off),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (s₀.ret (.ptr (.js buffer) off)) (s.ret (.ptr (.js (R.a buffer)) off)) ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.ptr (.js buffer) off),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (s₀.ret (.ptr (.js buffer) off)) (s.ret (.ptr (.js (R.a buffer)) off)) := by
  obtain ⟨sourceRun,targetRun,post⟩ := step_ptr_typed_buffer_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h fn view buffer off count function object backing kind data this bytes
    control functionRead functionKind viewRead viewKind bufferRead bufferKind nonempty
  exact ⟨sourceRun,targetRun,post,
    ⟨inventory.runtime.returning (.ptr (.js buffer) off) (.ptr (.js buffer) off),
      inventory.privates.frame (fun _ held => held) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.captures.frame (fun _ held => held) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.arrays.frame (fun _ held => held) (fun _ _ _ => rfl) (fun _ _ _ => rfl),
      inventory.publicFields.frame (fun _ held => held) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),
      inventory.buffers.frame (fun _ held => held) (fun _ _ _ => rfl) (fun _ _ _ => rfl)⟩⟩

/-- The current initialized buffer note determines the returned owned handle.
Neither a target read nor a fresh choice of handle meaning is a premise. -/
theorem RetainedInventory.read_handle_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn buffer handle : Nat) (object : Obj) (data : List Val) (this : Val) (fnRole thisRole : Value)
    (control : s₀.ctl = .call (.obj fn) this [.ptr (.js buffer) 0,.num zeroN])
    (read : s₀.heap.get fn = some (.obj object)) (kind : object.kind = .fn (.native (.ffi .readU64) data))
    (callNote : notes.runtime.control = Annotated.callNote fnRole thisRole
      ([FixedArgument.pointer buffer 0,FixedArgument.literal (F64.zero false)].map FixedArgument.role))
    (selected : notes.buffers.owners buffer = some (handleSlotNotes handle)) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.big (Int.ofNat handle)),C₀) ∧
      interpC (step F s).run C = some (s.ret (.big (Int.ofNat (R.handle handle))),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.handle handle),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live (s₀.ret (.big (Int.ofNat handle))) (s.ret (.big (Int.ofNat (R.handle handle)))) := by
  obtain ⟨sourceRun,targetRun,post,runtime,heap,arrayState,publicFields,buffers⟩ := native_readU64_inventory_step F FR h
    inventory.runtime inventory.heapInventory inventory.arrays inventory.publicFields inventory.buffers
    fn buffer handle object data this fnRole thisRole control read kind callNote selected
  exact ⟨sourceRun,targetRun,post,⟨runtime,heap.privates,heap.captures,arrayState,publicFields,buffers⟩⟩

end Host.Ts.Owned.Annotated
