import host.sim.compose.a4b.vw15.VWBodyJ115
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl116 : Conv.NClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1121.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl116 (PRE_first_tail_x15_r0_body.cncl115 bodyNcl115)

theorem bodyClean116 : Conv.JClean (⟨20477, 17581, 2765507, 5014⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1121 :=
  PRE_first_tail_x15_r0_body.gjcl116 (PRE_first_tail_x15_r0_body.cjcl115 bodyClean115)

kernel_rfl bodyJsLe116 : Nat.ble PRE_first_tail_x15_r0_body.s1117.next PRE_first_tail_x15_r0_body.s1121.next = true
kernel_rfl bodyJsList116 : (PRE_first_tail_x15_r0_body.gjh116 ++ PRE_first_tail_x15_r0_body.cl116).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1121.next) PRE_first_tail_x15_r0_body.s1123) = true
theorem bodyJs116 : JsHeapAbove PRE_first_tail_x15_r0_body.s1121.next PRE_first_tail_x15_r0_body.s1123 :=
  JsHeapAbove.glueSite bodyJs115 (Nat.le_of_ble_eq_true bodyJsLe116) PRE_first_tail_x15_r0_body.gjk116 PRE_first_tail_x15_r0_body.gjbd116 PRE_first_tail_x15_r0_body.cheap116 PRE_first_tail_x15_r0_body.zclbd116 bodyJsList116

end Host.Ts.Sim.Compose.VWFirst.VW15
