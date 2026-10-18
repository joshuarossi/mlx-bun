import host.ts.renameOrdinary.ConcatReadPrefix
import host.ts.RenameParametricBufferRead
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro3 52 2640 as Ordinary.VectorToConcat.ReadHandle352.functionObject
host_transport_object P.RestStream.micro0.micro3 52 3126700 as Ordinary.VectorToConcat.ReadHandle352.bufferObject
end Host.Load.Run.Full
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.ReadHandle352
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro3.s52
noncomputable def output : St LSt := P.RestStream.micro0.micro3.s53
noncomputable def sourceThis : Val := match input.ctl with | .call _ v _ => v | _ => .undef
theorem source_control : input.ctl = .call (.obj 2640) sourceThis [.ptr (.js 3126700) 0,.num zeroN] := by host_kernel_rfl
theorem source_function : input.heap.get 2640 = some (.obj functionObject) := by host_kernel_rfl
theorem source_kind : functionObject.kind = .fn (.native (.ffi .readU64) []) := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126700 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 29372)) 8 0) := by host_kernel_rfl
theorem source_post : input.ret (.big (Int.ofNat 29372)) = output := by host_kernel_rfl

/-- The actual Bun read observes exactly the owned handle written by concat.
Target function dispatch, pointer, buffer and read are derived from the source. -/
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (offset : (Annotated.Value.literal (.lit (F64.zero false))).Holds ν C R (callArgument s.ctl 1))
    (slot : (slotKindRole 29372).Holds ν C R (objectKindAt s (R.a 3126700))) :
    interpC (step P.F s).run C = some (s.ret (.big (Int.ofNat (R.handle 29372))),C) ∧
      StateR NR FR R live framed before after old old' output (s.ret (.big (Int.ofNat (R.handle 29372)))) := by
  obtain ⟨_,run,related⟩ := step_readU64_buffer_from_source P.F NR FR R C₀ C ν live framed before after old old' input s h
    2640 3126700 29372 functionObject bufferObject [] sourceThis source_control source_function source_kind source_buffer source_buffer_kind offset slot
  exact ⟨run,source_post ▸ related⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.ReadHandle352
