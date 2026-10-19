import host.load.RuntimeCompiledArgumentEntryCuts2057
import host.ts.RenameCompiledArgumentEntryChainStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
host_compiled_argument_chain_step P.F, From2057.s3 using From2057.S3 to From2057.s4 using From2057.S4 as Source2060

-- Same actual source 2060 state. Only the declared endpoint changes.
open Lean Elab Command in
run_cmd do
  let saved : Command.State ← get
  let count := saved.messages.toList.length
  let mut rendered := ""
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_compiled_argument_chain_step P.F, From2057.s3 using From2057.S3 to From2057.s5 using From2057.S5 as WrongSource2060"
  catch exception =>
    rendered := rendered ++ (← exception.toMessageData.toString)
  for message in (← get).messages.toList.drop count do
    rendered := rendered ++ "\n" ++ (← message.data.toString)
  if (← getEnv).contains ((← getCurrNamespace) ++ `WrongSource2060.input) then
    throwError "wrong source 2060 endpoint left a partial declaration"
  set saved
  unless (rendered.splitOn "(kernel) declaration type mismatch").length > 1 do
    throwError s!"wrong source 2060 endpoint was not a kernel declaration type mismatch:\n{rendered.take 1500}"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
