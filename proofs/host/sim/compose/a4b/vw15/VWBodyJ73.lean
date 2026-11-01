import host.sim.compose.a4b.vw15.VWBodyJ72
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl73 : Conv.NClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl73 (PRE_first_tail_x15_r0_body.cncl72 bodyNcl72)

theorem bodyClean73 : Conv.JClean (⟨19648, 16740, 2732455, 3200⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s714 :=
  PRE_first_tail_x15_r0_body.gjcl73 (PRE_first_tail_x15_r0_body.cjcl72 bodyClean72)

kernel_rfl bodyJsLe73 : Nat.ble PRE_first_tail_x15_r0_body.s706.next PRE_first_tail_x15_r0_body.s714.next = true
kernel_rfl bodyJsList73 : (PRE_first_tail_x15_r0_body.gjh73 ++ PRE_first_tail_x15_r0_body.cl73).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s714.next) PRE_first_tail_x15_r0_body.s716) = true
theorem bodyJs73 : JsHeapAbove PRE_first_tail_x15_r0_body.s714.next PRE_first_tail_x15_r0_body.s716 :=
  JsHeapAbove.glueSite bodyJs72 (Nat.le_of_ble_eq_true bodyJsLe73) PRE_first_tail_x15_r0_body.gjk73 PRE_first_tail_x15_r0_body.gjbd73 PRE_first_tail_x15_r0_body.cheap73 PRE_first_tail_x15_r0_body.zclbd73 bodyJsList73

end Host.Ts.Sim.Compose.VWFirst.VW15
