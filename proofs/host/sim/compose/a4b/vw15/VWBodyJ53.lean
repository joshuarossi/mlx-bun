import host.sim.compose.a4b.vw15.VWBodyJ52
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl53 : Conv.NClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s517.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl53 (PRE_first_tail_x15_r0_body.cncl52 bodyNcl52)

theorem bodyClean53 : Conv.JClean (⟨19240, 16333, 2716167, 2320⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s517 :=
  PRE_first_tail_x15_r0_body.gjcl53 (PRE_first_tail_x15_r0_body.cjcl52 bodyClean52)

kernel_rfl bodyJsLe53 : Nat.ble PRE_first_tail_x15_r0_body.s513.next PRE_first_tail_x15_r0_body.s517.next = true
kernel_rfl bodyJsList53 : (PRE_first_tail_x15_r0_body.gjh53 ++ PRE_first_tail_x15_r0_body.cl53).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s517.next) PRE_first_tail_x15_r0_body.s519) = true
theorem bodyJs53 : JsHeapAbove PRE_first_tail_x15_r0_body.s517.next PRE_first_tail_x15_r0_body.s519 :=
  JsHeapAbove.glueSite bodyJs52 (Nat.le_of_ble_eq_true bodyJsLe53) PRE_first_tail_x15_r0_body.gjk53 PRE_first_tail_x15_r0_body.gjbd53 PRE_first_tail_x15_r0_body.cheap53 PRE_first_tail_x15_r0_body.zclbd53 bodyJsList53

end Host.Ts.Sim.Compose.VWFirst.VW15
