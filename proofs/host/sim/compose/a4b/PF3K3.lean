import host.sim.compose.a4b.PF3Na
import host.sim.template.a4pre_first_tail_x3_r0_suffix.m.B3
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF3.ctl : PRE_first_tail_x3_r0_suffix.s8.ctl = PFW3.R.data.map.ctl PRE_pf_vw.s0.ctl
kernel_rfl PF3.stack : PRE_first_tail_x3_r0_suffix.s8.stack = PRE_pf_vw.s0.stack.map PFW3.R.data.map.frame
kernel_rfl PF3.jobs : PRE_first_tail_x3_r0_suffix.s8.jobs = PRE_pf_vw.s0.jobs.map PFW3.R.data.map.job
kernel_rfl PF3.stores : PRE_first_tail_x3_r0_suffix.s8.stores = PFW3.R.data.map.stores PRE_pf_vw.s0.stores

end Host.Load.Run.Tpl
