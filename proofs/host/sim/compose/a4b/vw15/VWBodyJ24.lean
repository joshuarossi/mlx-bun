import host.sim.compose.a4b.vw15.VWBodyJ23
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl24 : Conv.NClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl24 (PRE_first_tail_x15_r0_body.cncl23 bodyNcl23)

theorem bodyClean24 : Conv.JClean (⟨18688, 15752, 2694287, 1109⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s246 :=
  PRE_first_tail_x15_r0_body.gjcl24 (PRE_first_tail_x15_r0_body.cjcl23 bodyClean23)

kernel_rfl bodyJsLe24 : Nat.ble PRE_first_tail_x15_r0_body.s229.next PRE_first_tail_x15_r0_body.s246.next = true
kernel_rfl bodyJsList24 : (PRE_first_tail_x15_r0_body.gjh24 ++ PRE_first_tail_x15_r0_body.cl24).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s246.next) PRE_first_tail_x15_r0_body.s248) = true
theorem bodyJs24 : JsHeapAbove PRE_first_tail_x15_r0_body.s246.next PRE_first_tail_x15_r0_body.s248 :=
  JsHeapAbove.glueSite bodyJs23 (Nat.le_of_ble_eq_true bodyJsLe24) PRE_first_tail_x15_r0_body.gjk24 PRE_first_tail_x15_r0_body.gjbd24 PRE_first_tail_x15_r0_body.cheap24 PRE_first_tail_x15_r0_body.zclbd24 bodyJsList24

end Host.Ts.Sim.Compose.VWFirst.VW15
