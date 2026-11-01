import host.sim.compose.a4b.vw15.VWBodyJ9
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl10 : Conv.NClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl10 (PRE_first_tail_x15_r0_body.cncl9 bodyNcl9)

theorem bodyClean10 : Conv.JClean (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s110 :=
  PRE_first_tail_x15_r0_body.gjcl10 (PRE_first_tail_x15_r0_body.cjcl9 bodyClean9)

kernel_rfl bodyJsLe10 : Nat.ble PRE_first_tail_x15_r0_body.s102.next PRE_first_tail_x15_r0_body.s110.next = true
kernel_rfl bodyJsList10 : (PRE_first_tail_x15_r0_body.gjh10 ++ PRE_first_tail_x15_r0_body.cl10).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s110.next) PRE_first_tail_x15_r0_body.s112) = true
theorem bodyJs10 : JsHeapAbove PRE_first_tail_x15_r0_body.s110.next PRE_first_tail_x15_r0_body.s112 :=
  JsHeapAbove.glueSite bodyJs9 (Nat.le_of_ble_eq_true bodyJsLe10) PRE_first_tail_x15_r0_body.gjk10 PRE_first_tail_x15_r0_body.gjbd10 PRE_first_tail_x15_r0_body.cheap10 PRE_first_tail_x15_r0_body.zclbd10 bodyJsList10

end Host.Ts.Sim.Compose.VWFirst.VW15
