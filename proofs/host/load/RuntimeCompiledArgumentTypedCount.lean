import host.load.RuntimeCompiledArgumentEntryPlan
import host.ts.RenameRetainedTypedCountStep
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

-- The actual BigUint64Array allocation takes the preceding array's length.
-- The generic transport requires its current literal role and native captures.
host_retained_typed_count P.F, Region.s106 using (Region.S106.substitute LoopVariables.oracleVariables)
  to Region.s107 using (Region.S107.substitute LoopVariables.oracleVariables) as TypedCount106

theorem typed_count_is_three : TypedCount106.count = 3 := by host_kernel_rfl
theorem typed_element_code : TypedCount106.codeIndex = 9 := by host_kernel_rfl

/-- error: typed count: expected constructor -/
#guard_msgs in
host_retained_typed_count P.F, Region.s105 using (Region.S105.substitute LoopVariables.oracleVariables)
  to Region.s107 using (Region.S107.substitute LoopVariables.oracleVariables) as WrongTypedControl

open Lean Elab Command in
run_cmd do
  let saved : Command.State ← get
  let count := saved.messages.toList.length
  let mut rendered := ""
  try
    Parametric.Driver.emit "host_retained_typed_count P.F, Region.s106 using (Region.S106.substitute LoopVariables.oracleVariables) to Region.s108 using (Region.S108.substitute LoopVariables.oracleVariables) as WrongTypedEndpoint"
  catch exception =>
    rendered := rendered ++ (← exception.toMessageData.toString)
  for message in (← get).messages.toList.drop count do
    rendered := rendered ++ "\n" ++ (← message.data.toString)
  for name in [`WrongTypedEndpoint.input,`WrongTypedEndpoint.source_control,`WrongTypedEndpoint.retained_transport] do
    if (← getEnv).contains ((← getCurrNamespace) ++ name) then
      throwError "wrong typed-array endpoint left a partial declaration: {name}"
  set saved
  unless (rendered.splitOn "(kernel) declaration type mismatch").length > 1 do
    throwError s!"wrong typed-array endpoint was not rejected by the kernel:\n{rendered.take 1500}"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
