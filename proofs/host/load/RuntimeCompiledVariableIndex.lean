import host.load.RuntimeCompiledArgumentEntryPlan
import host.ts.RenameRetainedVariableIndexAssignmentStep
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_variable_index_assignment P.F, Region.s126
  using (Region.S126.substitute LoopVariables.oracleVariables)
  to Region.s131 using (Region.S131.substitute LoopVariables.oracleVariables) as VariableIndex126

theorem variable_index_is_zero : VariableIndex126.index = 0 := by host_kernel_rfl

/-- error: variable indexed assignment: expected assignment -/
#guard_msgs in
host_retained_variable_index_assignment P.F, Region.s127
  using (Region.S127.substitute LoopVariables.oracleVariables)
  to Region.s131 using (Region.S131.substitute LoopVariables.oracleVariables) as WrongVariableIndexControl

open Lean Elab Command in
run_cmd do
  let saved : Command.State ← get
  let count := saved.messages.toList.length
  let mut rendered := ""
  try
    Parametric.Driver.emit "host_retained_variable_index_assignment P.F, Region.s126 using (Region.S126.substitute LoopVariables.oracleVariables) to Region.s132 using (Region.S132.substitute LoopVariables.oracleVariables) as WrongVariableIndexEndpoint"
  catch exception => rendered := rendered ++ (← exception.toMessageData.toString)
  for message in (← get).messages.toList.drop count do
    rendered := rendered ++ "\n" ++ (← message.data.toString)
  for tag in [`input,`source_control,`retained_transport] do
    if (← getEnv).contains ((← getCurrNamespace) ++ `WrongVariableIndexEndpoint ++ tag) then
      throwError "indexed assignment rejection leaked a partial declaration"
  set saved
  unless (rendered.splitOn "(kernel) declaration type mismatch").length > 1 do
    throwError "indexed assignment endpoint was not rejected by the kernel: {rendered}"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
