import host.sim.compose.a4b.x0.sfx.VWBodyJsP2
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B17
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B00
import host.sim.compose.JsAbove
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyJsPLe3 : Nat.ble PRE_first_tail_x0_r0_body.s339.next PRE_first_tail_x0_r0_body.s452.next = true
kernel_rfl bodyJsPList3 : PRE_first_tail_x0_r0_body.gjh0_3.all (noBigAtP (jsAboveB PRE_first_tail_x0_r0_body.s452.next) PRE_first_tail_x0_r0_body.s452) = true

theorem bodyJsPAt3 : JsHeapAbove PRE_first_tail_x0_r0_body.s452.next PRE_first_tail_x0_r0_body.s452 :=
  bodyJsPAt2.step (Nat.le_of_ble_eq_true bodyJsPLe3) PRE_first_tail_x0_r0_body.gjoff0_3 bodyJsPList3

end Host.Ts.Sim.Compose.VWFirst.X0.Sfx
