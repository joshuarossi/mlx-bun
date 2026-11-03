import host.sim.compose.a4b.PLW0Walk
import host.sim.compose.a4b.PL0EKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PLW0.R from PL0EV : PLW0.R.data.map, PRE_plx0_entry.s0, PRE_fd_x0_r0_body.s447

end Host.Load.Run.Tpl
