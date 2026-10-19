import host.load.RuntimeCompiledArgumentEntryPlan
import host.load.RuntimeCompiledArgumentEntrySelect
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts

-- Region indices 0-11. Index 3 is the actual source-2060 chain return.
-- The surrounding steps stay on the checked linear planner.
host_compiled_argument_linear_plan P.F, Region from 0 plan_steps 12 as Head

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
