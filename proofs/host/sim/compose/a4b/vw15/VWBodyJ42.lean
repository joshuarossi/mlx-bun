import host.sim.compose.a4b.vw15.VWBodyJ41
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl42 : Conv.NClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s419.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl42 (PRE_first_tail_x15_r0_body.cncl41 bodyNcl41)

theorem bodyClean42 : Conv.JClean (⟨19038, 16115, 2708219, 1880⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s419 :=
  PRE_first_tail_x15_r0_body.gjcl42 (PRE_first_tail_x15_r0_body.cjcl41 bodyClean41)

kernel_rfl bodyJsLe42 : Nat.ble PRE_first_tail_x15_r0_body.s402.next PRE_first_tail_x15_r0_body.s419.next = true
kernel_rfl bodyJsList42 : (PRE_first_tail_x15_r0_body.gjh42 ++ PRE_first_tail_x15_r0_body.cl42).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s419.next) PRE_first_tail_x15_r0_body.s421) = true
theorem bodyJs42 : JsHeapAbove PRE_first_tail_x15_r0_body.s419.next PRE_first_tail_x15_r0_body.s421 :=
  JsHeapAbove.glueSite bodyJs41 (Nat.le_of_ble_eq_true bodyJsLe42) PRE_first_tail_x15_r0_body.gjk42 PRE_first_tail_x15_r0_body.gjbd42 PRE_first_tail_x15_r0_body.cheap42 PRE_first_tail_x15_r0_body.zclbd42 bodyJsList42

end Host.Ts.Sim.Compose.VWFirst.VW15
