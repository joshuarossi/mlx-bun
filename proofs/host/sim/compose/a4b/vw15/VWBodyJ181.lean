import host.sim.compose.a4b.vw15.VWBodyJ180
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl181 : Conv.NClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl181 (PRE_first_tail_x15_r0_body.cncl180 bodyNcl180)

theorem bodyClean181 : Conv.JClean (⟨21772, 18873, 2817223, 7817⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1749 :=
  PRE_first_tail_x15_r0_body.gjcl181 (PRE_first_tail_x15_r0_body.cjcl180 bodyClean180)

kernel_rfl bodyJsLe181 : Nat.ble PRE_first_tail_x15_r0_body.s1741.next PRE_first_tail_x15_r0_body.s1749.next = true
kernel_rfl bodyJsList181 : (PRE_first_tail_x15_r0_body.gjh181 ++ PRE_first_tail_x15_r0_body.cl181).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1749.next) PRE_first_tail_x15_r0_body.s1751) = true
theorem bodyJs181 : JsHeapAbove PRE_first_tail_x15_r0_body.s1749.next PRE_first_tail_x15_r0_body.s1751 :=
  JsHeapAbove.glueSite bodyJs180 (Nat.le_of_ble_eq_true bodyJsLe181) PRE_first_tail_x15_r0_body.gjk181 PRE_first_tail_x15_r0_body.gjbd181 PRE_first_tail_x15_r0_body.cheap181 PRE_first_tail_x15_r0_body.zclbd181 bodyJsList181

end Host.Ts.Sim.Compose.VWFirst.VW15
