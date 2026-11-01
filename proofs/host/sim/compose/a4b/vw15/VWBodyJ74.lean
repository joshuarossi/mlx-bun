import host.sim.compose.a4b.vw15.VWBodyJ73
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl74 : Conv.NClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s718.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl74 (PRE_first_tail_x15_r0_body.cncl73 bodyNcl73)

theorem bodyClean74 : Conv.JClean (⟨19655, 16744, 2732743, 3217⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s718 :=
  PRE_first_tail_x15_r0_body.gjcl74 (PRE_first_tail_x15_r0_body.cjcl73 bodyClean73)

kernel_rfl bodyJsLe74 : Nat.ble PRE_first_tail_x15_r0_body.s714.next PRE_first_tail_x15_r0_body.s718.next = true
kernel_rfl bodyJsList74 : (PRE_first_tail_x15_r0_body.gjh74 ++ PRE_first_tail_x15_r0_body.cl74).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s718.next) PRE_first_tail_x15_r0_body.s720) = true
theorem bodyJs74 : JsHeapAbove PRE_first_tail_x15_r0_body.s718.next PRE_first_tail_x15_r0_body.s720 :=
  JsHeapAbove.glueSite bodyJs73 (Nat.le_of_ble_eq_true bodyJsLe74) PRE_first_tail_x15_r0_body.gjk74 PRE_first_tail_x15_r0_body.gjbd74 PRE_first_tail_x15_r0_body.cheap74 PRE_first_tail_x15_r0_body.zclbd74 bodyJsList74

end Host.Ts.Sim.Compose.VWFirst.VW15
