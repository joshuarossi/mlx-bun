import host.sim.compose.a4b.PFW4L9Walk
import host.sim.compose.a4b.PF4L9EKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PFW4L9.R from PF4L9EV : PFW4L9.R.data.map, PRE_pf_x4_L9.s0, PRE_first_tail_x4_L9_r0_suffix.s8

end Host.Load.Run.Tpl
