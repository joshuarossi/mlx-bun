import host.sim.compose.a4b.vw15.VWBodyJ20
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl21 : Conv.NClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s217.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl21 (PRE_first_tail_x15_r0_body.cncl20 bodyNcl20)

theorem bodyClean21 : Conv.JClean (⟨18629, 15713, 2691908, 987⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s217 :=
  PRE_first_tail_x15_r0_body.gjcl21 (PRE_first_tail_x15_r0_body.cjcl20 bodyClean20)

kernel_rfl bodyJsLe21 : Nat.ble PRE_first_tail_x15_r0_body.s201.next PRE_first_tail_x15_r0_body.s217.next = true
kernel_rfl bodyJsList21 : (PRE_first_tail_x15_r0_body.gjh21 ++ PRE_first_tail_x15_r0_body.cl21).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s217.next) PRE_first_tail_x15_r0_body.s219) = true
theorem bodyJs21 : JsHeapAbove PRE_first_tail_x15_r0_body.s217.next PRE_first_tail_x15_r0_body.s219 :=
  JsHeapAbove.glueSite bodyJs20 (Nat.le_of_ble_eq_true bodyJsLe21) PRE_first_tail_x15_r0_body.gjk21 PRE_first_tail_x15_r0_body.gjbd21 PRE_first_tail_x15_r0_body.cheap21 PRE_first_tail_x15_r0_body.zclbd21 bodyJsList21

end Host.Ts.Sim.Compose.VWFirst.VW15
