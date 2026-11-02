import host.sim.compose.a4b.PLTNa
import host.sim.template.a4pre_pl_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.n0 : PLTP.R.data.n0 = PRE_pl_tail.s0.next
kernel_rfl PLT.n1 : PLTP.R.data.n1 = PRE_pl_common.s1.next
kernel_rfl PLT.ren : checkRen PRE_pl_tail.s0 PLTP.R.data PLTP.R.inv = true

end Host.Load.Run.Tpl
