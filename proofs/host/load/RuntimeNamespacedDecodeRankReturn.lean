import host.load.RuntimeNamespacedDecodeRankResult
import host.load.RuntimeNumberReturnBlock
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated Host.Mlx.Ffi.Annotated
host_retained_theorem slice_to_rank_return := fun
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
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) (signatureFrame : ¬ framed Meta1219.types) (owned : H Meta1219.handle) => by
  have earlier := slice_to_rank notes ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s inst state inventory
    a b c d e callBoundary returnHead caller fnRole thisRole stackNotes pointerEntry budget objectLive objectFixed globalLive globalFixed signatureFrame owned
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  have numberRole : IntegerNumberRole (.ordinaryBig (Int.ofNat (len Meta1219.node.shape)))
      (.lit (F64.ofInt (Int.ofNat (len Meta1219.node.shape)))) := .ordinary _
  host_retained_chain_after P.F, [NumberReturn.Rank1220.retained_transport] using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema slice_to_rank_return, 139

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema slice_to_rank_return, 140
end Host.Load.Run.Full.Ordinary.NamespacedDecode
