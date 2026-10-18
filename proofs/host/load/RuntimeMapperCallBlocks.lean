import host.load.RuntimeMapperBodyBlocks
import host.load.RuntimeGetterReturnBlocks
import host.load.RuntimeDriver
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RetainedMapperCallBlocks
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_source_step P.F, P.RestStream.micro0.micro1.s25 using P.RestStream.micro0.micro1.S25 to P.RestStream.micro0.micro1.s26 using P.RestStream.micro0.micro1.S26 as Lookup125
host_source_step P.F, P.RestStream.micro0.micro1.s26 using P.RestStream.micro0.micro1.S26 to P.RestStream.micro0.micro1.s27 using P.RestStream.micro0.micro1.S27 as Enter126
host_source_step P.F, P.RestStream.micro0.micro1.s27 using P.RestStream.micro0.micro1.S27 to P.RestStream.micro0.micro1.s28 using P.RestStream.micro0.micro1.S28 as Body127
host_source_step P.F, P.RestStream.micro0.micro1.s28 using P.RestStream.micro0.micro1.S28 to P.RestStream.micro0.micro1.s29 using P.RestStream.micro0.micro1.S29 as Next128
host_source_step P.F, P.RestStream.micro0.micro1.s29 using P.RestStream.micro0.micro1.S29 to P.RestStream.micro0.micro1.s30 using P.RestStream.micro0.micro1.S30 as Guard129

host_retained_theorem callback := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ RetainedMapperBodyBlocks.FirstReceiver.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' RetainedMapperBodyBlocks.FirstReceiver.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live RetainedMapperBodyBlocks.FirstReceiver.input s)
    (fnRole thisRole role : Annotated.Value) (extraRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj RetainedMapperEntryBlocks.First119.sourceOwner::extraRoles))
    (fieldNote : notes.privates.owners RetainedGetterBlocks.First130.sourceOwner =
      some ⟨RetainedGetterBlocks.First130.sourceBrand,RetainedGetterBlocks.First130.sourceHandleName,role⟩)
    (bound : s.next+3 ≤ 2^64) => by
  host_retained_chain P.F, [RetainedMapperBodyBlocks.FirstReceiver.retained_transport,
    Lookup125.retained_transport,Enter126.retained_transport,Body127.retained_transport,Next128.retained_transport,Guard129.retained_transport,
    RetainedGetterReturns.First130.retained_transport,RetainedMapperBodyBlocks.FirstReturn.retained_transport] using h, inventory, inst
host_assert_retained_schema callback, 26

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema callback, 27

end Host.Load.Run.Full.Ordinary.RetainedMapperCallBlocks
