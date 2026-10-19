import host.load.RuntimeCompiledArgumentEntryPlan
import host.load.RuntimeCompiledArgumentEntrySelect
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts

-- Region indices 30-63. Index 63 is the compiled closure wrapper at source 2120.
host_compiled_argument_linear_plan P.F, Region from 30 plan_steps 34 as From30

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
