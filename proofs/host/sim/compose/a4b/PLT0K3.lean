import host.sim.compose.a4b.PLT0Na
import host.sim.template.a4pre_plx0_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT0.ctl : PRE_plx0_common.s1.ctl = PLTW0.R.data.map.ctl PRE_pl_tail.s0.ctl
kernel_rfl PLT0.stack : PRE_plx0_common.s1.stack = PRE_pl_tail.s0.stack.map PLTW0.R.data.map.frame
kernel_rfl PLT0.jobs : PRE_plx0_common.s1.jobs = PRE_pl_tail.s0.jobs.map PLTW0.R.data.map.job
kernel_rfl PLT0.stores : PRE_plx0_common.s1.stores = PLTW0.R.data.map.stores PRE_pl_tail.s0.stores

end Host.Load.Run.Tpl
