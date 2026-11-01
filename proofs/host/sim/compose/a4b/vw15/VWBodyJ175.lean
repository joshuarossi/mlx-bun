import host.sim.compose.a4b.vw15.VWBodyJ174
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl175 : Conv.NClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1692.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl175 (PRE_first_tail_x15_r0_body.cncl174 bodyNcl174)

theorem bodyClean175 : Conv.JClean (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1692 :=
  PRE_first_tail_x15_r0_body.gjcl175 (PRE_first_tail_x15_r0_body.cjcl174 bodyClean174)

kernel_rfl bodyJsLe175 : Nat.ble PRE_first_tail_x15_r0_body.s1684.next PRE_first_tail_x15_r0_body.s1692.next = true
kernel_rfl bodyJsList175 : (PRE_first_tail_x15_r0_body.gjh175 ++ PRE_first_tail_x15_r0_body.cl175).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1692.next) PRE_first_tail_x15_r0_body.s1694) = true
theorem bodyJs175 : JsHeapAbove PRE_first_tail_x15_r0_body.s1692.next PRE_first_tail_x15_r0_body.s1694 :=
  JsHeapAbove.glueSite bodyJs174 (Nat.le_of_ble_eq_true bodyJsLe175) PRE_first_tail_x15_r0_body.gjk175 PRE_first_tail_x15_r0_body.gjbd175 PRE_first_tail_x15_r0_body.cheap175 PRE_first_tail_x15_r0_body.zclbd175 bodyJsList175

end Host.Ts.Sim.Compose.VWFirst.VW15
