import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.ctl : PRE_plvw_common.s1.ctl = PLTVW.R.data.map.ctl PRE_pl_tail.s0.ctl
kernel_rfl PLTV.stack : PRE_plvw_common.s1.stack = PRE_pl_tail.s0.stack.map PLTVW.R.data.map.frame
kernel_rfl PLTV.jobs : PRE_plvw_common.s1.jobs = PRE_pl_tail.s0.jobs.map PLTVW.R.data.map.job
kernel_rfl PLTV.stores : PRE_plvw_common.s1.stores = PLTVW.R.data.map.stores PRE_pl_tail.s0.stores

end Host.Load.Run.Tpl
