import host.ts.RenameRuntimeDriverMlxConstructor
import host.ts.renameOrdinary.MlxRegistrySteps

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RetainedMlxConstructor

host_retained_mlx_constructor P.F, P.RestStream.micro0.micro3.s72 using P.RestStream.micro0.micro3.S72
  to P.RestStream.micro0.micro4.s9 using P.RestStream.micro0.micro4.S9 as Constructor372

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_mlx_constructor P.F, P.RestStream.micro0.micro3.s72 using P.RestStream.micro0.micro3.S72 to P.RestStream.micro0.micro4.s8 using P.RestStream.micro0.micro4.S8 as WrongMlxConstructorEndpoint"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong MLXArray constructor endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedMlxConstructor
