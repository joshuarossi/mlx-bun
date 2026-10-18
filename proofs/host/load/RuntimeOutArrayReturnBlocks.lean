import host.ts.RenameRetainedOutArrayReturnFrontend
import host.ts.RenameRetainedChain
import host.load.RuntimeNativeCases
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RetainedOutArrayReturns
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_outArray_return P.F, P.RestStream.micro0.micro3.s56 using P.RestStream.micro0.micro3.S56
  to P.RestStream.micro0.micro3.s71 using P.RestStream.micro0.micro3.S71 as First356

host_retained_theorem success_summary := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ First356.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' First356.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live First356.input s)
    (role : Annotated.Value) (blockNote scopeNote callNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
    (statusNote : notes.runtime.cells.cells First356.sourceStatusCell = some (.literal (.lit (.zero false))))
    (handleNote : notes.runtime.cells.cells First356.sourceHandleCell = some role)
    (stackNotes : notes.runtime.stack = blockNote::scopeNote::callNote::callerNotes) => by
  host_retained_chain P.F, [First356.retained_transport] using h, inventory, inst
host_assert_retained_schema success_summary, 15

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema success_summary, 16

open Lean Elab Command in
run_cmd do
  for (name,input,endpoint) in [
      ("WrongEndpoint","First356.input","P.RestStream.micro0.micro3.s72"),
      ("WrongResult","First356.input","{P.RestStream.micro0.micro3.s71 with ctl := .ret .undef}"),
      ("WrongStatus","First356.input.setCell First356.sourceStatusCell (natV 1)","First356.output")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_outArray_return P.F, ({input}) using P.RestStream.micro0.micro3.S56 to ({endpoint}) using P.RestStream.micro0.micro3.S71 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect outArray status/endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedOutArrayReturns
