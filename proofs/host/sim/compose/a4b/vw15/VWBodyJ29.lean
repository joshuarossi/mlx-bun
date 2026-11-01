import host.sim.compose.a4b.vw15.VWBodyJ28
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl29 : Conv.NClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl29 (PRE_first_tail_x15_r0_body.cncl28 bodyNcl28)

theorem bodyClean29 : Conv.JClean (⟨18768, 15859, 2697327, 1294⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s287 :=
  PRE_first_tail_x15_r0_body.gjcl29 (PRE_first_tail_x15_r0_body.cjcl28 bodyClean28)

kernel_rfl bodyJsLe29 : Nat.ble PRE_first_tail_x15_r0_body.s283.next PRE_first_tail_x15_r0_body.s287.next = true
kernel_rfl bodyJsList29 : (PRE_first_tail_x15_r0_body.gjh29 ++ PRE_first_tail_x15_r0_body.cl29).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s287.next) PRE_first_tail_x15_r0_body.s289) = true
theorem bodyJs29 : JsHeapAbove PRE_first_tail_x15_r0_body.s287.next PRE_first_tail_x15_r0_body.s289 :=
  JsHeapAbove.glueSite bodyJs28 (Nat.le_of_ble_eq_true bodyJsLe29) PRE_first_tail_x15_r0_body.gjk29 PRE_first_tail_x15_r0_body.gjbd29 PRE_first_tail_x15_r0_body.cheap29 PRE_first_tail_x15_r0_body.zclbd29 bodyJsList29

end Host.Ts.Sim.Compose.VWFirst.VW15
