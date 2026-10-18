import host.load.RuntimeNamespacedDecodePlan1100
import host.load.RuntimeNamespacedDecodeSliceReturn

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_theorem slice_to_new := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ AfterSlice.Block1087.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
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
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto) => by
  have earlier := slice_to_pointer notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory
    a b c d e (callBoundary::argumentFrameNote false Plan1100.Block21.sourceKind fnRole thisRole []
      Plan1100.Block21.sourceRest Plan1100.Block21.sourceEnv::returnHead::caller)
    stackNotes (.ptr (.js 3126780) 0) pointerEntry (by omega)
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_retained_plan_chain_after P.F, PointerToNew using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema slice_to_new, 35

noncomputable def NewToWrapper.rules := Plan1100.rules.drop 8
host_retained_theorem slice_to_wrapper := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ AfterSlice.Block1087.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
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
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto) => by
  have earlier := slice_to_new notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory
    a b c d e callBoundary returnHead caller fnRole thisRole stackNotes pointerEntry budget objectLive objectFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_retained_plan_chain_after P.F, NewToWrapper using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema slice_to_wrapper, 73

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema slice_to_wrapper, 74

end Host.Load.Run.Full.Ordinary.NamespacedDecode
