import host.sim.compose.a4b.vw15.VWBodyJ108
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl109 : Conv.NClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1059.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl109 (PRE_first_tail_x15_r0_body.cncl108 bodyNcl108)

theorem bodyClean109 : Conv.JClean (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1059 :=
  PRE_first_tail_x15_r0_body.gjcl109 (PRE_first_tail_x15_r0_body.cjcl108 bodyClean108)

kernel_rfl bodyJsLe109 : Nat.ble PRE_first_tail_x15_r0_body.s1051.next PRE_first_tail_x15_r0_body.s1059.next = true
kernel_rfl bodyJsList109 : (PRE_first_tail_x15_r0_body.gjh109 ++ PRE_first_tail_x15_r0_body.cl109).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1059.next) PRE_first_tail_x15_r0_body.s1061) = true
theorem bodyJs109 : JsHeapAbove PRE_first_tail_x15_r0_body.s1059.next PRE_first_tail_x15_r0_body.s1061 :=
  JsHeapAbove.glueSite bodyJs108 (Nat.le_of_ble_eq_true bodyJsLe109) PRE_first_tail_x15_r0_body.gjk109 PRE_first_tail_x15_r0_body.gjbd109 PRE_first_tail_x15_r0_body.cheap109 PRE_first_tail_x15_r0_body.zclbd109 bodyJsList109

end Host.Ts.Sim.Compose.VWFirst.VW15
