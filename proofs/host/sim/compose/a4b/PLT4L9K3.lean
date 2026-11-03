import host.sim.compose.a4b.PLT4L9Na
import host.sim.template.a4pre_plx4_L9_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L9.ctl : PRE_plx4_L9_common.s1.ctl = PLTW4L9.R.data.map.ctl PRE_pl_tail.s0.ctl
kernel_rfl PLT4L9.stack : PRE_plx4_L9_common.s1.stack = PRE_pl_tail.s0.stack.map PLTW4L9.R.data.map.frame
kernel_rfl PLT4L9.jobs : PRE_plx4_L9_common.s1.jobs = PRE_pl_tail.s0.jobs.map PLTW4L9.R.data.map.job
kernel_rfl PLT4L9.stores : PRE_plx4_L9_common.s1.stores = PLTW4L9.R.data.map.stores PRE_pl_tail.s0.stores

end Host.Load.Run.Tpl
