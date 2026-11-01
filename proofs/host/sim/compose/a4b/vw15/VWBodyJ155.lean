import host.sim.compose.a4b.vw15.VWBodyJ154
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl155 : Conv.NClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1494.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl155 (PRE_first_tail_x15_r0_body.cncl154 bodyNcl154)

theorem bodyClean155 : Conv.JClean (⟨21249, 18340, 2796385, 6679⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1494 :=
  PRE_first_tail_x15_r0_body.gjcl155 (PRE_first_tail_x15_r0_body.cjcl154 bodyClean154)

kernel_rfl bodyJsLe155 : Nat.ble PRE_first_tail_x15_r0_body.s1490.next PRE_first_tail_x15_r0_body.s1494.next = true
kernel_rfl bodyJsList155 : (PRE_first_tail_x15_r0_body.gjh155 ++ PRE_first_tail_x15_r0_body.cl155).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1494.next) PRE_first_tail_x15_r0_body.s1496) = true
theorem bodyJs155 : JsHeapAbove PRE_first_tail_x15_r0_body.s1494.next PRE_first_tail_x15_r0_body.s1496 :=
  JsHeapAbove.glueSite bodyJs154 (Nat.le_of_ble_eq_true bodyJsLe155) PRE_first_tail_x15_r0_body.gjk155 PRE_first_tail_x15_r0_body.gjbd155 PRE_first_tail_x15_r0_body.cheap155 PRE_first_tail_x15_r0_body.zclbd155 bodyJsList155

end Host.Ts.Sim.Compose.VWFirst.VW15
