import host.sim.compose.a4b.vw15.VWBodyJ183
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl184 : Conv.NClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1778.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl184 (PRE_first_tail_x15_r0_body.cncl183 bodyNcl183)

theorem bodyClean184 : Conv.JClean (⟨21829, 18936, 2819483, 7946⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1778 :=
  PRE_first_tail_x15_r0_body.gjcl184 (PRE_first_tail_x15_r0_body.cjcl183 bodyClean183)

kernel_rfl bodyJsLe184 : Nat.ble PRE_first_tail_x15_r0_body.s1770.next PRE_first_tail_x15_r0_body.s1778.next = true
kernel_rfl bodyJsList184 : (PRE_first_tail_x15_r0_body.gjh184 ++ PRE_first_tail_x15_r0_body.cl184).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1778.next) PRE_first_tail_x15_r0_body.s1780) = true
theorem bodyJs184 : JsHeapAbove PRE_first_tail_x15_r0_body.s1778.next PRE_first_tail_x15_r0_body.s1780 :=
  JsHeapAbove.glueSite bodyJs183 (Nat.le_of_ble_eq_true bodyJsLe184) PRE_first_tail_x15_r0_body.gjk184 PRE_first_tail_x15_r0_body.gjbd184 PRE_first_tail_x15_r0_body.cheap184 PRE_first_tail_x15_r0_body.zclbd184 bodyJsList184

end Host.Ts.Sim.Compose.VWFirst.VW15
