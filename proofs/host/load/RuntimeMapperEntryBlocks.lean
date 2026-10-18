import host.ts.RenameRetainedMapperFrontend
import host.ts.RenameRetainedChain
import host.ts.renameOrdinary.MapBodyStates
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RetainedMapperEntryBlocks

host_retained_mapper_entry P.F, P.RestStream.micro0.micro1.s19 using P.RestStream.micro0.micro1.S19
  to P.RestStream.micro0.micro1.s23 using P.RestStream.micro0.micro1.S23 as First119
host_retained_mapper_entry P.F, P.RestStream.micro0.micro1.s76 using P.RestStream.micro0.micro1.S76
  to P.RestStream.micro0.micro1.s80 using P.RestStream.micro0.micro1.S80 as Second176

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
host_retained_theorem first_entry := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ First119.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' First119.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live First119.input s)
    (fnRole thisRole : Annotated.Value) (extraRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj First119.sourceOwner::extraRoles))
    (bound : s.next+3 ≤ 2^64) => by
  host_retained_chain P.F, [First119.retained_transport] using h, inventory, inst
host_assert_retained_schema first_entry, 4

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_mapper_entry P.F, P.RestStream.micro0.micro1.s19 using P.RestStream.micro0.micro1.S19 to P.RestStream.micro0.micro1.s24 using P.RestStream.micro0.micro1.S24 as WrongEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong mapper-entry endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedMapperEntryBlocks
