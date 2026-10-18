import host.mlx.NativeTypedBufferInventory
import host.mlx.NativeMemoryInventory
import host.ts.RenameRetainedTypedAllocation

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

private theorem ordinary_zero_values {ν : Nat → F64} {C : CSrv} {R : Ren} {values : List Val}
    (held : ListR (fun role value => role.Holds ν C R value) [Value.ordinaryBig 0] values) : values = [.big 0] := by
  cases held with | cons head tail =>
    cases tail
    cases head
    rfl

def RetainedNotes.nullTyped (notes : RetainedNotes) (fresh : Nat) : RetainedNotes :=
  notes.typedBytes fresh (handleSlotNotes 0)

/-- BigUint64Array([0n]) gets its element from the current array inventory,
its builtin literals from captured metadata, and its null-handle meaning from
the native Live invariant. Both original allocations install the byte notes. -/
theorem RetainedInventory.typedArray_null_step
    (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop)
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St Host.Load.LSt}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    {NodeRelation : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop}
    {ObjectRelation : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop} {H N : Nat → Prop} {tail : List NumV}
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R NodeRelation ObjectRelation H N tail s₀.ffi.mlx s.ffi.mlx)
    (fn arrayOwner proto : Nat) (object : Obj) (newTarget : Val) (x y : F64) (metadata : NativeCaptureNote)
    (control : s₀.ctl = .construct (.obj fn) [.obj arrayOwner] newTarget)
    (read : s₀.heap.get fn = some (.obj object))
    (kind : object.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (codeIndex : F64.toIndex? x = some 9) (protoIndex : F64.toIndex? y = some proto)
    (selected : notes.captures.owners fn = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit x)))
    (protoNote : metadata.roles 1 = some (.literal (.lit y)))
    (elements : notes.arrays.owners arrayOwner = some [.ordinaryBig 0])
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live proto) (protoFixed : R.a proto = proto)
    (sourceBound : s₀.next+1 < 2^64) (targetBound : s.next+1 < 2^64) :
    let sourcePost := (newTyped Host.Load.ffi s₀ .u64 proto (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s₀.next+1))
    let targetPost := (newTyped Host.Load.ffi s .u64 proto (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s.next+1))
    interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1))
        framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.nullTyped s₀.next) ν₀ ν C₀ C R
        (LiveAfter (LiveAfter live s₀.next) (s₀.next+1)) sourcePost targetPost := by
  dsimp only
  obtain ⟨sourceArray,targetArray,sourceValues,targetValues,sourceRead,sourceKind,targetRead,targetKind,sourceRoles,targetRoles,_⟩ :=
    inventory.arrays.selected arrayOwner [.ordinaryBig 0] elements
  have sourceValuesEq := ordinary_zero_values sourceRoles
  have targetValuesEq := ordinary_zero_values targetRoles
  rw [sourceValuesEq] at sourceKind
  rw [targetValuesEq] at targetKind
  have targetContents : ArrayData s (R.a arrayOwner) [.big 0] := ⟨targetArray,targetRead,targetKind⟩
  have codeRole := (inventory.captures.argument fn metadata selected 0 _ codeNote).2.2
  have protoRole := (inventory.captures.argument fn metadata selected 1 _ protoNote).2.2
  obtain ⟨sourceRun,targetRun,post⟩ := step_construct_u64_zero_from_source Host.Load.ffi (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν
    live framed before after old old' s₀ s h fn arrayOwner proto object sourceArray newTarget x y
    control read kind sourceRead sourceKind codeIndex protoIndex targetContents codeRole protoRole
    bufferProtoLive bufferProtoFixed protoLive protoFixed sourceBound targetBound
  have sourceBytes := null_handle_cellPartNotes ν₀ C₀ identity rfl 8 0
  have targetBytes := null_handle_cellPartNotes ν C R native.handleZero 8 0
  exact ⟨sourceRun,targetRun,post,inventory.newTyped_buffer Host.Load.ffi h.heap .u64 proto 1
    _ _ (handleSlotNotes 0) sourceBytes targetBytes sourceBound targetBound⟩

end Host.Ts.Owned.Annotated
