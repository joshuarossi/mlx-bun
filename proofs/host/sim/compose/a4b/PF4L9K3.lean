import host.sim.compose.a4b.PF4L9Na
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B3
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L9.ctl : PRE_first_tail_x4_L9_r0_suffix.s8.ctl = PFW4L9.R.data.map.ctl PRE_pf_x4_L9.s0.ctl
kernel_rfl PF4L9.stack : PRE_first_tail_x4_L9_r0_suffix.s8.stack = PRE_pf_x4_L9.s0.stack.map PFW4L9.R.data.map.frame
kernel_rfl PF4L9.jobs : PRE_first_tail_x4_L9_r0_suffix.s8.jobs = PRE_pf_x4_L9.s0.jobs.map PFW4L9.R.data.map.job
kernel_rfl PF4L9.stores : PRE_first_tail_x4_L9_r0_suffix.s8.stores = PFW4L9.R.data.map.stores PRE_pf_x4_L9.s0.stores

end Host.Load.Run.Tpl
