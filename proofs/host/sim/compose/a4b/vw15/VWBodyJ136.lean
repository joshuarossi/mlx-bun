import host.sim.compose.a4b.vw15.VWBodyJ135
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl136 : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl136 (PRE_first_tail_x15_r0_body.cncl135 bodyNcl135)

theorem bodyClean136 : Conv.JClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1318 :=
  PRE_first_tail_x15_r0_body.gjcl136 (PRE_first_tail_x15_r0_body.cjcl135 bodyClean135)

kernel_rfl bodyJsLe136 : Nat.ble PRE_first_tail_x15_r0_body.s1310.next PRE_first_tail_x15_r0_body.s1318.next = true
kernel_rfl bodyJsList136 : (PRE_first_tail_x15_r0_body.gjh136 ++ PRE_first_tail_x15_r0_body.cl136).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1318.next) PRE_first_tail_x15_r0_body.s1320) = true
theorem bodyJs136 : JsHeapAbove PRE_first_tail_x15_r0_body.s1318.next PRE_first_tail_x15_r0_body.s1320 :=
  JsHeapAbove.glueSite bodyJs135 (Nat.le_of_ble_eq_true bodyJsLe136) PRE_first_tail_x15_r0_body.gjk136 PRE_first_tail_x15_r0_body.gjbd136 PRE_first_tail_x15_r0_body.cheap136 PRE_first_tail_x15_r0_body.zclbd136 bodyJsList136

end Host.Ts.Sim.Compose.VWFirst.VW15
