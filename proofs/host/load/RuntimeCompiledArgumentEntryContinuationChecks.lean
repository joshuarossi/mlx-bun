import host.load.RuntimeCompiledArgumentEntryWrapper
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.ContinuationChecks
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem numeric_role_rejected (n : NumV) (role : Annotated.Value) :
    ¬ StructuralValue (.num n) role := by intro h; cases h

theorem bigint_role_rejected (n : Int) (role : Annotated.Value) :
    ¬ StructuralValue (.big n) role := by intro h; cases h

/-- error: expected logical-not frame -/
#guard_msgs in
host_compiled_argument_not_step P.F, Region.s38 using (Region.S38.substitute LoopVariables.oracleVariables)
  to Region.s39 using (Region.S39.substitute LoopVariables.oracleVariables) as WrongNotFrame

-- Both commands must reject an incorrect actual-source endpoint in the kernel,
-- and roll back every declaration emitted while attempting that command.
open Lean Elab Command in
run_cmd do
  for (command,input,output,stem) in [
      ("host_compiled_argument_not_step",35,37,`WrongNotEndpoint),
      ("host_retained_structural_member",38,40,`WrongMemberEndpoint)] do
    let saved : Command.State ← get
    let count := saved.messages.toList.length
    let mut rendered := ""
    let oracle := "LoopVariables.oracleVariables"
    try
      Parametric.Driver.emit s!"{command} P.F, Region.s{input} using (Region.S{input}.substitute {oracle}) to Region.s{output} using (Region.S{output}.substitute {oracle}) as {stem}"
    catch exception =>
      rendered := rendered ++ (← exception.toMessageData.toString)
    for message in (← get).messages.toList.drop count do
      rendered := rendered ++ "\n" ++ (← message.data.toString)
    let names := [stem ++ `input,stem ++ `source_control,stem ++ `source_post,stem ++ `retained_transport]
    for name in names do
      if (← getEnv).contains ((← getCurrNamespace) ++ name) then
        throwError "wrong endpoint left a partial declaration: {name}"
    set saved
    unless (rendered.splitOn "(kernel) declaration type mismatch").length > 1 do
      throwError s!"wrong endpoint was not rejected by the kernel:\n{rendered.take 1500}"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry.ContinuationChecks
