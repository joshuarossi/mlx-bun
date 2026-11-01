import host.sim.compose.a4b.vw15.VWBodyJ184
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl185 : Conv.NClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1782.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl185 (PRE_first_tail_x15_r0_body.cncl184 bodyNcl184)

theorem bodyClean185 : Conv.JClean (⟨21836, 18940, 2819771, 7963⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1782 :=
  PRE_first_tail_x15_r0_body.gjcl185 (PRE_first_tail_x15_r0_body.cjcl184 bodyClean184)

kernel_rfl bodyJsLe185 : Nat.ble PRE_first_tail_x15_r0_body.s1778.next PRE_first_tail_x15_r0_body.s1782.next = true
kernel_rfl bodyJsList185 : (PRE_first_tail_x15_r0_body.gjh185 ++ PRE_first_tail_x15_r0_body.cl185).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1782.next) PRE_first_tail_x15_r0_body.s1784) = true
theorem bodyJs185 : JsHeapAbove PRE_first_tail_x15_r0_body.s1782.next PRE_first_tail_x15_r0_body.s1784 :=
  JsHeapAbove.glueSite bodyJs184 (Nat.le_of_ble_eq_true bodyJsLe185) PRE_first_tail_x15_r0_body.gjk185 PRE_first_tail_x15_r0_body.gjbd185 PRE_first_tail_x15_r0_body.cheap185 PRE_first_tail_x15_r0_body.zclbd185 bodyJsList185

end Host.Ts.Sim.Compose.VWFirst.VW15
