import host.sim.compose.a4b.vw15.VWBodyJ74
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl75 : Conv.NClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl75 (PRE_first_tail_x15_r0_body.cncl74 bodyNcl74)

theorem bodyClean75 : Conv.JClean (⟨19689, 16763, 2734215, 3290⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s735 :=
  PRE_first_tail_x15_r0_body.gjcl75 (PRE_first_tail_x15_r0_body.cjcl74 bodyClean74)

kernel_rfl bodyJsLe75 : Nat.ble PRE_first_tail_x15_r0_body.s718.next PRE_first_tail_x15_r0_body.s735.next = true
kernel_rfl bodyJsList75 : (PRE_first_tail_x15_r0_body.gjh75 ++ PRE_first_tail_x15_r0_body.cl75).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s735.next) PRE_first_tail_x15_r0_body.s737) = true
theorem bodyJs75 : JsHeapAbove PRE_first_tail_x15_r0_body.s735.next PRE_first_tail_x15_r0_body.s737 :=
  JsHeapAbove.glueSite bodyJs74 (Nat.le_of_ble_eq_true bodyJsLe75) PRE_first_tail_x15_r0_body.gjk75 PRE_first_tail_x15_r0_body.gjbd75 PRE_first_tail_x15_r0_body.cheap75 PRE_first_tail_x15_r0_body.zclbd75 bodyJsList75

end Host.Ts.Sim.Compose.VWFirst.VW15
