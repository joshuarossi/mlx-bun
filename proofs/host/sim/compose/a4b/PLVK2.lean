import host.sim.compose.a4b.PLVNa
import host.sim.template.a4pre_fd_vw_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLV.n0 : PLVW.R.data.n0 = PRE_plvw_entry.s0.next
kernel_rfl PLV.n1 : PLVW.R.data.n1 = PRE_fd_vw_r0_body.s900.next
kernel_rfl PLV.ren : checkRen PRE_plvw_entry.s0 PLVW.R.data PLVW.R.inv = true

end Host.Load.Run.Tpl
