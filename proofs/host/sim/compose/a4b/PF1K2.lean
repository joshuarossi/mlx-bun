import host.sim.compose.a4b.PF1Na
import host.sim.template.a4pre_first_tail_x1_r0_suffix.m.B0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF1.n0 : PFW1.R.data.n0 = PRE_pf_vw.s0.next
kernel_rfl PF1.n1 : PFW1.R.data.n1 = PRE_first_tail_x1_r0_suffix.s8.next
kernel_rfl PF1.grows : Nat.ble PRE_pf_vw.s0.next PRE_first_tail_x1_r0_suffix.s8.next = true
kernel_rfl PF1.ren : checkRen PRE_pf_vw.s0 PFW1.R.data PFW1.R.inv = true

end Host.Load.Run.Tpl
