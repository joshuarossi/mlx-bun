import host.sim.compose.a4b.vw15.VWBodyJ97
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl98 : Conv.NClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s948.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl98 (PRE_first_tail_x15_r0_body.cncl97 bodyNcl97)

theorem bodyClean98 : Conv.JClean (⟨20127, 17218, 2751575, 4243⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s948 :=
  PRE_first_tail_x15_r0_body.gjcl98 (PRE_first_tail_x15_r0_body.cjcl97 bodyClean97)

kernel_rfl bodyJsLe98 : Nat.ble PRE_first_tail_x15_r0_body.s944.next PRE_first_tail_x15_r0_body.s948.next = true
kernel_rfl bodyJsList98 : (PRE_first_tail_x15_r0_body.gjh98 ++ PRE_first_tail_x15_r0_body.cl98).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s948.next) PRE_first_tail_x15_r0_body.s950) = true
theorem bodyJs98 : JsHeapAbove PRE_first_tail_x15_r0_body.s948.next PRE_first_tail_x15_r0_body.s950 :=
  JsHeapAbove.glueSite bodyJs97 (Nat.le_of_ble_eq_true bodyJsLe98) PRE_first_tail_x15_r0_body.gjk98 PRE_first_tail_x15_r0_body.gjbd98 PRE_first_tail_x15_r0_body.cheap98 PRE_first_tail_x15_r0_body.zclbd98 bodyJsList98

end Host.Ts.Sim.Compose.VWFirst.VW15
