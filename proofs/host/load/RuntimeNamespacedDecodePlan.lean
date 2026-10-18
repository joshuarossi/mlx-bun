import host.load.RuntimeBlockPlan
import host.mlx.NativeSourcePlugins
import host.mlx.OrdinarySliceStates
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_source_plan_subst P.F, P.RestStream.micro0 from 1087 plan_steps 13
  substitute LoopVariables.oracleVariables as AfterSlice

end Host.Load.Run.Full.Ordinary.NamespacedDecode
