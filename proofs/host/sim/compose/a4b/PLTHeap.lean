import host.sim.compose.a4b.PLTPWalk
import host.sim.compose.a4b.PLTEKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PLTP.R from PLTEV : PLTP.R.data.map, PRE_pl_tail.s0, PRE_pl_common.s1

end Host.Load.Run.Tpl
