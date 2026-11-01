import host.sim.compose.a4b.PFW3Walk
import host.sim.compose.a4b.PF15EKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PFW3.R from PF15EV : PFW3.R.data.map, PRE_pf_vw.s0, PRE_first_tail_x3_r0_suffix.s8

end Host.Load.Run.Tpl
