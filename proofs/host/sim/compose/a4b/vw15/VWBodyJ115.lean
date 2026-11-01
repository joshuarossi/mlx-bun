import host.sim.compose.a4b.vw15.VWBodyJ114
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl115 : Conv.NClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1117.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl115 (PRE_first_tail_x15_r0_body.cncl114 bodyNcl114)

theorem bodyClean115 : Conv.JClean (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1117 :=
  PRE_first_tail_x15_r0_body.gjcl115 (PRE_first_tail_x15_r0_body.cjcl114 bodyClean114)

kernel_rfl bodyJsLe115 : Nat.ble PRE_first_tail_x15_r0_body.s1109.next PRE_first_tail_x15_r0_body.s1117.next = true
kernel_rfl bodyJsList115 : (PRE_first_tail_x15_r0_body.gjh115 ++ PRE_first_tail_x15_r0_body.cl115).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1117.next) PRE_first_tail_x15_r0_body.s1119) = true
theorem bodyJs115 : JsHeapAbove PRE_first_tail_x15_r0_body.s1117.next PRE_first_tail_x15_r0_body.s1119 :=
  JsHeapAbove.glueSite bodyJs114 (Nat.le_of_ble_eq_true bodyJsLe115) PRE_first_tail_x15_r0_body.gjk115 PRE_first_tail_x15_r0_body.gjbd115 PRE_first_tail_x15_r0_body.cheap115 PRE_first_tail_x15_r0_body.zclbd115 bodyJsList115

end Host.Ts.Sim.Compose.VWFirst.VW15
