import host.load.RuntimeNamespacedDecodeRegion1100
import host.ts.RenameRetainedUsingFrontend
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_source_linear_plan_subst P.F, Region1100 from 60 plan_steps 40
  substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables as Plan1160
end Host.Load.Run.Full.Ordinary.NamespacedDecode
