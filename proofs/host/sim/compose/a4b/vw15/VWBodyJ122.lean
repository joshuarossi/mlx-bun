import host.sim.compose.a4b.vw15.VWBodyJ121
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl122 : Conv.NClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1178.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl122 (PRE_first_tail_x15_r0_body.cncl121 bodyNcl121)

theorem bodyClean122 : Conv.JClean (⟨20599, 17692, 2770407, 5269⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1178 :=
  PRE_first_tail_x15_r0_body.gjcl122 (PRE_first_tail_x15_r0_body.cjcl121 bodyClean121)

kernel_rfl bodyJsLe122 : Nat.ble PRE_first_tail_x15_r0_body.s1174.next PRE_first_tail_x15_r0_body.s1178.next = true
kernel_rfl bodyJsList122 : (PRE_first_tail_x15_r0_body.gjh122 ++ PRE_first_tail_x15_r0_body.cl122).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1178.next) PRE_first_tail_x15_r0_body.s1180) = true
theorem bodyJs122 : JsHeapAbove PRE_first_tail_x15_r0_body.s1178.next PRE_first_tail_x15_r0_body.s1180 :=
  JsHeapAbove.glueSite bodyJs121 (Nat.le_of_ble_eq_true bodyJsLe122) PRE_first_tail_x15_r0_body.gjk122 PRE_first_tail_x15_r0_body.gjbd122 PRE_first_tail_x15_r0_body.cheap122 PRE_first_tail_x15_r0_body.zclbd122 bodyJsList122

end Host.Ts.Sim.Compose.VWFirst.VW15
