import host.sim.compose.a4b.PLD1Full
import host.sim.compose.a4b.PLEntryFresh
import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.n0 : PLWalkD1.R.data.n0 = PRE_pl_entry.s0.next
kernel_rfl PLD1.n1 : PLWalkD1.R.data.n1 = D1Body.s155.next
kernel_rfl PLD1.grows : Nat.ble PRE_pl_entry.s0.next D1Body.s155.next = true
kernel_rfl PLD1.ren : checkRen PRE_pl_entry.s0 PLWalkD1.R.data PLWalkD1.R.inv = true

end Host.Load.Run.Tpl
