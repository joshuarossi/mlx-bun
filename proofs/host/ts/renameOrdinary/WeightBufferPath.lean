import host.ts.renameOrdinary.WeightBufferPrefix
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- Pointer evaluation, zero offset, rank arithmetic, and buffer allocation
form one continuous original-source execution. Both ABI literal roles are
produced by that execution, and all older heap fields are framed. -/
theorem weight_buffer_transport (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' BufferPointer.input s)
    (rank : s.heap.get (R.a ByteRank.address) = some (.cell (some (natV 3))))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (bound : s.next < 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live BufferNative.input.next)
        framed before after old old' BufferNative.output result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) ∧
      result.next = s.next+1 ∧ result.stack = s.stack.tail := by
  obtain ⟨s52,run10,h52,offset,count,heap52,next52,stack52,_⟩ := buffer_arguments_transport FR R ν₀ ν C₀ C live framed
    before after old old' s h rank
  have bound52 : s52.next < 2^64 := next52 ▸ bound
  obtain ⟨result,run52,h53⟩ := BufferNative.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν live framed before after old old'
    s52 h52 offset count bufferProtoLive bufferProtoFixed bound52
  obtain ⟨heap53,next53,_,stack53⟩ := BufferNative.transport_heap_frame (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν live framed before after old old'
    s52 result h52 offset count bufferProtoLive bufferProtoFixed bound52 run52
  refine ⟨result,?_,h53,?_,next53.trans (congrArg (fun n => n+1) next52),stack53.trans stack52⟩
  · have run1 : runC P.F 1 s52 C = some (result,C) := by
      apply runC_cons P.F 0 s52 result result C C C (h52.control.isHalt_eq.trans (by host_kernel_rfl)) run52
      rfl
    exact runC_join P.F (m:=10) (n:=1) run10 run1
  · intro a alive
    exact (heap53 a (next52 ▸ alive)).trans (congrArg (fun heap => heap.get a) heap52)
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
