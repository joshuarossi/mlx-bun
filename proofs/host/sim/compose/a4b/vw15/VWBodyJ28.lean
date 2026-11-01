import host.sim.compose.a4b.vw15.VWBodyJ27
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl28 : Conv.NClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s283.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl28 (PRE_first_tail_x15_r0_body.cncl27 bodyNcl27)

theorem bodyClean28 : Conv.JClean (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s283 :=
  PRE_first_tail_x15_r0_body.gjcl28 (PRE_first_tail_x15_r0_body.cjcl27 bodyClean27)

kernel_rfl bodyJsLe28 : Nat.ble PRE_first_tail_x15_r0_body.s275.next PRE_first_tail_x15_r0_body.s283.next = true
kernel_rfl bodyJsList28 : (PRE_first_tail_x15_r0_body.gjh28 ++ PRE_first_tail_x15_r0_body.cl28).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s283.next) PRE_first_tail_x15_r0_body.s285) = true
theorem bodyJs28 : JsHeapAbove PRE_first_tail_x15_r0_body.s283.next PRE_first_tail_x15_r0_body.s285 :=
  JsHeapAbove.glueSite bodyJs27 (Nat.le_of_ble_eq_true bodyJsLe28) PRE_first_tail_x15_r0_body.gjk28 PRE_first_tail_x15_r0_body.gjbd28 PRE_first_tail_x15_r0_body.cheap28 PRE_first_tail_x15_r0_body.zclbd28 bodyJsList28

end Host.Ts.Sim.Compose.VWFirst.VW15
