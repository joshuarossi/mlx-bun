import host.sim.compose.a4b.PFW4L8Walk
import host.sim.compose.a4b.PF4L8EKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PFW4L8.R from PF4L8EV : PFW4L8.R.data.map, PRE_pf_x4_L8.s0, PRE_first_tail_x4_L8_r0_suffix.s8

end Host.Load.Run.Tpl
