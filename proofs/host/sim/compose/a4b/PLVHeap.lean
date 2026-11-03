import host.sim.compose.a4b.PLVWalk
import host.sim.compose.a4b.PLVEKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PLVW.R from PLVEV : PLVW.R.data.map, PRE_plvw_entry.s0, PRE_fd_vw_r0_body.s900

end Host.Load.Run.Tpl
