import host.sim.compose.a4b.vw15.VWBodyJ172
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl173 : Conv.NClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1667.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl173 (PRE_first_tail_x15_r0_body.cncl172 bodyNcl172)

theorem bodyClean173 : Conv.JClean (⟨21600, 18703, 2810343, 7450⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1667 :=
  PRE_first_tail_x15_r0_body.gjcl173 (PRE_first_tail_x15_r0_body.cjcl172 bodyClean172)

kernel_rfl bodyJsLe173 : Nat.ble PRE_first_tail_x15_r0_body.s1663.next PRE_first_tail_x15_r0_body.s1667.next = true
kernel_rfl bodyJsList173 : (PRE_first_tail_x15_r0_body.gjh173 ++ PRE_first_tail_x15_r0_body.cl173).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1667.next) PRE_first_tail_x15_r0_body.s1669) = true
theorem bodyJs173 : JsHeapAbove PRE_first_tail_x15_r0_body.s1667.next PRE_first_tail_x15_r0_body.s1669 :=
  JsHeapAbove.glueSite bodyJs172 (Nat.le_of_ble_eq_true bodyJsLe173) PRE_first_tail_x15_r0_body.gjk173 PRE_first_tail_x15_r0_body.gjbd173 PRE_first_tail_x15_r0_body.cheap173 PRE_first_tail_x15_r0_body.zclbd173 bodyJsList173

end Host.Ts.Sim.Compose.VWFirst.VW15
