import host.sim.compose.a4b.vw15.VWBodyJ136
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl137 : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl137 (PRE_first_tail_x15_r0_body.cncl136 bodyNcl136)

theorem bodyClean137 : Conv.JClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1322 :=
  PRE_first_tail_x15_r0_body.gjcl137 (PRE_first_tail_x15_r0_body.cjcl136 bodyClean136)

kernel_rfl bodyJsLe137 : Nat.ble PRE_first_tail_x15_r0_body.s1318.next PRE_first_tail_x15_r0_body.s1322.next = true
kernel_rfl bodyJsList137 : (PRE_first_tail_x15_r0_body.gjh137 ++ PRE_first_tail_x15_r0_body.cl137).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1322.next) PRE_first_tail_x15_r0_body.s1324) = true
theorem bodyJs137 : JsHeapAbove PRE_first_tail_x15_r0_body.s1322.next PRE_first_tail_x15_r0_body.s1324 :=
  JsHeapAbove.glueSite bodyJs136 (Nat.le_of_ble_eq_true bodyJsLe137) PRE_first_tail_x15_r0_body.gjk137 PRE_first_tail_x15_r0_body.gjbd137 PRE_first_tail_x15_r0_body.cheap137 PRE_first_tail_x15_r0_body.zclbd137 bodyJsList137

end Host.Ts.Sim.Compose.VWFirst.VW15
