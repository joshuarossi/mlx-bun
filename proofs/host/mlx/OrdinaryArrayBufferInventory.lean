import host.mlx.NativeArrayBufferInventory
import host.ts.renameOrdinary.NativeBufferCase

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.NativeBuffer
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- The authoritative ordinary source10→11 native call, now with the complete
retained invariant. Literal ABI roles come from the preceding call note. -/
theorem retained_transport (FR : Ren → P.F.S → P.F.S → Prop) {notes : RetainedNotes}
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (fnRole thisRole pointerRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole
      [pointerRole,.literal (.lit (F64.ofNat 0)),.literal (.lit (F64.ofNat 12))])
    (protoLive : live aArrayBufferProto) (protoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (bound : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live input.next) framed before after old old' output result ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj input.next)})
        ν₀ ν C₀ C R (LiveAfter live input.next) output result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) ∧
      result.next = s.next+1 ∧ result.ffi = s.ffi := by
  obtain ⟨_,run,post,retained,_,frame,_,native,_,next⟩ := inventory.toArrayBuffer_step P.F FR h
    2639 object [] .undef 117452 0 0 12 (F64.ofNat 0) (F64.ofNat 12) fnRole thisRole pointerRole
    source_control source_heap source_kind (by decide +kernel) (by decide +kernel) note
    protoLive protoFixed source_bound bound
  rw [Nat.zero_add,source_post] at post retained
  exact ⟨_,run,post,retained,frame,next,native⟩

end Host.Load.Run.Full.Ordinary.NativeBuffer
