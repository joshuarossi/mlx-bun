import host.sim.compose.a4b.PL0Na
import host.sim.template.a4pre_fd_x0_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.ctl : PRE_fd_x0_r0_body.s447.ctl = PLW0.R.data.map.ctl PRE_plx0_entry.s0.ctl
kernel_rfl PL0.stack : PRE_fd_x0_r0_body.s447.stack = PRE_plx0_entry.s0.stack.map PLW0.R.data.map.frame
kernel_rfl PL0.jobs : PRE_fd_x0_r0_body.s447.jobs = PRE_plx0_entry.s0.jobs.map PLW0.R.data.map.job
kernel_rfl PL0.stores : PRE_fd_x0_r0_body.s447.stores = PLW0.R.data.map.stores PRE_plx0_entry.s0.stores

end Host.Load.Run.Tpl
