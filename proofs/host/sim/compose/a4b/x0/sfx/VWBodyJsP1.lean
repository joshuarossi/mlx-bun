import host.sim.compose.a4b.x0.sfx.VWBodyJsP0
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B00
import host.sim.compose.JsAbove
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyJsPLe1 : Nat.ble PRE_first_tail_x0_r0_body.s113.next PRE_first_tail_x0_r0_body.s226.next = true
kernel_rfl bodyJsPList1 : PRE_first_tail_x0_r0_body.gjh0_1.all (noBigAtP (jsAboveB PRE_first_tail_x0_r0_body.s226.next) PRE_first_tail_x0_r0_body.s226) = true

theorem bodyJsPAt1 : JsHeapAbove PRE_first_tail_x0_r0_body.s226.next PRE_first_tail_x0_r0_body.s226 :=
  bodyJsPAt0.step (Nat.le_of_ble_eq_true bodyJsPLe1) PRE_first_tail_x0_r0_body.gjoff0_1 bodyJsPList1

end Host.Ts.Sim.Compose.VWFirst.X0.Sfx
