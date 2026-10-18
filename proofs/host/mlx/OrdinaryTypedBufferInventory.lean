import host.mlx.NativeTypedBufferInventory
import host.ts.renameOrdinary.TypedBufferCase

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.TypedBuffer
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- The actual ordinary source12→13 Int32Array construction retains the full
invariant. Its builtin literal roles come from initialized capture notes. -/
theorem retained_transport (FR : Ren → P.F.S → P.F.S → Prop) {notes : RetainedNotes}
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s) (metadata : NativeCaptureNote)
    (selected : notes.captures.owners 90 = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit (F64.ofNat 4))))
    (protoNote : metadata.roles 1 = some (.literal (.lit (F64.ofNat 21))))
    (protoLive : live 21) (protoFixed : R.a 21 = 21) (bound : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live input.next) framed before after old old' output result ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj input.next)})
        ν₀ ν C₀ C R (LiveAfter live input.next) output result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) ∧
      result.next = s.next+1 ∧ result.ffi = s.ffi := by
  obtain ⟨_,run,post,retained,_,frame,_,native,_,next⟩ := inventory.typedBuffer_step P.F FR h
    90 3126661 constructorObject bufferObject (.obj 90) 117452 0 12 4 21 (F64.ofNat 4) (F64.ofNat 21) metadata
    source_control source_heap source_kind source_buffer source_buffer_kind (by decide +kernel) (by decide +kernel)
    selected codeNote protoNote protoLive protoFixed source_bound bound
  have sourceEq :
      (input.alloc (typedBuffer (eltOfCode 4) 3126661 0 (12 / (eltOfCode 4).size) 21)).2.ret (.obj input.next) = output :=
    source_post
  rw [sourceEq] at post retained
  exact ⟨_,run,post,retained,frame,next,native⟩

end Host.Load.Run.Full.Ordinary.TypedBuffer
