import host.ts.RenameRuntimeDriverPrivateObjectRead
import host.ts.renameOrdinary.MlxRegistrySteps
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RetainedPrivateObject

host_retained_private_object P.F, P.RestStream.micro0.micro4.s3 using P.RestStream.micro0.micro4.S3
  to P.RestStream.micro0.micro4.s4 using P.RestStream.micro0.micro4.S4 as Token403

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_private_object P.F, P.RestStream.micro0.micro4.s3 using P.RestStream.micro0.micro4.S3 to P.RestStream.micro0.micro4.s3 using P.RestStream.micro0.micro4.S3 as WrongPrivateObjectEndpoint"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong private-object endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedPrivateObject
