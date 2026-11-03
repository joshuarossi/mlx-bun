import host.sim.compose.a4b.x0.sfx.VWBodyJsP5
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B20
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B00
import host.sim.compose.JsAbove
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyJsPLe6 : Nat.ble PRE_first_tail_x0_r0_body.s678.next PRE_first_tail_x0_r0_body.s791.next = true
kernel_rfl bodyJsPList6 : PRE_first_tail_x0_r0_body.gjh0_6.all (noBigAtP (jsAboveB PRE_first_tail_x0_r0_body.s791.next) PRE_first_tail_x0_r0_body.s791) = true

theorem bodyJsPAt6 : JsHeapAbove PRE_first_tail_x0_r0_body.s791.next PRE_first_tail_x0_r0_body.s791 :=
  bodyJsPAt5.step (Nat.le_of_ble_eq_true bodyJsPLe6) PRE_first_tail_x0_r0_body.gjoff0_6 bodyJsPList6

end Host.Ts.Sim.Compose.VWFirst.X0.Sfx
