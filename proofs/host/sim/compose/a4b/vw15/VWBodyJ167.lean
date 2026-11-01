import host.sim.compose.a4b.vw15.VWBodyJ166
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl167 : Conv.NClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl167 (PRE_first_tail_x15_r0_body.cncl166 bodyNcl166)

theorem bodyClean167 : Conv.JClean (⟨21485, 18577, 2805801, 7192⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1609 :=
  PRE_first_tail_x15_r0_body.gjcl167 (PRE_first_tail_x15_r0_body.cjcl166 bodyClean166)

kernel_rfl bodyJsLe167 : Nat.ble PRE_first_tail_x15_r0_body.s1605.next PRE_first_tail_x15_r0_body.s1609.next = true
kernel_rfl bodyJsList167 : (PRE_first_tail_x15_r0_body.gjh167 ++ PRE_first_tail_x15_r0_body.cl167).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1609.next) PRE_first_tail_x15_r0_body.s1611) = true
theorem bodyJs167 : JsHeapAbove PRE_first_tail_x15_r0_body.s1609.next PRE_first_tail_x15_r0_body.s1611 :=
  JsHeapAbove.glueSite bodyJs166 (Nat.le_of_ble_eq_true bodyJsLe167) PRE_first_tail_x15_r0_body.gjk167 PRE_first_tail_x15_r0_body.gjbd167 PRE_first_tail_x15_r0_body.cheap167 PRE_first_tail_x15_r0_body.zclbd167 bodyJsList167

end Host.Ts.Sim.Compose.VWFirst.VW15
