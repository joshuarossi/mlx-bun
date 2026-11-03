import host.sim.compose.a4b.PL4L8Na
import host.sim.template.a4pre_fd_x4_L8_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L8.ctl : PRE_fd_x4_L8_r0_body.s451.ctl = PLW4L8.R.data.map.ctl PRE_plx4_L8_entry.s0.ctl
kernel_rfl PL4L8.stack : PRE_fd_x4_L8_r0_body.s451.stack = PRE_plx4_L8_entry.s0.stack.map PLW4L8.R.data.map.frame
kernel_rfl PL4L8.jobs : PRE_fd_x4_L8_r0_body.s451.jobs = PRE_plx4_L8_entry.s0.jobs.map PLW4L8.R.data.map.job
kernel_rfl PL4L8.stores : PRE_fd_x4_L8_r0_body.s451.stores = PLW4L8.R.data.map.stores PRE_plx4_L8_entry.s0.stores

end Host.Load.Run.Tpl
