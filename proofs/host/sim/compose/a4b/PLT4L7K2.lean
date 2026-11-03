import host.sim.compose.a4b.PLT4L7Na
import host.sim.template.a4pre_plx4_L7_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L7.n0 : PLTW4L7.R.data.n0 = PRE_pl_tail.s0.next
kernel_rfl PLT4L7.n1 : PLTW4L7.R.data.n1 = PRE_plx4_L7_common.s1.next
kernel_rfl PLT4L7.ren : checkRen PRE_pl_tail.s0 PLTW4L7.R.data PLTW4L7.R.inv = true

end Host.Load.Run.Tpl
