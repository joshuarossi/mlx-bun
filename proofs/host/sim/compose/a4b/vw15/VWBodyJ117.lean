import host.sim.compose.a4b.vw15.VWBodyJ116
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl117 : Conv.NClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1137.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl117 (PRE_first_tail_x15_r0_body.cncl116 bodyNcl116)

theorem bodyClean117 : Conv.JClean (⟨20517, 17609, 2767244, 5091⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1137 :=
  PRE_first_tail_x15_r0_body.gjcl117 (PRE_first_tail_x15_r0_body.cjcl116 bodyClean116)

kernel_rfl bodyJsLe117 : Nat.ble PRE_first_tail_x15_r0_body.s1121.next PRE_first_tail_x15_r0_body.s1137.next = true
kernel_rfl bodyJsList117 : (PRE_first_tail_x15_r0_body.gjh117 ++ PRE_first_tail_x15_r0_body.cl117).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1137.next) PRE_first_tail_x15_r0_body.s1139) = true
theorem bodyJs117 : JsHeapAbove PRE_first_tail_x15_r0_body.s1137.next PRE_first_tail_x15_r0_body.s1139 :=
  JsHeapAbove.glueSite bodyJs116 (Nat.le_of_ble_eq_true bodyJsLe117) PRE_first_tail_x15_r0_body.gjk117 PRE_first_tail_x15_r0_body.gjbd117 PRE_first_tail_x15_r0_body.cheap117 PRE_first_tail_x15_r0_body.zclbd117 bodyJsList117

end Host.Ts.Sim.Compose.VWFirst.VW15
