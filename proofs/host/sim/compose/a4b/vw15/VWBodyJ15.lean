import host.sim.compose.a4b.vw15.VWBodyJ14
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl15 : Conv.NClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s160.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl15 (PRE_first_tail_x15_r0_body.cncl14 bodyNcl14)

theorem bodyClean15 : Conv.JClean (⟨18509, 15578, 2687131, 725⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s160 :=
  PRE_first_tail_x15_r0_body.gjcl15 (PRE_first_tail_x15_r0_body.cjcl14 bodyClean14)

kernel_rfl bodyJsLe15 : Nat.ble PRE_first_tail_x15_r0_body.s143.next PRE_first_tail_x15_r0_body.s160.next = true
kernel_rfl bodyJsList15 : (PRE_first_tail_x15_r0_body.gjh15 ++ PRE_first_tail_x15_r0_body.cl15).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s160.next) PRE_first_tail_x15_r0_body.s162) = true
theorem bodyJs15 : JsHeapAbove PRE_first_tail_x15_r0_body.s160.next PRE_first_tail_x15_r0_body.s162 :=
  JsHeapAbove.glueSite bodyJs14 (Nat.le_of_ble_eq_true bodyJsLe15) PRE_first_tail_x15_r0_body.gjk15 PRE_first_tail_x15_r0_body.gjbd15 PRE_first_tail_x15_r0_body.cheap15 PRE_first_tail_x15_r0_body.zclbd15 bodyJsList15

end Host.Ts.Sim.Compose.VWFirst.VW15
