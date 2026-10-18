import host.ts.RenameRuntimeDriverObjectVariable
import host.mlx.OrdinaryVectorStates
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedObjectVariable

host_retained_object_variable P.F, P.RestStream.micro0.micro2.s58 using P.RestStream.micro0.micro2.S58
  to P.RestStream.micro0.micro2.s59 using P.RestStream.micro0.micro2.S59 as Variable258

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_object_variable P.F, P.RestStream.micro0.micro2.s58 using P.RestStream.micro0.micro2.S58 to P.RestStream.micro0.micro2.s58 using P.RestStream.micro0.micro2.S58 as WrongObjectVariableEndpoint"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong object-variable endpoint was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedObjectVariable
