import host.sim.compose.a4b.vw15.VWBodyJ165
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl166 : Conv.NClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1605.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl166 (PRE_first_tail_x15_r0_body.cncl165 bodyNcl165)

theorem bodyClean166 : Conv.JClean (⟨21478, 18573, 2805513, 7175⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1605 :=
  PRE_first_tail_x15_r0_body.gjcl166 (PRE_first_tail_x15_r0_body.cjcl165 bodyClean165)

kernel_rfl bodyJsLe166 : Nat.ble PRE_first_tail_x15_r0_body.s1597.next PRE_first_tail_x15_r0_body.s1605.next = true
kernel_rfl bodyJsList166 : (PRE_first_tail_x15_r0_body.gjh166 ++ PRE_first_tail_x15_r0_body.cl166).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1605.next) PRE_first_tail_x15_r0_body.s1607) = true
theorem bodyJs166 : JsHeapAbove PRE_first_tail_x15_r0_body.s1605.next PRE_first_tail_x15_r0_body.s1607 :=
  JsHeapAbove.glueSite bodyJs165 (Nat.le_of_ble_eq_true bodyJsLe166) PRE_first_tail_x15_r0_body.gjk166 PRE_first_tail_x15_r0_body.gjbd166 PRE_first_tail_x15_r0_body.cheap166 PRE_first_tail_x15_r0_body.zclbd166 bodyJsList166

end Host.Ts.Sim.Compose.VWFirst.VW15
