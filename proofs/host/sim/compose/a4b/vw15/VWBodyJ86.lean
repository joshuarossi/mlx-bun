import host.sim.compose.a4b.vw15.VWBodyJ85
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl86 : Conv.NClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s833.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl86 (PRE_first_tail_x15_r0_body.cncl85 bodyNcl85)

theorem bodyClean86 : Conv.JClean (⟨19891, 16981, 2742155, 3730⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s833 :=
  PRE_first_tail_x15_r0_body.gjcl86 (PRE_first_tail_x15_r0_body.cjcl85 bodyClean85)

kernel_rfl bodyJsLe86 : Nat.ble PRE_first_tail_x15_r0_body.s829.next PRE_first_tail_x15_r0_body.s833.next = true
kernel_rfl bodyJsList86 : (PRE_first_tail_x15_r0_body.gjh86 ++ PRE_first_tail_x15_r0_body.cl86).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s833.next) PRE_first_tail_x15_r0_body.s835) = true
theorem bodyJs86 : JsHeapAbove PRE_first_tail_x15_r0_body.s833.next PRE_first_tail_x15_r0_body.s835 :=
  JsHeapAbove.glueSite bodyJs85 (Nat.le_of_ble_eq_true bodyJsLe86) PRE_first_tail_x15_r0_body.gjk86 PRE_first_tail_x15_r0_body.gjbd86 PRE_first_tail_x15_r0_body.cheap86 PRE_first_tail_x15_r0_body.zclbd86 bodyJsList86

end Host.Ts.Sim.Compose.VWFirst.VW15
