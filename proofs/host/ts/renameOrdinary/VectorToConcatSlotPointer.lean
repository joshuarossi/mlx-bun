import host.ts.renameOrdinary.VectorToConcatArray
import host.ts.renameOrdinary.VectorToConcatPointerPath
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- The real native null initializer, BigUint64Array conversion and ptr call
are composed. Both the resulting pointer and its null-slot annotation are
derived from the initial state. -/
theorem initialize_slot_pointer (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' ArrayCall.input s)
    (signatureFrame : ¬ framed 4253)
    (code : (Annotated.Value.literal (.lit (F64.ofNat 9))).Holds ν C R (nativeDataArgument s (R.a 95) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 26))).Holds ν C R (nativeDataArgument s (R.a 95) 1))
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 26) (typedProtoFixed : R.a 26 = 26)
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 15 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
        R (LiveAfter (LiveAfter (LiveAfter live Array296.input.next) Typed298.input.next) (Typed298.input.next+1))
        framed before after old old' Pointer309.output result ∧
      result.ctl = .ret (.ptr (.js (R.a 3126700)) 0) ∧
      (slotKindRole 0).Holds ν C R (objectKindAt result (R.a 3126700)) := by
  obtain ⟨s299,hr295,h299,slot299⟩ := initialize_null_slot ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s h signatureFrame code proto arrayProtoLive arrayProtoFixed
    bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed bound
  have next299 : s299.next = s.next+3 := h.target_next_add h299 3 (by host_kernel_rfl)
  have bound299 : s299.next ≤ 2^64 := by rw [next299]; exact bound
  obtain ⟨result,hr299,h310,hc310,heap310⟩ := slot_pointer_transport (NumberRoles ν₀ ν C₀ C)
    (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host) R C₀ C
    (LiveAfter (LiveAfter (LiveAfter live Array296.input.next) Typed298.input.next) (Typed298.input.next+1))
    framed before after old old' s299 h299 bound299
  have slot310 : (slotKindRole 0).Holds ν C R (objectKindAt result (R.a 3126700)) := by
    have he : objectKindAt result (R.a 3126700) = objectKindAt s299 (R.a 3126700) := by
      simp only [objectKindAt,St.obj?,heap310]
    rw [he]
    exact slot299
  exact ⟨result,runC_join P.F (m := 4) (n := 11) hr295 hr299,h310,hc310,slot310⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
