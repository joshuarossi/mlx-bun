import host.sim.compose.a4b.x0.sfx.VWBodyJsP4
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B19
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B00
import host.sim.compose.JsAbove
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyJsPLe5 : Nat.ble PRE_first_tail_x0_r0_body.s565.next PRE_first_tail_x0_r0_body.s678.next = true
kernel_rfl bodyJsPList5 : PRE_first_tail_x0_r0_body.gjh0_5.all (noBigAtP (jsAboveB PRE_first_tail_x0_r0_body.s678.next) PRE_first_tail_x0_r0_body.s678) = true

theorem bodyJsPAt5 : JsHeapAbove PRE_first_tail_x0_r0_body.s678.next PRE_first_tail_x0_r0_body.s678 :=
  bodyJsPAt4.step (Nat.le_of_ble_eq_true bodyJsPLe5) PRE_first_tail_x0_r0_body.gjoff0_5 bodyJsPList5

end Host.Ts.Sim.Compose.VWFirst.X0.Sfx
