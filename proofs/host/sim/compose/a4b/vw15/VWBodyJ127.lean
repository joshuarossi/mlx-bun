import host.sim.compose.a4b.vw15.VWBodyJ126
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl127 : Conv.NClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1232.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl127 (PRE_first_tail_x15_r0_body.cncl126 bodyNcl126)

theorem bodyClean127 : Conv.JClean (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1232 :=
  PRE_first_tail_x15_r0_body.gjcl127 (PRE_first_tail_x15_r0_body.cjcl126 bodyClean126)

kernel_rfl bodyJsLe127 : Nat.ble PRE_first_tail_x15_r0_body.s1224.next PRE_first_tail_x15_r0_body.s1232.next = true
kernel_rfl bodyJsList127 : (PRE_first_tail_x15_r0_body.gjh127 ++ PRE_first_tail_x15_r0_body.cl127).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1232.next) PRE_first_tail_x15_r0_body.s1234) = true
theorem bodyJs127 : JsHeapAbove PRE_first_tail_x15_r0_body.s1232.next PRE_first_tail_x15_r0_body.s1234 :=
  JsHeapAbove.glueSite bodyJs126 (Nat.le_of_ble_eq_true bodyJsLe127) PRE_first_tail_x15_r0_body.gjk127 PRE_first_tail_x15_r0_body.gjbd127 PRE_first_tail_x15_r0_body.cheap127 PRE_first_tail_x15_r0_body.zclbd127 bodyJsList127

end Host.Ts.Sim.Compose.VWFirst.VW15
