import host.load.RuntimeBlockPlan
import host.ts.RenameLoopVariableNamespace
import host.mlx.OrdinaryConcatStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedVectorOracleBatch
open Host.Ts.Owned.Annotated

host_source_plan_subst P.F, P.RestStream.micro0 from 250 plan_steps 86 substitute LoopVariables.oracleVariables as Plan
noncomputable def First.rules := Plan.rules.take 32
noncomputable def Second.rules := (Plan.rules.drop 32).take 32
noncomputable def Null.rules := (Plan.rules.drop 32).take 14
noncomputable def Slot.rules := (Plan.rules.drop 46).take 18
noncomputable def Array.rules := (Plan.rules.drop 46).take 2
noncomputable def Ready.rules := Plan.rules.drop 49
noncomputable def Third.rules := Plan.rules.drop 64

end Host.Load.Run.Full.Ordinary.RetainedVectorOracleBatch
