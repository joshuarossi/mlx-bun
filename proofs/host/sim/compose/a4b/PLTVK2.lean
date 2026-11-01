import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.n0 : PLTailVW.R.data.n0 = PRE_pl_tail.s0.next
kernel_rfl PLTV.n1 : PLTailVW.R.data.n1 = PRE_plvw_common.s4.next
kernel_rfl PLTV.grows : Nat.ble PRE_pl_tail.s0.next PRE_plvw_common.s4.next = true
kernel_rfl PLTV.ren : checkRen PRE_pl_tail.s0 PLTailVW.R.data PLTailVW.R.inv = true

end Host.Load.Run.Tpl
