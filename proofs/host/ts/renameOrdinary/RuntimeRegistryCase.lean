import host.ts.RenameRuntimeDriverRegistry
import host.mlx.OrdinaryFreeStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedRegistry
host_retained_registry P.F, P.RestStream.micro0.micro4.s5 using P.RestStream.micro0.micro4.S5
  to P.RestStream.micro0.micro4.s6 using P.RestStream.micro0.micro4.S6 as Registration405

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Host.Ts.Owned.Parametric.Driver.emit "host_retained_registry P.F, P.RestStream.micro0.micro4.s5 using P.RestStream.micro0.micro4.S5 to P.RestStream.micro0.micro4.s6.ret (.bool true) using P.RestStream.micro0.micro4.S6 as WrongResult"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "registration acquired an incorrect result without kernel rejection"
end Host.Load.Run.Full.Ordinary.RetainedRegistry
