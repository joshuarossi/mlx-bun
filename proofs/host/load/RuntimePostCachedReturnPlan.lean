import host.load.RuntimePostCachedReturnCuts
import host.load.RuntimeBlockPlan

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.PostCachedReturn
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated

/- Host steps only. The vector-free call at local index 25 and the vector-size
call at the next segment stay outside these plans and use the adapters checked
in the cuts. -/
host_source_linear_plan_subst P.F, From2383 from 0 plan_steps 25
  substitute LoopVariables.oracleVariables as BeforeFree
host_source_linear_plan_subst P.F, From2409 from 0 plan_steps 19
  substitute LoopVariables.oracleVariables as BeforeSize
host_source_linear_plan_subst P.F, From2429 from 0 plan_steps 18
  substitute LoopVariables.oracleVariables as AfterSize

theorem segment_lengths :
    BeforeFree.sourceSteps = 25 ∧ BeforeSize.sourceSteps = 19 ∧ AfterSize.sourceSteps = 18 := by
  decide +kernel

end Host.Load.Run.Full.Ordinary.PostCachedReturn
