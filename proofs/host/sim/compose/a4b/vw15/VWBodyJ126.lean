import host.sim.compose.a4b.vw15.VWBodyJ125
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl126 : Conv.NClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl126 (PRE_first_tail_x15_r0_body.cncl125 bodyNcl125)

theorem bodyClean126 : Conv.JClean (⟨20690, 17774, 2774135, 5471⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1224 :=
  PRE_first_tail_x15_r0_body.gjcl126 (PRE_first_tail_x15_r0_body.cjcl125 bodyClean125)

kernel_rfl bodyJsLe126 : Nat.ble PRE_first_tail_x15_r0_body.s1207.next PRE_first_tail_x15_r0_body.s1224.next = true
kernel_rfl bodyJsList126 : (PRE_first_tail_x15_r0_body.gjh126 ++ PRE_first_tail_x15_r0_body.cl126).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1224.next) PRE_first_tail_x15_r0_body.s1226) = true
theorem bodyJs126 : JsHeapAbove PRE_first_tail_x15_r0_body.s1224.next PRE_first_tail_x15_r0_body.s1226 :=
  JsHeapAbove.glueSite bodyJs125 (Nat.le_of_ble_eq_true bodyJsLe126) PRE_first_tail_x15_r0_body.gjk126 PRE_first_tail_x15_r0_body.gjbd126 PRE_first_tail_x15_r0_body.cheap126 PRE_first_tail_x15_r0_body.zclbd126 bodyJsList126

end Host.Ts.Sim.Compose.VWFirst.VW15
