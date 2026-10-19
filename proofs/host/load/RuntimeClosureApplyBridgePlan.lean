import host.ts.renameOrdinary.NativeCallCutStates
import host.load.RuntimeBlockPlan
import host.mlx.NativeSourcePlugins
import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ClosureApplyBridge

-- Thirteen host steps, source 2337 through the empty vector-new call.
host_source_plan_subst P.F, P.RestStream.micro0 from 2337 plan_steps 13
  substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables as Before

-- The existing native empty-vector rule. Its target execution and the resulting
-- ownership are proved here, not assumed by the bridge.
host_source_step P.F, P.RestStream.micro0.micro23.s50
  using ((P.RestStream.micro0.micro23.S50).substitute (Host.Ts.Owned.Annotated.LoopVariables.oracleVariables))
  to P.RestStream.micro0.micro23.s51
  using ((P.RestStream.micro0.micro23.S51).substitute (Host.Ts.Owned.Annotated.LoopVariables.oracleVariables))
  as VectorNew

-- Thirty-one host steps from the fresh empty vector to the closure-call input.
host_source_plan_subst P.F, P.RestStream.micro0 from 2351 plan_steps 31
  substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables as After

end Host.Load.Run.Full.Ordinary.ClosureApplyBridge
