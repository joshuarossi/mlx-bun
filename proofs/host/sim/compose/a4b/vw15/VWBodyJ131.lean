import host.sim.compose.a4b.vw15.VWBodyJ130
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl131 : Conv.NClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1264.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl131 (PRE_first_tail_x15_r0_body.cncl130 bodyNcl130)

theorem bodyClean131 : Conv.JClean (⟨20777, 17866, 2777541, 5653⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1264 :=
  PRE_first_tail_x15_r0_body.gjcl131 (PRE_first_tail_x15_r0_body.cjcl130 bodyClean130)

kernel_rfl bodyJsLe131 : Nat.ble PRE_first_tail_x15_r0_body.s1260.next PRE_first_tail_x15_r0_body.s1264.next = true
kernel_rfl bodyJsList131 : (PRE_first_tail_x15_r0_body.gjh131 ++ PRE_first_tail_x15_r0_body.cl131).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1264.next) PRE_first_tail_x15_r0_body.s1266) = true
theorem bodyJs131 : JsHeapAbove PRE_first_tail_x15_r0_body.s1264.next PRE_first_tail_x15_r0_body.s1266 :=
  JsHeapAbove.glueSite bodyJs130 (Nat.le_of_ble_eq_true bodyJsLe131) PRE_first_tail_x15_r0_body.gjk131 PRE_first_tail_x15_r0_body.gjbd131 PRE_first_tail_x15_r0_body.cheap131 PRE_first_tail_x15_r0_body.zclbd131 bodyJsList131

end Host.Ts.Sim.Compose.VWFirst.VW15
