import host.sim.compose.a4b.vw15.VWBodyJ21
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl22 : Conv.NClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s225.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl22 (PRE_first_tail_x15_r0_body.cncl21 bodyNcl21)

theorem bodyClean22 : Conv.JClean (⟨18646, 15729, 2692505, 1019⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s225 :=
  PRE_first_tail_x15_r0_body.gjcl22 (PRE_first_tail_x15_r0_body.cjcl21 bodyClean21)

kernel_rfl bodyJsLe22 : Nat.ble PRE_first_tail_x15_r0_body.s217.next PRE_first_tail_x15_r0_body.s225.next = true
kernel_rfl bodyJsList22 : (PRE_first_tail_x15_r0_body.gjh22 ++ PRE_first_tail_x15_r0_body.cl22).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s225.next) PRE_first_tail_x15_r0_body.s227) = true
theorem bodyJs22 : JsHeapAbove PRE_first_tail_x15_r0_body.s225.next PRE_first_tail_x15_r0_body.s227 :=
  JsHeapAbove.glueSite bodyJs21 (Nat.le_of_ble_eq_true bodyJsLe22) PRE_first_tail_x15_r0_body.gjk22 PRE_first_tail_x15_r0_body.gjbd22 PRE_first_tail_x15_r0_body.cheap22 PRE_first_tail_x15_r0_body.zclbd22 bodyJsList22

end Host.Ts.Sim.Compose.VWFirst.VW15
