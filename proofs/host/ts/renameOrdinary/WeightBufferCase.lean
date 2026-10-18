import host.ts.renameOrdinary.WeightBufferSteps
import host.ts.RenameRouteDriver
import host.ts.RenameParametricArrayBuffer

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro5 52 2639 as Ordinary.VectorToConcat.WeightShape.BufferNative.object
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape.BufferNative
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

noncomputable def input : St P.F.S := P.RestStream.micro0.micro5.s52
noncomputable def output : St P.F.S := P.RestStream.micro0.micro5.s53

theorem source_control : input.ctl = .call (.obj 2639) .undef
    [.ptr (.ext 5460) 0,natV 0,natV 12] := by host_kernel_rfl
theorem source_heap : input.heap.get 2639 = some (.obj object) := by host_kernel_rfl
theorem source_kind : object.kind = .fn (.native (.ffi .toArrayBuffer) []) := by host_kernel_rfl
theorem source_post :
    (input.alloc (externalBuffer 5460 0 12)).2.ret (.obj input.next) = output := by host_kernel_rfl
theorem source_bound : input.next < 2^64 := by decide +kernel
theorem source_run (C : CSrv) : interpC (step P.F input).run C = some (output,C) := by host_kernel_rfl

/-- The actual weight shape region is converted by the original Bun buffer builtin. -/
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' input s)
    (offsetRole : (Annotated.Value.literal (.lit (F64.ofNat 0))).Holds ν C R (callArgument s.ctl 1))
    (countRole : (Annotated.Value.literal (.lit (F64.ofNat 12))).Holds ν C R (callArgument s.ctl 2))
    (hp : live aArrayBufferProto) (hpr : R.a aArrayBufferProto = aArrayBufferProto)
    (ht : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (LiveAfter live input.next) framed before after old old' output result := by
  obtain ⟨_,hr,hpost⟩ := step_toArrayBuffer_from_source P.F NR FR R C₀ C ν live framed
    before after old old' input s h 2639 object [] .undef 5460 0 0 12
    (F64.ofNat 0) (F64.ofNat 12) source_control source_heap source_kind
    (by decide +kernel) (by decide +kernel) offsetRole countRole hp hpr source_bound ht
  rw [Nat.zero_add,source_post] at hpost
  exact ⟨_,hr,hpost⟩

/-- The actual target builtin allocates one fresh object and preserves every
older heap address, including the initialized typed-constructor metadata. -/
theorem transport_heap_frame (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' input s)
    (offsetRole : (Annotated.Value.literal (.lit (F64.ofNat 0))).Holds ν C R (callArgument s.ctl 1))
    (countRole : (Annotated.Value.literal (.lit (F64.ofNat 12))).Holds ν C R (callArgument s.ctl 2))
    (hp : live aArrayBufferProto) (hpr : R.a aArrayBufferProto = aArrayBufferProto)
    (ht : s.next < 2^64) (run : interpC (step P.F s).run C = some (result,C)) :
    (∀ a, a < s.next → result.heap.get a = s.heap.get a) ∧
      result.next = s.next + 1 ∧ result.ffi = s.ffi ∧ result.stack = s.stack := by
  obtain ⟨_,hr,_⟩ := step_toArrayBuffer_from_source P.F NR FR R C₀ C ν live framed
    before after old old' input s h 2639 object [] .undef 5460 0 0 12
    (F64.ofNat 0) (F64.ofNat 12) source_control source_heap source_kind
    (by decide +kernel) (by decide +kernel) offsetRole countRole hp hpr source_bound ht
  have he := congrArg Prod.fst (Option.some.inj (run.symm.trans hr))
  dsimp only at he
  rw [he]
  exact ⟨fun a ha => alloc_ret_heap_below s _ _ ht a ha,rfl,rfl,rfl⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape.BufferNative
