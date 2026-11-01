import host.sim.compose.a4b.vw15.VWBodyJ161
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl162 : Conv.NClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1569.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl162 (PRE_first_tail_x15_r0_body.cncl161 bodyNcl161)

theorem bodyClean162 : Conv.JClean (⟨21398, 18485, 2802391, 7010⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1569 :=
  PRE_first_tail_x15_r0_body.gjcl162 (PRE_first_tail_x15_r0_body.cjcl161 bodyClean161)

kernel_rfl bodyJsLe162 : Nat.ble PRE_first_tail_x15_r0_body.s1552.next PRE_first_tail_x15_r0_body.s1569.next = true
kernel_rfl bodyJsList162 : (PRE_first_tail_x15_r0_body.gjh162 ++ PRE_first_tail_x15_r0_body.cl162).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1569.next) PRE_first_tail_x15_r0_body.s1571) = true
theorem bodyJs162 : JsHeapAbove PRE_first_tail_x15_r0_body.s1569.next PRE_first_tail_x15_r0_body.s1571 :=
  JsHeapAbove.glueSite bodyJs161 (Nat.le_of_ble_eq_true bodyJsLe162) PRE_first_tail_x15_r0_body.gjk162 PRE_first_tail_x15_r0_body.gjbd162 PRE_first_tail_x15_r0_body.cheap162 PRE_first_tail_x15_r0_body.zclbd162 bodyJsList162

end Host.Ts.Sim.Compose.VWFirst.VW15
