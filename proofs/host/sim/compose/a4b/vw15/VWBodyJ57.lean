import host.sim.compose.a4b.vw15.VWBodyJ56
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl57 : Conv.NClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s562.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl57 (PRE_first_tail_x15_r0_body.cncl56 bodyNcl56)

theorem bodyClean57 : Conv.JClean (⟨19337, 16424, 2720168, 2526⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s562 :=
  PRE_first_tail_x15_r0_body.gjcl57 (PRE_first_tail_x15_r0_body.cjcl56 bodyClean56)

kernel_rfl bodyJsLe57 : Nat.ble PRE_first_tail_x15_r0_body.s546.next PRE_first_tail_x15_r0_body.s562.next = true
kernel_rfl bodyJsList57 : (PRE_first_tail_x15_r0_body.gjh57 ++ PRE_first_tail_x15_r0_body.cl57).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s562.next) PRE_first_tail_x15_r0_body.s564) = true
theorem bodyJs57 : JsHeapAbove PRE_first_tail_x15_r0_body.s562.next PRE_first_tail_x15_r0_body.s564 :=
  JsHeapAbove.glueSite bodyJs56 (Nat.le_of_ble_eq_true bodyJsLe57) PRE_first_tail_x15_r0_body.gjk57 PRE_first_tail_x15_r0_body.gjbd57 PRE_first_tail_x15_r0_body.cheap57 PRE_first_tail_x15_r0_body.zclbd57 bodyJsList57

end Host.Ts.Sim.Compose.VWFirst.VW15
