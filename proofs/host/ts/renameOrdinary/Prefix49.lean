import host.ts.renameOrdinary.Prefix40
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.Prefix
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The actual first forty-nine steps derive the fixed axis parameter from its
source literal and retain the full live host/native relation. -/
theorem first_fortynine_transport
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Ren → Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
      R live framed before after old old' input s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s (R.a 90) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s (R.a 90) 1))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 21) (typedProtoFixed : R.a 21 = 21)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (bound : s.next + 9 + (blockNames Parameter48.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 49 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail) R
        (CellsLive (ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
          TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
          callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172) P.RestStream.micro0.micro0.s48.next (blockNames Parameter48.sourceBody))
        framed before after old old' P.RestStream.micro0.micro0.s49 result ∧
      result.heap.get (R.a Parameter43.sourceAddress) = some (.cell (some (natV 1))) := by
  let fr := NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail
  let live40 := ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
    TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
    callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172
  obtain ⟨s40,hr40,h40,axis40⟩ := first_forty_transport FR R ν₀ ν C₀ C roles ObjRel boundary H N tail
    live framed before after old old' s h rank code proto bufferProtoLive bufferProtoFixed
    typedProtoLive typedProtoFixed arrayProtoLive arrayProtoFixed nativeHandle region (by omega)
  have hn40 : s40.next = s.next+8 := counter_add h h40 8 (by host_kernel_rfl)
  have hb40 : s40.next + (blockNames Parameter48.sourceBody).length ≤ 2^64 := by rw [hn40]; omega
  obtain ⟨result,hr49,h49,v,hv,axis49⟩ := concat_parameter_axis_preserved (NumberRoles ν₀ ν C₀ C) fr R C₀ C
    live40 framed before after old old' s40 h40 hb40 (fun v => v = natV 1) axis40
  subst v
  exact ⟨result,runC_join P.F hr40 hr49,h49,hv⟩

end Host.Load.Run.Full.Ordinary.Prefix
