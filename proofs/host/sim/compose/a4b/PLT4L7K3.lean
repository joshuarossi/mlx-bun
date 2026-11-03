import host.sim.compose.a4b.PLT4L7Na
import host.sim.template.a4pre_plx4_L7_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L7.ctl : PRE_plx4_L7_common.s1.ctl = PLTW4L7.R.data.map.ctl PRE_pl_tail.s0.ctl
kernel_rfl PLT4L7.stack : PRE_plx4_L7_common.s1.stack = PRE_pl_tail.s0.stack.map PLTW4L7.R.data.map.frame
kernel_rfl PLT4L7.jobs : PRE_plx4_L7_common.s1.jobs = PRE_pl_tail.s0.jobs.map PLTW4L7.R.data.map.job
kernel_rfl PLT4L7.stores : PRE_plx4_L7_common.s1.stores = PLTW4L7.R.data.map.stores PRE_pl_tail.s0.stores

end Host.Load.Run.Tpl
