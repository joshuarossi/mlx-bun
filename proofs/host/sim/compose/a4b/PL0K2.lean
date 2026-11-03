import host.sim.compose.a4b.PL0Na
import host.sim.template.a4pre_fd_x0_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.n0 : PLW0.R.data.n0 = PRE_plx0_entry.s0.next
kernel_rfl PL0.n1 : PLW0.R.data.n1 = PRE_fd_x0_r0_body.s447.next
kernel_rfl PL0.ren : checkRen PRE_plx0_entry.s0 PLW0.R.data PLW0.R.inv = true

end Host.Load.Run.Tpl
