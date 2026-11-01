import host.sim.compose.a4b.vw15.VWBodyJ93
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl94 : Conv.NClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl94 (PRE_first_tail_x15_r0_body.cncl93 bodyNcl93)

theorem bodyClean94 : Conv.JClean (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s915 :=
  PRE_first_tail_x15_r0_body.gjcl94 (PRE_first_tail_x15_r0_body.cjcl93 bodyClean93)

kernel_rfl bodyJsLe94 : Nat.ble PRE_first_tail_x15_r0_body.s907.next PRE_first_tail_x15_r0_body.s915.next = true
kernel_rfl bodyJsList94 : (PRE_first_tail_x15_r0_body.gjh94 ++ PRE_first_tail_x15_r0_body.cl94).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s915.next) PRE_first_tail_x15_r0_body.s917) = true
theorem bodyJs94 : JsHeapAbove PRE_first_tail_x15_r0_body.s915.next PRE_first_tail_x15_r0_body.s917 :=
  JsHeapAbove.glueSite bodyJs93 (Nat.le_of_ble_eq_true bodyJsLe94) PRE_first_tail_x15_r0_body.gjk94 PRE_first_tail_x15_r0_body.gjbd94 PRE_first_tail_x15_r0_body.cheap94 PRE_first_tail_x15_r0_body.zclbd94 bodyJsList94

end Host.Ts.Sim.Compose.VWFirst.VW15
