import host.sim.compose.a4b.PF8Na
import host.sim.template.a4pre_first_tail_x8_r0_suffix.m.B0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF8.n0 : PFW8.R.data.n0 = PRE_pf_vw.s0.next
kernel_rfl PF8.n1 : PFW8.R.data.n1 = PRE_first_tail_x8_r0_suffix.s8.next
kernel_rfl PF8.ren : checkRen PRE_pf_vw.s0 PFW8.R.data PFW8.R.inv = true

end Host.Load.Run.Tpl
