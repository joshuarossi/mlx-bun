import host.load.RuntimeNamespacedDecodeRegion1100
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_source_linear_plan_subst P.F, Region1100 from 0 plan_steps 60
  substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables as Plan1100
noncomputable def PointerToNew.rules := Plan1100.rules.take 8
noncomputable def Construct.rules := (Plan1100.rules.drop 8).take 1
noncomputable def WrapperReturn.rules := Plan1100.rules.drop 9
end Host.Load.Run.Full.Ordinary.NamespacedDecode
