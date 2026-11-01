import host.sim.compose.a4b.vw15.VWBodyJ24
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl25 : Conv.NClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s254.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl25 (PRE_first_tail_x15_r0_body.cncl24 bodyNcl24)

theorem bodyClean25 : Conv.JClean (⟨18704, 15792, 2694783, 1148⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s254 :=
  PRE_first_tail_x15_r0_body.gjcl25 (PRE_first_tail_x15_r0_body.cjcl24 bodyClean24)

kernel_rfl bodyJsLe25 : Nat.ble PRE_first_tail_x15_r0_body.s246.next PRE_first_tail_x15_r0_body.s254.next = true
kernel_rfl bodyJsList25 : (PRE_first_tail_x15_r0_body.gjh25 ++ PRE_first_tail_x15_r0_body.cl25).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s254.next) PRE_first_tail_x15_r0_body.s256) = true
theorem bodyJs25 : JsHeapAbove PRE_first_tail_x15_r0_body.s254.next PRE_first_tail_x15_r0_body.s256 :=
  JsHeapAbove.glueSite bodyJs24 (Nat.le_of_ble_eq_true bodyJsLe25) PRE_first_tail_x15_r0_body.gjk25 PRE_first_tail_x15_r0_body.gjbd25 PRE_first_tail_x15_r0_body.cheap25 PRE_first_tail_x15_r0_body.zclbd25 bodyJsList25

end Host.Ts.Sim.Compose.VWFirst.VW15
