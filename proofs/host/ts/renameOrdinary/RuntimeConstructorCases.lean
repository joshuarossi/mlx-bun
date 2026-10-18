import host.ts.RenameRuntimeDriverConstructors
import host.ts.renameOrdinary.MlxConstructorBody

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RetainedConstructors
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_constructor P.F, P.RestStream.micro0.micro3.s72 using P.RestStream.micro0.micro3.S72
  to P.RestStream.micro0.micro3.s73 using P.RestStream.micro0.micro3.S73 as Class372

host_retained_constructor P.F, P.RestStream.micro0.micro3.s80 using P.RestStream.micro0.micro3.S80
  to P.RestStream.micro0.micro3.s81 using P.RestStream.micro0.micro3.S81 as Body380

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_retained_constructor P.F, P.RestStream.micro0.micro3.s72 using P.RestStream.micro0.micro3.S72 to P.RestStream.micro0.micro3.s72 using P.RestStream.micro0.micro3.S72 as WrongConstructorEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong constructor endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedConstructors
