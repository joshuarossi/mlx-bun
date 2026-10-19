import host.mlx.NativeCachedFrontend
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_retained_cached P.F, P.RestStream.micro0.micro23.s82 using
  (P.RestStream.micro0.micro23.S82.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro23.s83 using
  (P.RestStream.micro0.micro23.S83.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Cached2382

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let count := saved.messages.toList.length
  let mut rejected := false
  try
    Host.Ts.Owned.Parametric.Driver.emit
      "host_retained_cached P.F, P.RestStream.micro0.micro23.s82 using (P.RestStream.micro0.micro23.S82.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) to P.RestStream.micro0.micro23.s83 using ({P.RestStream.micro0.micro23.S83.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables with tab := []}) as WrongNumberTable"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "(kernel) application type mismatch").length > 1
  for message in (← get).messages.toList.drop count do
    if ((← message.data.toString).splitOn "(kernel) application type mismatch").length > 1 then rejected := true
  set saved
  unless rejected do throwError "cached replay negative did not reject the changed numeric table in the kernel"
end Host.Load.Run.Full.Ordinary.NamespacedDecode
