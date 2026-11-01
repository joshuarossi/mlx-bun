import host.sim.compose.a4b.vw15.VWBodyJ162
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl163 : Conv.NClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1577.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl163 (PRE_first_tail_x15_r0_body.cncl162 bodyNcl162)

theorem bodyClean163 : Conv.JClean (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1577 :=
  PRE_first_tail_x15_r0_body.gjcl163 (PRE_first_tail_x15_r0_body.cjcl162 bodyClean162)

kernel_rfl bodyJsLe163 : Nat.ble PRE_first_tail_x15_r0_body.s1569.next PRE_first_tail_x15_r0_body.s1577.next = true
kernel_rfl bodyJsList163 : (PRE_first_tail_x15_r0_body.gjh163 ++ PRE_first_tail_x15_r0_body.cl163).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1577.next) PRE_first_tail_x15_r0_body.s1579) = true
theorem bodyJs163 : JsHeapAbove PRE_first_tail_x15_r0_body.s1577.next PRE_first_tail_x15_r0_body.s1579 :=
  JsHeapAbove.glueSite bodyJs162 (Nat.le_of_ble_eq_true bodyJsLe163) PRE_first_tail_x15_r0_body.gjk163 PRE_first_tail_x15_r0_body.gjbd163 PRE_first_tail_x15_r0_body.cheap163 PRE_first_tail_x15_r0_body.zclbd163 bodyJsList163

end Host.Ts.Sim.Compose.VWFirst.VW15
