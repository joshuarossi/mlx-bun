import host.sim.compose.a4b.PFW0Walk
import host.sim.compose.a4b.PF0EKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PFW0.R from PF0EV : PFW0.R.data.map, PRE_pf_x0.s0, PRE_first_tail_x0_r0_suffix.s8

end Host.Load.Run.Tpl
