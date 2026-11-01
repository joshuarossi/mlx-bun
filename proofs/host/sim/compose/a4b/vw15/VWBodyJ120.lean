import host.sim.compose.a4b.vw15.VWBodyJ119
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl120 : Conv.NClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl120 (PRE_first_tail_x15_r0_body.cncl119 bodyNcl119)

theorem bodyClean120 : Conv.JClean (⟨20576, 17648, 2769623, 5213⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1166 :=
  PRE_first_tail_x15_r0_body.gjcl120 (PRE_first_tail_x15_r0_body.cjcl119 bodyClean119)

kernel_rfl bodyJsLe120 : Nat.ble PRE_first_tail_x15_r0_body.s1149.next PRE_first_tail_x15_r0_body.s1166.next = true
kernel_rfl bodyJsList120 : (PRE_first_tail_x15_r0_body.gjh120 ++ PRE_first_tail_x15_r0_body.cl120).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1166.next) PRE_first_tail_x15_r0_body.s1168) = true
theorem bodyJs120 : JsHeapAbove PRE_first_tail_x15_r0_body.s1166.next PRE_first_tail_x15_r0_body.s1168 :=
  JsHeapAbove.glueSite bodyJs119 (Nat.le_of_ble_eq_true bodyJsLe120) PRE_first_tail_x15_r0_body.gjk120 PRE_first_tail_x15_r0_body.gjbd120 PRE_first_tail_x15_r0_body.cheap120 PRE_first_tail_x15_r0_body.zclbd120 bodyJsList120

end Host.Ts.Sim.Compose.VWFirst.VW15
