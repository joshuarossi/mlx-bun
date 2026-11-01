import host.sim.compose.a4b.vw15.VWBodyJ175
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl176 : Conv.NClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1696.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl176 (PRE_first_tail_x15_r0_body.cncl175 bodyNcl175)

theorem bodyClean176 : Conv.JClean (⟨21657, 18766, 2812603, 7579⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1696 :=
  PRE_first_tail_x15_r0_body.gjcl176 (PRE_first_tail_x15_r0_body.cjcl175 bodyClean175)

kernel_rfl bodyJsLe176 : Nat.ble PRE_first_tail_x15_r0_body.s1692.next PRE_first_tail_x15_r0_body.s1696.next = true
kernel_rfl bodyJsList176 : (PRE_first_tail_x15_r0_body.gjh176 ++ PRE_first_tail_x15_r0_body.cl176).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1696.next) PRE_first_tail_x15_r0_body.s1698) = true
theorem bodyJs176 : JsHeapAbove PRE_first_tail_x15_r0_body.s1696.next PRE_first_tail_x15_r0_body.s1698 :=
  JsHeapAbove.glueSite bodyJs175 (Nat.le_of_ble_eq_true bodyJsLe176) PRE_first_tail_x15_r0_body.gjk176 PRE_first_tail_x15_r0_body.gjbd176 PRE_first_tail_x15_r0_body.cheap176 PRE_first_tail_x15_r0_body.zclbd176 bodyJsList176

end Host.Ts.Sim.Compose.VWFirst.VW15
