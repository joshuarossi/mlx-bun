import host.ts.RenameRetainedGetterFrontend
import host.ts.RenameRetainedChain
import host.ts.renameOrdinary.MapBodyStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedGetterBlocks

host_retained_getter_body P.F, P.RestStream.micro0.micro1.s30 using P.RestStream.micro0.micro1.S30
  to P.RestStream.micro0.micro1.s39 using P.RestStream.micro0.micro1.S39 as First130
host_retained_getter_body P.F, P.RestStream.micro0.micro1.s87 using P.RestStream.micro0.micro1.S87
  to P.RestStream.micro0.micro1.s96 using P.RestStream.micro0.micro1.S96 as Second187

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
host_retained_theorem first_block := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ First130.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' First130.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live First130.input s)
    (role : Annotated.Value) (ifNote blockNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
    (thisNote : notes.runtime.cells.cells First130.sourceThisCell = some (.obj First130.sourceOwner))
    (fieldNote : notes.privates.owners First130.sourceOwner = some ⟨First130.sourceBrand,First130.sourceHandleName,role⟩)
    (stackNotes : notes.runtime.stack = ifNote::blockNote::tailNotes) => by
  host_retained_chain P.F, [First130.retained_transport] using h, inventory, inst
host_assert_retained_schema first_block, 9

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema first_block, 10

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_getter_body P.F, P.RestStream.micro0.micro1.s30 using P.RestStream.micro0.micro1.S30 to P.RestStream.micro0.micro1.s40 using P.RestStream.micro0.micro1.S40 as WrongEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong getter-block endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedGetterBlocks
