import host.load.RuntimeCompiledArgumentEntryPlan
import host.load.RuntimeCompiledArgumentEntrySelect
import host.ts.RenameLoopVariableNamespace
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts

-- Continue the actual wrapper entry through the original vector-allocation cut.
host_compiled_argument_linear_plan P.F, Region from 64 plan_steps 215 as From64

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
