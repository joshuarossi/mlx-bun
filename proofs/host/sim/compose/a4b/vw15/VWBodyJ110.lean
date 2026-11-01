import host.sim.compose.a4b.vw15.VWBodyJ109
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl110 : Conv.NClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1063.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl110 (PRE_first_tail_x15_r0_body.cncl109 bodyNcl109)

theorem bodyClean110 : Conv.JClean (⟨20363, 17455, 2760995, 4756⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1063 :=
  PRE_first_tail_x15_r0_body.gjcl110 (PRE_first_tail_x15_r0_body.cjcl109 bodyClean109)

kernel_rfl bodyJsLe110 : Nat.ble PRE_first_tail_x15_r0_body.s1059.next PRE_first_tail_x15_r0_body.s1063.next = true
kernel_rfl bodyJsList110 : (PRE_first_tail_x15_r0_body.gjh110 ++ PRE_first_tail_x15_r0_body.cl110).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1063.next) PRE_first_tail_x15_r0_body.s1065) = true
theorem bodyJs110 : JsHeapAbove PRE_first_tail_x15_r0_body.s1063.next PRE_first_tail_x15_r0_body.s1065 :=
  JsHeapAbove.glueSite bodyJs109 (Nat.le_of_ble_eq_true bodyJsLe110) PRE_first_tail_x15_r0_body.gjk110 PRE_first_tail_x15_r0_body.gjbd110 PRE_first_tail_x15_r0_body.cheap110 PRE_first_tail_x15_r0_body.zclbd110 bodyJsList110

end Host.Ts.Sim.Compose.VWFirst.VW15
