import host.mlx.NativeTypedArrayInventory
import host.ts.renameOrdinary.VectorToConcatTyped

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.Typed298
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- The actual source298 null-slot initialization derives the target iterable
and builtin literals from retained notes, and fixes null through native Live. -/
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
    (elements : notes.arrays.owners 3126699 = some [.ordinaryBig 0])
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live 26) (protoFixed : R.a 26 = 26) (bound : s.next+1 < 2^64) :
    ∃ result, interpC (step P.F input).run C₀ = some (output,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter (LiveAfter live input.next) (input.next+1))
        framed before after old old' output result ∧
      RetainedInventory (notes.nullTyped input.next) ν₀ ν C₀ C R
        (LiveAfter (LiveAfter live input.next) (input.next+1)) output result := by
  obtain ⟨sourceRun,targetRun,post,retained⟩ := inventory.typedArray_null_step FR h native
    95 3126699 26 constructorObject newTarget (F64.ofNat 9) (F64.ofNat 26) metadata
    source_control source_constructor source_kind (by decide +kernel) (by decide +kernel)
    selected codeNote protoNote elements bufferProtoLive bufferProtoFixed protoLive protoFixed source_bound bound
  have sourceEq : (newTyped Host.Load.ffi input .u64 26 (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (input.next+1)) = output := source_post
  rw [sourceEq] at sourceRun post retained
  exact ⟨_,sourceRun,targetRun,post,retained⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat.Typed298
