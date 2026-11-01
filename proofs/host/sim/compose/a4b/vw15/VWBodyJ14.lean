import host.sim.compose.a4b.vw15.VWBodyJ13
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl14 : Conv.NClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s143.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl14 (PRE_first_tail_x15_r0_body.cncl13 bodyNcl13)

theorem bodyClean14 : Conv.JClean (⟨18475, 15559, 2685659, 652⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s143 :=
  PRE_first_tail_x15_r0_body.gjcl14 (PRE_first_tail_x15_r0_body.cjcl13 bodyClean13)

kernel_rfl bodyJsLe14 : Nat.ble PRE_first_tail_x15_r0_body.s139.next PRE_first_tail_x15_r0_body.s143.next = true
kernel_rfl bodyJsList14 : (PRE_first_tail_x15_r0_body.gjh14 ++ PRE_first_tail_x15_r0_body.cl14).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s143.next) PRE_first_tail_x15_r0_body.s145) = true
theorem bodyJs14 : JsHeapAbove PRE_first_tail_x15_r0_body.s143.next PRE_first_tail_x15_r0_body.s145 :=
  JsHeapAbove.glueSite bodyJs13 (Nat.le_of_ble_eq_true bodyJsLe14) PRE_first_tail_x15_r0_body.gjk14 PRE_first_tail_x15_r0_body.gjbd14 PRE_first_tail_x15_r0_body.cheap14 PRE_first_tail_x15_r0_body.zclbd14 bodyJsList14

end Host.Ts.Sim.Compose.VWFirst.VW15
