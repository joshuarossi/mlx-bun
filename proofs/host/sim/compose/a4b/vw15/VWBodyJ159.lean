import host.sim.compose.a4b.vw15.VWBodyJ158
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl159 : Conv.NClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl159 (PRE_first_tail_x15_r0_body.cncl158 bodyNcl158)

theorem bodyClean159 : Conv.JClean (⟨21341, 18422, 2800135, 6881⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1540 :=
  PRE_first_tail_x15_r0_body.gjcl159 (PRE_first_tail_x15_r0_body.cjcl158 bodyClean158)

kernel_rfl bodyJsLe159 : Nat.ble PRE_first_tail_x15_r0_body.s1523.next PRE_first_tail_x15_r0_body.s1540.next = true
kernel_rfl bodyJsList159 : (PRE_first_tail_x15_r0_body.gjh159 ++ PRE_first_tail_x15_r0_body.cl159).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1540.next) PRE_first_tail_x15_r0_body.s1542) = true
theorem bodyJs159 : JsHeapAbove PRE_first_tail_x15_r0_body.s1540.next PRE_first_tail_x15_r0_body.s1542 :=
  JsHeapAbove.glueSite bodyJs158 (Nat.le_of_ble_eq_true bodyJsLe159) PRE_first_tail_x15_r0_body.gjk159 PRE_first_tail_x15_r0_body.gjbd159 PRE_first_tail_x15_r0_body.cheap159 PRE_first_tail_x15_r0_body.zclbd159 bodyJsList159

end Host.Ts.Sim.Compose.VWFirst.VW15
