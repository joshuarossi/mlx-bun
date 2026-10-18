import host.mlx.NativeHandleArrayInventory
import host.mlx.OrdinaryVectorStates
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro2 23 95 as Ordinary.HandleArray223.constructorObject
host_transport_object P.RestStream.micro0.micro2 23 3126677 as Ordinary.HandleArray223.arrayObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.HandleArray223
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def input : St LSt := P.RestStream.micro0.micro2.s23
noncomputable def output : St LSt := P.RestStream.micro0.micro2.s24
noncomputable def handles : List Nat := match arrayObject.kind with
  | .array values => values.filterMap (fun value => match value with | .big (.ofNat n) => some n | _ => none)
  | _ => []

theorem source_control : input.ctl = .construct (.obj 95) [.obj 3126677] (.obj 95) := by host_kernel_rfl
theorem source_constructor : input.heap.get 95 = some (.obj constructorObject) := by host_kernel_rfl
theorem source_kind : constructorObject.kind = .fn (.native (.buf .typedCtor)
    [.num (.lit (F64.ofNat 9)),.num (.lit (F64.ofNat 26))]) := by host_kernel_rfl
theorem source_handles : handles = [25732,29363] := by host_kernel_rfl
theorem source_native_bound : input.ffi.mlx.next < 2^64 := by decide +kernel
theorem source_bound : input.next+1 < 2^64 := by decide +kernel
theorem source_post : (newTyped Host.Load.ffi input .u64 26
    (cellBytes .u64 (handleArrayCells identity handles)) handles.length).2.ret (.obj (input.next+1)) = output := by host_kernel_rfl

/-- The actual source223 input-vector buffer constructor retains both owned
handle meanings through the original uint64 conversion and two allocations. -/
theorem retained_transport (FR : Ren → P.F.S → P.F.S → Prop) {notes : RetainedNotes}
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    {NodeRelation : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop}
    {ObjectRelation : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop} {H N : Nat → Prop} {tail : List NumV}
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R NodeRelation ObjectRelation H N tail input.ffi.mlx s.ffi.mlx)
    (metadata : NativeCaptureNote) (selected : notes.captures.owners 95 = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit (F64.ofNat 9))))
    (protoNote : metadata.roles 1 = some (.literal (.lit (F64.ofNat 26))))
    (elements : notes.arrays.owners 3126677 = some (handles.map Value.handle)) (owned : listSupport H handles)
    (nativeBound : s.ffi.mlx.next < 2^64)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live 26) (protoFixed : R.a 26 = 26) (bound : s.next+1 < 2^64) :
    ∃ result, interpC (step P.F input).run C₀ = some (output,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live input.next) (input.next+1))
        framed before after old old' output result ∧
      RetainedInventory (notes.typedBytes input.next (handleArrayBytes handles)) ν₀ ν C₀ C R
        (LiveAfter (LiveAfter live input.next) (input.next+1)) output result := by
  obtain ⟨sourceRun,targetRun,post,retained⟩ := inventory.typedArray_handles_step FR h native
    95 3126677 26 constructorObject (.obj 95) (F64.ofNat 9) (F64.ofNat 26) metadata handles
    source_control source_constructor source_kind (by decide +kernel) (by decide +kernel) selected codeNote protoNote
    elements owned source_native_bound nativeBound bufferProtoLive bufferProtoFixed protoLive protoFixed source_bound bound
  rw [source_post] at sourceRun post retained
  exact ⟨_,sourceRun,targetRun,post,retained⟩

end Host.Load.Run.Full.Ordinary.HandleArray223
