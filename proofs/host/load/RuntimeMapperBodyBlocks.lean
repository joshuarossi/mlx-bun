import host.ts.RenameRetainedMapperBodyFrontend
import host.load.RuntimeMapperEntryBlocks
import host.mlx.OrdinaryVectorStates
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RetainedMapperBodyBlocks
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_mapper_receiver RetainedMapperEntryBlocks.First119
  to P.RestStream.micro0.micro1.s25 using P.RestStream.micro0.micro1.S25 as FirstReceiver
host_retained_mapper_receiver RetainedMapperEntryBlocks.Second176
  to P.RestStream.micro0.micro1.s82 using P.RestStream.micro0.micro1.S82 as SecondReceiver
host_retained_mapper_return P.F, P.RestStream.micro0.micro1.s43 using P.RestStream.micro0.micro1.S43
  to P.RestStream.micro0.micro1.s45 using P.RestStream.micro0.micro1.S45 as FirstReturn
host_retained_mapper_return P.F, P.RestStream.micro0.micro2.s0 using P.RestStream.micro0.micro2.S0
  to P.RestStream.micro0.micro2.s2 using P.RestStream.micro0.micro2.S2 as SecondReturn

host_retained_theorem first_receiver := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ FirstReceiver.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' FirstReceiver.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live FirstReceiver.input s)
    (fnRole thisRole : Annotated.Value) (extraRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj RetainedMapperEntryBlocks.First119.sourceOwner::extraRoles))
    (bound : s.next+3 ≤ 2^64) => by
  host_retained_chain P.F, [FirstReceiver.retained_transport] using h, inventory, inst
host_assert_retained_schema first_receiver, 6

host_retained_theorem first_return := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ FirstReturn.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' FirstReturn.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live FirstReturn.input s)
    (role : Annotated.Value) (retNote callNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = retNote::callNote::callerNotes) => by
  host_retained_chain P.F, [FirstReturn.retained_transport] using h, inventory, inst
host_assert_retained_schema first_return, 2

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_mapper_receiver RetainedMapperEntryBlocks.First119 to P.RestStream.micro0.micro1.s26 using P.RestStream.micro0.micro1.S26 as WrongReceiverEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong mapper receiver endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedMapperBodyBlocks
