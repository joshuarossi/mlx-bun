import host.sim.compose.a4b.vw15.VWBodyJ5
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl6 : Conv.NClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl6 (PRE_first_tail_x15_r0_body.cncl5 bodyNcl5)

theorem bodyClean6 : Conv.JClean (⟨18330, 15404, 2679973, 341⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s74 :=
  PRE_first_tail_x15_r0_body.gjcl6 (PRE_first_tail_x15_r0_body.cjcl5 bodyClean5)

kernel_rfl bodyJsLe6 : Nat.ble PRE_first_tail_x15_r0_body.s57.next PRE_first_tail_x15_r0_body.s74.next = true
kernel_rfl bodyJsList6 : (PRE_first_tail_x15_r0_body.gjh6 ++ PRE_first_tail_x15_r0_body.cl6).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s74.next) PRE_first_tail_x15_r0_body.s76) = true
theorem bodyJs6 : JsHeapAbove PRE_first_tail_x15_r0_body.s74.next PRE_first_tail_x15_r0_body.s76 :=
  JsHeapAbove.glueSite bodyJs5 (Nat.le_of_ble_eq_true bodyJsLe6) PRE_first_tail_x15_r0_body.gjk6 PRE_first_tail_x15_r0_body.gjbd6 PRE_first_tail_x15_r0_body.cheap6 PRE_first_tail_x15_r0_body.zclbd6 bodyJsList6

end Host.Ts.Sim.Compose.VWFirst.VW15
