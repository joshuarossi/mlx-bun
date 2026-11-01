import host.sim.compose.a4b.vw15.VWBodyJ0
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl1 : Conv.NClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s24.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl1 (PRE_first_tail_x15_r0_body.cncl0 bodyNcl0)

theorem bodyClean1 : Conv.JClean (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s24 :=
  PRE_first_tail_x15_r0_body.gjcl1 (PRE_first_tail_x15_r0_body.cjcl0 bodyClean0)

kernel_rfl bodyJsLe1 : Nat.ble PRE_first_tail_x15_r0_body.s15.next PRE_first_tail_x15_r0_body.s24.next = true
kernel_rfl bodyJsList1 : (PRE_first_tail_x15_r0_body.gjh1 ++ PRE_first_tail_x15_r0_body.cl1).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s24.next) PRE_first_tail_x15_r0_body.s26) = true
theorem bodyJs1 : JsHeapAbove PRE_first_tail_x15_r0_body.s24.next PRE_first_tail_x15_r0_body.s26 :=
  JsHeapAbove.glueSite bodyJs0 (Nat.le_of_ble_eq_true bodyJsLe1) PRE_first_tail_x15_r0_body.gjk1 PRE_first_tail_x15_r0_body.gjbd1 PRE_first_tail_x15_r0_body.cheap1 PRE_first_tail_x15_r0_body.zclbd1 bodyJsList1

end Host.Ts.Sim.Compose.VWFirst.VW15
