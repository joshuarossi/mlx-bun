import host.load.RuntimeOracleSliceStridesPlan
import host.ts.RenameRetainedLiteralArrowFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.SliceLiteralArrow
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_literal_arrow P.F, P.RestStream.micro0.micro8.s38
  using (P.RestStream.micro0.micro8.S38.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro8.s43 using (P.RestStream.micro0.micro8.S43.substitute LoopVariables.oracleVariables)
  as Literal838
host_retained_theorem literal838 := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Literal838.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Literal838.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Literal838.input s)
    (fnRole thisRole : Annotated.Value) (argRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole argRoles)
    (targetBound : s.next+2 ≤ 2^64) => by
  host_retained_chain P.F, [Literal838.retained_transport] using h, inventory, inst
host_assert_retained_schema literal838, 5


end Host.Load.Run.Full.Ordinary.SliceLiteralArrow
