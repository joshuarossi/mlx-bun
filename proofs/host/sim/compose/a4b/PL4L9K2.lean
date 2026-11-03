import host.sim.compose.a4b.PL4L9Na
import host.sim.template.a4pre_fd_x4_L9_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L9.n0 : PLW4L9.R.data.n0 = PRE_plx4_L9_entry.s0.next
kernel_rfl PL4L9.n1 : PLW4L9.R.data.n1 = PRE_fd_x4_L9_r0_body.s451.next
kernel_rfl PL4L9.ren : checkRen PRE_plx4_L9_entry.s0 PLW4L9.R.data PLW4L9.R.inv = true

end Host.Load.Run.Tpl
