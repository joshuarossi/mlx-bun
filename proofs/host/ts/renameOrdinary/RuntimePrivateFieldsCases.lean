import host.ts.RenameRuntimeDriverPrivateFields
import host.ts.renameOrdinary.MlxConstructorBody

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RetainedPrivateFields
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_private_fields P.F, P.RestStream.micro0.micro3.s73 using P.RestStream.micro0.micro3.S73
  to P.RestStream.micro0.micro3.s74 using P.RestStream.micro0.micro3.S74 as Fields373

host_retained_private_fields P.F, P.RestStream.micro0.micro3.s75 using P.RestStream.micro0.micro3.S75
  to P.RestStream.micro0.micro3.s76 using P.RestStream.micro0.micro3.S76 as Disposed375

host_retained_private_fields P.F, P.RestStream.micro0.micro3.s77 using P.RestStream.micro0.micro3.S77
  to P.RestStream.micro0.micro3.s78 using P.RestStream.micro0.micro3.S78 as Token377

host_retained_private_fields P.F, P.RestStream.micro0.micro3.s79 using P.RestStream.micro0.micro3.S79
  to P.RestStream.micro0.micro3.s80 using P.RestStream.micro0.micro3.S80 as Pins379

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_retained_private_fields P.F, P.RestStream.micro0.micro3.s73 using P.RestStream.micro0.micro3.S73 to P.RestStream.micro0.micro3.s73 using P.RestStream.micro0.micro3.S73 as WrongPrivateFieldEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong private-field endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedPrivateFields
