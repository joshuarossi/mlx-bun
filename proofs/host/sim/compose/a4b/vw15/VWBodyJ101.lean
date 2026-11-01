import host.sim.compose.a4b.vw15.VWBodyJ100
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl101 : Conv.NClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s977.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl101 (PRE_first_tail_x15_r0_body.cncl100 bodyNcl100)

theorem bodyClean101 : Conv.JClean (⟨20184, 17281, 2753835, 4372⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s977 :=
  PRE_first_tail_x15_r0_body.gjcl101 (PRE_first_tail_x15_r0_body.cjcl100 bodyClean100)

kernel_rfl bodyJsLe101 : Nat.ble PRE_first_tail_x15_r0_body.s973.next PRE_first_tail_x15_r0_body.s977.next = true
kernel_rfl bodyJsList101 : (PRE_first_tail_x15_r0_body.gjh101 ++ PRE_first_tail_x15_r0_body.cl101).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s977.next) PRE_first_tail_x15_r0_body.s979) = true
theorem bodyJs101 : JsHeapAbove PRE_first_tail_x15_r0_body.s977.next PRE_first_tail_x15_r0_body.s979 :=
  JsHeapAbove.glueSite bodyJs100 (Nat.le_of_ble_eq_true bodyJsLe101) PRE_first_tail_x15_r0_body.gjk101 PRE_first_tail_x15_r0_body.gjbd101 PRE_first_tail_x15_r0_body.cheap101 PRE_first_tail_x15_r0_body.zclbd101 bodyJsList101

end Host.Ts.Sim.Compose.VWFirst.VW15
