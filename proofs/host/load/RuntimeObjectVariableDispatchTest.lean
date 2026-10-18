import host.load.RuntimeDriver
import host.ts.RenameRetainedChain
import host.mlx.OrdinaryVectorStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RuntimeObjectVariableDispatchTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_source_step P.F, P.RestStream.micro0.micro2.s58 using P.RestStream.micro0.micro2.S58
  to P.RestStream.micro0.micro2.s59 using P.RestStream.micro0.micro2.S59 as Object258

host_retained_theorem current_object := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Object258.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Object258.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Object258.input s) => by
  host_retained_chain P.F, [Object258.retained_transport] using h, inventory, inst

host_assert_retained_schema current_object, 1
end Host.Load.Run.Full.Ordinary.RuntimeObjectVariableDispatchTest
