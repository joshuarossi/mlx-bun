import host.sim.compose.a4b.VWDispatch
import host.sim.compose.a4b.VWG2
namespace Host.Ts.Sim.Compose.FillVWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def pc0 := SetupCommon.nextCut
noncomputable def b_g1_DTtail_first_i := VWFirst.afterNpsCut
noncomputable def b_g1_DTtail_first_o := VWFirst.dispatchCut
noncomputable def b_g2_first_i := VWFirst.g2Cut
noncomputable def b_g2_first_o := VWFirst.forwardCut

noncomputable def nps_DTtail_first__start__g1_DTtail_first := VWFirst.nps_DTtail_first__start__g1_DTtail_first
noncomputable def g1_DTtail_first := VWFirst.g1_DTtail_first
noncomputable def disp_VW__g1_DTtail_first__g2_first := VWFirst.disp_VW__g1_DTtail_first__g2_first
noncomputable def g2_first := VWFirst.g2_first
end Host.Ts.Sim.Compose.FillVWFirst
