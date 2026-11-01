import host.sim.compose.a4b.vw15.VWBodyJ176
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl177 : Conv.NClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl177 (PRE_first_tail_x15_r0_body.cncl176 bodyNcl176)

theorem bodyClean177 : Conv.JClean (⟨21697, 18794, 2814344, 7656⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1712 :=
  PRE_first_tail_x15_r0_body.gjcl177 (PRE_first_tail_x15_r0_body.cjcl176 bodyClean176)

kernel_rfl bodyJsLe177 : Nat.ble PRE_first_tail_x15_r0_body.s1696.next PRE_first_tail_x15_r0_body.s1712.next = true
kernel_rfl bodyJsList177 : (PRE_first_tail_x15_r0_body.gjh177 ++ PRE_first_tail_x15_r0_body.cl177).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1712.next) PRE_first_tail_x15_r0_body.s1714) = true
theorem bodyJs177 : JsHeapAbove PRE_first_tail_x15_r0_body.s1712.next PRE_first_tail_x15_r0_body.s1714 :=
  JsHeapAbove.glueSite bodyJs176 (Nat.le_of_ble_eq_true bodyJsLe177) PRE_first_tail_x15_r0_body.gjk177 PRE_first_tail_x15_r0_body.gjbd177 PRE_first_tail_x15_r0_body.cheap177 PRE_first_tail_x15_r0_body.zclbd177 bodyJsList177

end Host.Ts.Sim.Compose.VWFirst.VW15
