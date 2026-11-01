import host.sim.compose.a4b.vw15.VWBodyJ131
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl132 : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl132 (PRE_first_tail_x15_r0_body.cncl131 bodyNcl131)

theorem bodyClean132 : Conv.JClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1281 :=
  PRE_first_tail_x15_r0_body.gjcl132 (PRE_first_tail_x15_r0_body.cjcl131 bodyClean131)

kernel_rfl bodyJsLe132 : Nat.ble PRE_first_tail_x15_r0_body.s1264.next PRE_first_tail_x15_r0_body.s1281.next = true
kernel_rfl bodyJsList132 : (PRE_first_tail_x15_r0_body.gjh132 ++ PRE_first_tail_x15_r0_body.cl132).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1281.next) PRE_first_tail_x15_r0_body.s1283) = true
theorem bodyJs132 : JsHeapAbove PRE_first_tail_x15_r0_body.s1281.next PRE_first_tail_x15_r0_body.s1283 :=
  JsHeapAbove.glueSite bodyJs131 (Nat.le_of_ble_eq_true bodyJsLe132) PRE_first_tail_x15_r0_body.gjk132 PRE_first_tail_x15_r0_body.gjbd132 PRE_first_tail_x15_r0_body.cheap132 PRE_first_tail_x15_r0_body.zclbd132 bodyJsList132

end Host.Ts.Sim.Compose.VWFirst.VW15
