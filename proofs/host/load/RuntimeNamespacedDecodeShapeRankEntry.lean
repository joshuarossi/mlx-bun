import host.load.RuntimeNamespacedDecodeRankResult
import host.load.RuntimeNamespacedDecodeShapeArrays
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi.Annotated
host_retained_theorem slice_to_shape_rank_call := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ AfterSlice.Block1087.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R live framed before after old old'
      P.RestStream.micro0.micro10.s87 s)
    (inventory : RetainedInventory (notes.nativeHandleResult 3126780 29373)
      ν₀ ν C₀ C R live P.RestStream.micro0.micro10.s87 s)
    (a b c d e callBoundary returnHead : Annotated.Tree) (caller : List Annotated.Tree)
    (fnRole thisRole : Annotated.Value)
    (stackNotes : notes.runtime.stack = a::b::c::d::e::callBoundary::
      argumentFrameNote false Plan1100.Block21.sourceKind fnRole thisRole []
        Plan1100.Block21.sourceRest Plan1100.Block21.sourceEnv::returnHead::caller)
    (pointerEntry : notes.runtime.cells.cells AfterSlice.Block1098.address = some (.ptr (.js 3126780) 0))
    (budget : s.next+32 ≤ 2^64)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) (signatureFrame : ¬ framed Meta1219.types) (owned : H Meta1219.handle) => by
  have earlier := slice_to_shape_arrays notes ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s inst state inventory
    a b c d e callBoundary returnHead caller fnRole thisRole stackNotes pointerEntry budget objectLive objectFixed arrayLive arrayFixed globalLive globalFixed signatureFrame owned
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_retained_chain_after P.F, [Plan1220.Block25.retained_transport, Plan1220.Block26.retained_transport, Plan1220.Block27.retained_transport, Plan1220.Block28.retained_transport, Plan1220.Block29.retained_transport, Plan1220.Block30.retained_transport, Plan1220.Block31.retained_transport, Plan1220.Block32.retained_transport, Plan1220.Block33.retained_transport, Plan1220.Block34.retained_transport, Plan1220.Block35.retained_transport, Plan1220.Block36.retained_transport, Plan1220.Block37.retained_transport, Plan1220.Block38.retained_transport, Plan1220.Block39.retained_transport, Plan1220.Block40.retained_transport, Plan1220.Block41.retained_transport, Plan1220.Block42.retained_transport, Plan1220.Block43.retained_transport, Plan1220.Block44.retained_transport, Plan1220.Block45.retained_transport, Plan1220.Block46.retained_transport, Plan1220.Block47.retained_transport, Plan1220.Block64.retained_transport] using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema slice_to_shape_rank_call, 198

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema slice_to_shape_rank_call, 199
end Host.Load.Run.Full.Ordinary.NamespacedDecode
