import host.load.RuntimeNamespacedDecodePlan
import host.mlx.NativeBufferResultFrame
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_theorem slice_to_pointer := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ AfterSlice.Block1087.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro10.s87 s)
    (inventory : RetainedInventory (notes.nativeHandleResult 3126780 29373)
      ν₀ ν C₀ C R live P.RestStream.micro0.micro10.s87 s)
    (a b c d e : Annotated.Tree) (caller : List Annotated.Tree)
    (stackNotes : notes.runtime.stack = a::b::c::d::e::caller)
    (pointerRole : Annotated.Value)
    (pointerEntry : notes.runtime.cells.cells AfterSlice.Block1098.address = some pointerRole)
    (budget : s.next+8 ≤ 2^64) => by
  host_retained_plan_chain P.F, AfterSlice using state, inventory, inst
host_assert_retained_schema slice_to_pointer, 13

end Host.Load.Run.Full.Ordinary.NamespacedDecode
