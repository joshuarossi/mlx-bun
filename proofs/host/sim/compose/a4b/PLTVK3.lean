import host.load.boot.World
import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.ctl : PRE_plvw_common.s4.ctl = PLTailVW.R.data.map.ctl PRE_pl_tail.s0.ctl
kernel_rfl PLTV.stack : PRE_plvw_common.s4.stack = PRE_pl_tail.s0.stack.map PLTailVW.R.data.map.frame
kernel_rfl PLTV.jobs : PRE_plvw_common.s4.jobs = PRE_pl_tail.s0.jobs.map PLTailVW.R.data.map.job
kernel_rfl PLTV.stores : PRE_plvw_common.s4.stores = PLTailVW.R.data.map.stores PRE_pl_tail.s0.stores

end Host.Load.Run.Tpl
