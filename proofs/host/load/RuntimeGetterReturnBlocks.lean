import host.ts.RenameRetainedGetterReturnFrontend
import host.load.RuntimeGetterBlocks
import host.mlx.OrdinaryVectorStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedGetterReturns

host_retained_getter_return _root_.Host.Load.Run.Full.Ordinary.RetainedGetterBlocks.First130
  to P.RestStream.micro0.micro1.s43 using P.RestStream.micro0.micro1.S43 as First130
host_retained_getter_return _root_.Host.Load.Run.Full.Ordinary.RetainedGetterBlocks.Second187
  to P.RestStream.micro0.micro2.s0 using P.RestStream.micro0.micro2.S0 as Second187

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
host_retained_theorem first_complete := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ First130.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' First130.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live First130.input s)
    (role : Annotated.Value) (ifNote blockNote scopeNote callNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
    (thisNote : notes.runtime.cells.cells RetainedGetterBlocks.First130.sourceThisCell = some (.obj RetainedGetterBlocks.First130.sourceOwner))
    (fieldNote : notes.privates.owners RetainedGetterBlocks.First130.sourceOwner =
      some ⟨RetainedGetterBlocks.First130.sourceBrand,RetainedGetterBlocks.First130.sourceHandleName,role⟩)
    (stackNotes : notes.runtime.stack = ifNote::blockNote::scopeNote::callNote::callerNotes) => by
  host_retained_chain P.F, [First130.retained_transport] using h, inventory, inst
host_assert_retained_schema first_complete, 13

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema first_complete, 14

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_getter_return _root_.Host.Load.Run.Full.Ordinary.RetainedGetterBlocks.First130 to P.RestStream.micro0.micro1.s42 using P.RestStream.micro0.micro1.S42 as LostCallBoundary"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "incorrect getter call return endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedGetterReturns
