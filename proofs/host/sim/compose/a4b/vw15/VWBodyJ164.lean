import host.sim.compose.a4b.vw15.VWBodyJ163
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl164 : Conv.NClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1581.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl164 (PRE_first_tail_x15_r0_body.cncl163 bodyNcl163)

theorem bodyClean164 : Conv.JClean (⟨21421, 18529, 2803175, 7066⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1581 :=
  PRE_first_tail_x15_r0_body.gjcl164 (PRE_first_tail_x15_r0_body.cjcl163 bodyClean163)

kernel_rfl bodyJsLe164 : Nat.ble PRE_first_tail_x15_r0_body.s1577.next PRE_first_tail_x15_r0_body.s1581.next = true
kernel_rfl bodyJsList164 : (PRE_first_tail_x15_r0_body.gjh164 ++ PRE_first_tail_x15_r0_body.cl164).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1581.next) PRE_first_tail_x15_r0_body.s1583) = true
theorem bodyJs164 : JsHeapAbove PRE_first_tail_x15_r0_body.s1581.next PRE_first_tail_x15_r0_body.s1583 :=
  JsHeapAbove.glueSite bodyJs163 (Nat.le_of_ble_eq_true bodyJsLe164) PRE_first_tail_x15_r0_body.gjk164 PRE_first_tail_x15_r0_body.gjbd164 PRE_first_tail_x15_r0_body.cheap164 PRE_first_tail_x15_r0_body.zclbd164 bodyJsList164

end Host.Ts.Sim.Compose.VWFirst.VW15
