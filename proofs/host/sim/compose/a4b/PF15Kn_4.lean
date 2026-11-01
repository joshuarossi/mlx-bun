import host.sim.compose.a4b.PF15Na
import host.sim.template.a4pre_first_tail_x15_r0_suffix.m.B0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF15.nnum_4 : ((((((List.range PRE_pf_vw.S0.tab.length).drop 500).drop 500).drop 500).drop 500).take 500).all PF15.numAt = true

end Host.Load.Run.Tpl
