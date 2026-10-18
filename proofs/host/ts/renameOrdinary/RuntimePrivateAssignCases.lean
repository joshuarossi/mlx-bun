import host.ts.RenameRuntimeDriverPrivateAssign
import host.ts.renameOrdinary.MlxConstructorBody

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RetainedPrivateAssign
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_private_assign P.F, P.RestStream.micro0.micro3.s86 using P.RestStream.micro0.micro3.S86
  to P.RestStream.micro0.micro3.s87 using P.RestStream.micro0.micro3.S87 as Entry386
host_retained_private_assign P.F, P.RestStream.micro0.micro3.s88 using P.RestStream.micro0.micro3.S88
  to P.RestStream.micro0.micro3.s89 using P.RestStream.micro0.micro3.S89 as Receiver388
host_retained_private_assign P.F, P.RestStream.micro0.micro3.s90 using P.RestStream.micro0.micro3.S90
  to P.RestStream.micro0.micro3.s91 using P.RestStream.micro0.micro3.S91 as Store390

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_retained_private_assign P.F, P.RestStream.micro0.micro3.s90 using P.RestStream.micro0.micro3.S90 to P.RestStream.micro0.micro3.s90 using P.RestStream.micro0.micro3.S90 as WrongPrivateStoreEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong private store endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedPrivateAssign
