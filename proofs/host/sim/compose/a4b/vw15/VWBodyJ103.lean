import host.sim.compose.a4b.vw15.VWBodyJ102
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl103 : Conv.NClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl103 (PRE_first_tail_x15_r0_body.cncl102 bodyNcl102)

theorem bodyClean103 : Conv.JClean (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1002 :=
  PRE_first_tail_x15_r0_body.gjcl103 (PRE_first_tail_x15_r0_body.cjcl102 bodyClean102)

kernel_rfl bodyJsLe103 : Nat.ble PRE_first_tail_x15_r0_body.s994.next PRE_first_tail_x15_r0_body.s1002.next = true
kernel_rfl bodyJsList103 : (PRE_first_tail_x15_r0_body.gjh103 ++ PRE_first_tail_x15_r0_body.cl103).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1002.next) PRE_first_tail_x15_r0_body.s1004) = true
theorem bodyJs103 : JsHeapAbove PRE_first_tail_x15_r0_body.s1002.next PRE_first_tail_x15_r0_body.s1004 :=
  JsHeapAbove.glueSite bodyJs102 (Nat.le_of_ble_eq_true bodyJsLe103) PRE_first_tail_x15_r0_body.gjk103 PRE_first_tail_x15_r0_body.gjbd103 PRE_first_tail_x15_r0_body.cheap103 PRE_first_tail_x15_r0_body.zclbd103 bodyJsList103

end Host.Ts.Sim.Compose.VWFirst.VW15
