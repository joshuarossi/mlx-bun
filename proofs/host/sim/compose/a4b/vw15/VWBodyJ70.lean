import host.sim.compose.a4b.vw15.VWBodyJ69
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl70 : Conv.NClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl70 (PRE_first_tail_x15_r0_body.cncl69 bodyNcl69)

theorem bodyClean70 : Conv.JClean (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s685 :=
  PRE_first_tail_x15_r0_body.gjcl70 (PRE_first_tail_x15_r0_body.cjcl69 bodyClean69)

kernel_rfl bodyJsLe70 : Nat.ble PRE_first_tail_x15_r0_body.s677.next PRE_first_tail_x15_r0_body.s685.next = true
kernel_rfl bodyJsList70 : (PRE_first_tail_x15_r0_body.gjh70 ++ PRE_first_tail_x15_r0_body.cl70).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s685.next) PRE_first_tail_x15_r0_body.s687) = true
theorem bodyJs70 : JsHeapAbove PRE_first_tail_x15_r0_body.s685.next PRE_first_tail_x15_r0_body.s687 :=
  JsHeapAbove.glueSite bodyJs69 (Nat.le_of_ble_eq_true bodyJsLe70) PRE_first_tail_x15_r0_body.gjk70 PRE_first_tail_x15_r0_body.gjbd70 PRE_first_tail_x15_r0_body.cheap70 PRE_first_tail_x15_r0_body.zclbd70 bodyJsList70

end Host.Ts.Sim.Compose.VWFirst.VW15
