import host.sim.compose.a4b.PLTNa
import host.sim.template.a4pre_pl_common.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.ctl : PRE_pl_common.s4.ctl = PLTail.R.data.map.ctl PRE_pl_tail.s0.ctl
kernel_rfl PLT.stack : PRE_pl_common.s4.stack = PRE_pl_tail.s0.stack.map PLTail.R.data.map.frame
kernel_rfl PLT.jobs : PRE_pl_common.s4.jobs = PRE_pl_tail.s0.jobs.map PLTail.R.data.map.job
kernel_rfl PLT.stores : PRE_pl_common.s4.stores = PLTail.R.data.map.stores PRE_pl_tail.s0.stores

end Host.Load.Run.Tpl
