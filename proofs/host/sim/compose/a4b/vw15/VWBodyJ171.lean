import host.sim.compose.a4b.vw15.VWBodyJ170
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl171 : Conv.NClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl171 (PRE_first_tail_x15_r0_body.cncl170 bodyNcl170)

theorem bodyClean171 : Conv.JClean (⟨21577, 18659, 2809559, 7394⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1655 :=
  PRE_first_tail_x15_r0_body.gjcl171 (PRE_first_tail_x15_r0_body.cjcl170 bodyClean170)

kernel_rfl bodyJsLe171 : Nat.ble PRE_first_tail_x15_r0_body.s1638.next PRE_first_tail_x15_r0_body.s1655.next = true
kernel_rfl bodyJsList171 : (PRE_first_tail_x15_r0_body.gjh171 ++ PRE_first_tail_x15_r0_body.cl171).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1655.next) PRE_first_tail_x15_r0_body.s1657) = true
theorem bodyJs171 : JsHeapAbove PRE_first_tail_x15_r0_body.s1655.next PRE_first_tail_x15_r0_body.s1657 :=
  JsHeapAbove.glueSite bodyJs170 (Nat.le_of_ble_eq_true bodyJsLe171) PRE_first_tail_x15_r0_body.gjk171 PRE_first_tail_x15_r0_body.gjbd171 PRE_first_tail_x15_r0_body.cheap171 PRE_first_tail_x15_r0_body.zclbd171 bodyJsList171

end Host.Ts.Sim.Compose.VWFirst.VW15
