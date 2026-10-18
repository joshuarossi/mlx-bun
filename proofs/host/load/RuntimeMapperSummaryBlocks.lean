import host.ts.RenameRetainedMapperCallFrontend
import host.ts.RenameRetainedChain
import host.ts.renameOrdinary.MapBodyStates
import host.mlx.OrdinaryVectorStates
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RetainedMapperSummaries
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_mapper_call P.F, P.RestStream.micro0.micro1.s19 using P.RestStream.micro0.micro1.S19
  to P.RestStream.micro0.micro1.s45 using P.RestStream.micro0.micro1.S45 as First119
host_retained_mapper_call P.F, P.RestStream.micro0.micro1.s76 using P.RestStream.micro0.micro1.S76
  to P.RestStream.micro0.micro2.s2 using P.RestStream.micro0.micro2.S2 as Second176

host_retained_theorem first_summary := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ First119.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' First119.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live First119.input s)
    (fnRole thisRole role : Annotated.Value) (extraRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj First119.sourceOwner::extraRoles))
    (fieldNote : notes.privates.owners First119.sourceOwner = some ⟨First119.sourceBrand,First119.sourceHandleName,role⟩)
    (budget : s.next+3 ≤ 2^64) => by
  host_retained_chain P.F, [First119.retained_transport] using h, inventory, inst
host_assert_retained_schema first_summary, 26

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema first_summary, 27

host_retained_theorem second_summary := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Second176.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Second176.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Second176.input s)
    (fnRole thisRole role : Annotated.Value) (extraRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj Second176.sourceOwner::extraRoles))
    (fieldNote : notes.privates.owners Second176.sourceOwner = some ⟨Second176.sourceBrand,Second176.sourceHandleName,role⟩)
    (budget : s.next+3 ≤ 2^64) => by
  host_retained_chain P.F, [Second176.retained_transport] using h, inventory, inst
host_assert_retained_schema second_summary, 26

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","P.RestStream.micro0.micro1.s46"),
      ("WrongResult","{P.RestStream.micro0.micro1.s45 with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_mapper_call P.F, P.RestStream.micro0.micro1.s19 using P.RestStream.micro0.micro1.S19 to {endpoint} using P.RestStream.micro0.micro1.S45 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect mapper call endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedMapperSummaries
