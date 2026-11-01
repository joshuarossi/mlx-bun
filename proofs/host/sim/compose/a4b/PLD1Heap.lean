import host.sim.compose.a4b.PostWalkD1
import host.sim.compose.a4b.PLEntryKeys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

tpl_heap_blocks PLWalkD1.R from PLEntryV : PLWalkD1.R.data.map, PRE_pl_entry.s0, D1Body.s155

end Host.Load.Run.Tpl
