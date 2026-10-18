import host.ts.renameOrdinary.MapReturn
import host.ts.renameOrdinary.DriverMapTyped

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

def mapTypedLive (live : Nat → Prop) : Nat → Prop :=
  LiveAfter (LiveAfter live MapTyped223.input.next) (MapTyped223.input.next+1)

/-- The actual loop exit, callback return and iterable constructor derive the
native input buffer from the two previously pushed owned handles. -/
theorem map_return_typed (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapExit214.input s)
    (contents : ArrayData s (R.a 3126677)
      [.big (Int.ofNat (R.handle 25732)),.big (Int.ofNat (R.handle 29363))])
    (code : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 0))
    (proto : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s (R.a MapTyped223.sourceFunction) 1))
    (handles : ∀ h ∈ MapTyped223.sourceHandles.map R.handle, h < 2^64)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live MapTyped223.sourceProto) (typedProtoFixed : R.a MapTyped223.sourceProto = MapTyped223.sourceProto)
    (bound : s.next+1 < 2^64) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      StateR NR FR R (mapTypedLive live) framed before after old old' MapTyped223.output result ∧
      (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt result (R.a 3126688)) ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨s223,run223,h223,heap223⟩ := map_return NR FR R C₀ C live framed before after old old' s h
  have next223 : s223.next = s.next := h.target_next_eq h223 (by host_kernel_rfl)
  have contents223 := contents.heap_eq heap223
  have code223 : (Annotated.Value.literal (.lit MapTyped223.sourceCode)).Holds ν C R
      (nativeDataArgument s223 (R.a MapTyped223.sourceFunction) 0) := by
    simpa only [nativeDataArgument,St.obj?,heap223] using code
  have proto223 : (Annotated.Value.literal (.lit MapTyped223.sourceProtoNumber)).Holds ν C R
      (nativeDataArgument s223 (R.a MapTyped223.sourceFunction) 1) := by
    simpa only [nativeDataArgument,St.obj?,heap223] using proto
  obtain ⟨result,run,hpost,buffer,frame⟩ := MapTyped223.transport NR FR R C₀ C ν live framed before after old old'
    s223 h223 contents223 code223 proto223 handles bufferProtoLive bufferProtoFixed typedProtoLive typedProtoFixed
    (by rw [next223]; exact bound)
  have one : runC P.F 1 s223 C = some (result,C) :=
    runC_cons P.F 0 s223 result result C C C (h223.control.isHalt_eq.trans (by host_kernel_rfl)) run rfl
  refine ⟨result,runC_join P.F run223 one,hpost,buffer,?_⟩
  intro a ha
  rw [frame a (by rw [next223]; exact ha),heap223]

end Host.Load.Run.Full.Ordinary
