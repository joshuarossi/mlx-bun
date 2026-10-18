import host.ts.RenameRuntimeDriverConstructorReturn
import host.ts.renameOrdinary.MlxRegistrySteps

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RetainedConstructorReturn
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_constructor_return P.F, P.RestStream.micro0.micro4.s8 using P.RestStream.micro0.micro4.S8
  to P.RestStream.micro0.micro4.s9 using P.RestStream.micro0.micro4.S9 as Return408

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Parametric.Driver.emit "host_retained_constructor_return P.F, P.RestStream.micro0.micro4.s8 using P.RestStream.micro0.micro4.S8 to P.RestStream.micro0.micro4.s8 using P.RestStream.micro0.micro4.S8 as WrongReturnEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong constructor-return endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedConstructorReturn
