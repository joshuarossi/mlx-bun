import host.sim.compose.a4b.vw15.VWBodyJ137
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl138 : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl138 (PRE_first_tail_x15_r0_body.cncl137 bodyNcl137)

theorem bodyClean138 : Conv.JClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1339 :=
  PRE_first_tail_x15_r0_body.gjcl138 (PRE_first_tail_x15_r0_body.cjcl137 bodyClean137)

kernel_rfl bodyJsLe138 : Nat.ble PRE_first_tail_x15_r0_body.s1322.next PRE_first_tail_x15_r0_body.s1339.next = true
kernel_rfl bodyJsList138 : (PRE_first_tail_x15_r0_body.gjh138 ++ PRE_first_tail_x15_r0_body.cl138).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1339.next) PRE_first_tail_x15_r0_body.s1341) = true
theorem bodyJs138 : JsHeapAbove PRE_first_tail_x15_r0_body.s1339.next PRE_first_tail_x15_r0_body.s1341 :=
  JsHeapAbove.glueSite bodyJs137 (Nat.le_of_ble_eq_true bodyJsLe138) PRE_first_tail_x15_r0_body.gjk138 PRE_first_tail_x15_r0_body.gjbd138 PRE_first_tail_x15_r0_body.cheap138 PRE_first_tail_x15_r0_body.zclbd138 bodyJsList138

end Host.Ts.Sim.Compose.VWFirst.VW15
