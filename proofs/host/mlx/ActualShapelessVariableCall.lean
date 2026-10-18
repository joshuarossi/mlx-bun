import host.mlx.ActualShapelessVariablePlan
import host.mlx.NativeCachedFreshRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Shapeless.Variable
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The actual shapeless callable reuses its checked source graph with varying
leading dimensions, including its null output slot. Current annotations and
policy derive the entire original target cached call, fresh vector handle,
write bytes, strong native post and producer closure. No source plan, future
signature, target geometry or target output role is an incoming premise. -/
theorem cached_call_from_current {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) (leading : Shape) (objects : Nat → Object)
    {roots H : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N0 tail source target)
    (policy : ProducerAnnotations roots H N0 (roles base leading) objects)
    (closureLive : H 18194) (vectorLive : H 18195) (nullLive : H 0)
    (targetNodes : target.nnext + trace.order.length < 2^64) (targetHandles : target.next < 2^64)
    (buffer offset : Nat) :
    ∃ final' : Host.Mlx.Ffi.St,
      Host.Mlx.Ffi.call source chars!"mlx_closure_apply" [output buffer offset,.big (Int.ofNat 18194),.big (Int.ofNat 18195)] =
        okW (s8.newObj (.vec [17783])).2 status0 [u64Write buffer offset s8.next] ∧
      Host.Mlx.Ffi.call target chars!"mlx_closure_apply"
          [output (R.a buffer) offset,.big (Int.ofNat (R.handle 18194)),.big (Int.ofNat (R.handle 18195))] =
        okW (final'.newObj (.vec ([17783].map R.node))).2 status0 [u64Write (R.a buffer) offset final'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (roles base leading) ν₀ ν C₀ C R boundary)
        (ObjectRel (objectWrite objects s8.next (.vec [17783])) ν₀ ν C₀ C R)
        (fun i => i = s8.next ∨ H i) N8 tail (s8.newObj (.vec [17783])).2 (final'.newObj (.vec ([17783].map R.node))).2 ∧
      ProducerAnnotations roots (fun i => i = s8.next ∨ H i) N8 (roles base leading)
        (objectWrite objects s8.next (.vec [17783])) ∧
      ProducerSupport roots (fun i => i = s8.next ∨ H i) N8 (s8.newObj (.vec [17783])).2 ∧
      ListR (Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R) (cellParts .u64 (.big (Int.ofNat s8.next)) 8 0)
        (cellParts .u64 (.big (Int.ofNat final'.next)) 8 0) := by
  have signature := policy.shapeless_signature h 18194 281474976715599 18195 payload trace inputs
    closureLive vectorLive source_closure source_vector metadata metadata source_trace_inputs source_real_inputs rfl
  have keys : listSupport (fun p : Nat × Nat => p.1 < s8.nnext) m8 := by
    change listSupport (fun p : Nat × Nat => p.1 < 17784)
      [(15272,17783),(15271,17782),(15270,17781),(15268,17780),(15267,17779),(15266,17778),(15265,17777),(15262,1318),(15263,15245),(15264,1319)]
    dsimp [listSupport]; decide +kernel
  have outputs : listSupport (· < s8.nnext) trace.outs := by change 15272 < 17784 ∧ True; decide +kernel
  have targetSlot : slotOf (output (R.a buffer) offset) = some (R.a buffer,offset,R.handle 0) := by
    rw [h.handleZero]
    exact CachedKernel.output_slot (R.a buffer) offset
  have result := h.cached_fresh_signature policy 18194 18195 281474976715599 buffer offset 0 payload true trace inputs m8
    (output buffer offset) (output (R.a buffer) offset) closureLive vectorLive nullLive source_closure source_vector source_null_object
    (CachedKernel.output_slot buffer offset) targetSlot signature metadata metadata source_trace_inputs source_real_inputs
    (plan0 base leading) keys outputs (by change 17777+8 < 2^64; decide +kernel) targetNodes
    (by change 22018 < 2^64; decide +kernel) targetHandles
  have sameOutputs : trace.outs.map (substOf m8) = [17783] := by rfl
  simpa only [sameOutputs] using result

end Host.Load.Run.Full.Shapeless.Variable
