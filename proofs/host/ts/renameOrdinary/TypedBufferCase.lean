import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriver
import host.ts.RenameParametricTypedBuffer

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro0 12 90 as Ordinary.TypedBuffer.constructorObject
host_transport_object P.RestStream.micro0.micro0 12 3126661 as Ordinary.TypedBuffer.bufferObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.TypedBuffer
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

noncomputable def input : St P.F.S := P.RestStream.micro0.micro0.s12
noncomputable def output : St P.F.S := P.RestStream.micro0.micro0.s13

theorem source_control : input.ctl = .construct (.obj 90) [.obj 3126661] (.obj 90) := by host_kernel_rfl
theorem source_heap : input.heap.get 90 = some (.obj constructorObject) := by host_kernel_rfl
theorem source_kind : constructorObject.kind =
    .fn (.native (.buf .typedCtor) [natV 4,natV 21]) := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126661 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .extBuf 117452 0 12 := by host_kernel_rfl
theorem source_post :
    (input.alloc (typedBuffer .i32 3126661 0 3 21)).2.ret (.obj input.next) = output := by host_kernel_rfl
theorem source_bound : input.next < 2^64 := by decide +kernel
theorem source_run (C : CSrv) : interpC (step P.F input).run C = some (output,C) := by host_kernel_rfl

/-- The actual Int32Array constructor creates the rank-three view used by
shape spread. Builtin element-code/prototype annotations must be carried from
initialization; the target backing buffer and its length follow from StateR. -/
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' input s)
    (codeRole : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s (R.a 90) 0))
    (protoRole : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s (R.a 90) 1))
    (hp : live 21) (hpr : R.a 21 = 21) (ht : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (LiveAfter live input.next) framed before after old old' output result := by
  obtain ⟨_,hr,hpost⟩ := step_construct_typedBuffer_from_source P.F NR FR R C₀ C ν live framed
    before after old old' input s h 90 3126661 constructorObject bufferObject (.obj 90)
    117452 0 12 4 21 (F64.ofNat 4) (F64.ofNat 21) source_control source_heap source_kind
    source_buffer source_buffer_kind (by decide +kernel) (by decide +kernel)
    codeRole protoRole hp hpr source_bound ht
  change StateR NR FR R (LiveAfter live input.next) framed before after old old'
    ((input.alloc (typedBuffer .i32 3126661 0 3 21)).2.ret (.obj input.next)) _ at hpost
  rw [source_post] at hpost
  exact ⟨_,hr,hpost⟩

end Host.Load.Run.Full.Ordinary.TypedBuffer
