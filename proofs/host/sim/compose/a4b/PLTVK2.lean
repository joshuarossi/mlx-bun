import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.n0 : PLTVW.R.data.n0 = PRE_pl_tail.s0.next
kernel_rfl PLTV.n1 : PLTVW.R.data.n1 = PRE_plvw_common.s1.next
kernel_rfl PLTV.ren : checkRen PRE_pl_tail.s0 PLTVW.R.data PLTVW.R.inv = true

end Host.Load.Run.Tpl
