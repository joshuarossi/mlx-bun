import host.sim.compose.a4b.vw15.VWBodyJ173
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl174 : Conv.NClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1684.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl174 (PRE_first_tail_x15_r0_body.cncl173 bodyNcl173)

theorem bodyClean174 : Conv.JClean (⟨21634, 18722, 2811819, 7523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1684 :=
  PRE_first_tail_x15_r0_body.gjcl174 (PRE_first_tail_x15_r0_body.cjcl173 bodyClean173)

kernel_rfl bodyJsLe174 : Nat.ble PRE_first_tail_x15_r0_body.s1667.next PRE_first_tail_x15_r0_body.s1684.next = true
kernel_rfl bodyJsList174 : (PRE_first_tail_x15_r0_body.gjh174 ++ PRE_first_tail_x15_r0_body.cl174).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1684.next) PRE_first_tail_x15_r0_body.s1686) = true
theorem bodyJs174 : JsHeapAbove PRE_first_tail_x15_r0_body.s1684.next PRE_first_tail_x15_r0_body.s1686 :=
  JsHeapAbove.glueSite bodyJs173 (Nat.le_of_ble_eq_true bodyJsLe174) PRE_first_tail_x15_r0_body.gjk174 PRE_first_tail_x15_r0_body.gjbd174 PRE_first_tail_x15_r0_body.cheap174 PRE_first_tail_x15_r0_body.zclbd174 bodyJsList174

end Host.Ts.Sim.Compose.VWFirst.VW15
