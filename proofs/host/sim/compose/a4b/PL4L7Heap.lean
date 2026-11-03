import host.sim.compose.a4b.PLW4L7Walk
import host.sim.compose.a4b.PL4L7EKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PLW4L7.R from PL4L7EV : PLW4L7.R.data.map, PRE_plx4_L7_entry.s0, PRE_fd_x4_L7_r0_body.s451

end Host.Load.Run.Tpl
