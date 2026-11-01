import host.sim.compose.a4b.vw15.VWBodyJ86
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl87 : Conv.NClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl87 (PRE_first_tail_x15_r0_body.cncl86 bodyNcl86)

theorem bodyClean87 : Conv.JClean (⟨19925, 17000, 2743627, 3803⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s850 :=
  PRE_first_tail_x15_r0_body.gjcl87 (PRE_first_tail_x15_r0_body.cjcl86 bodyClean86)

kernel_rfl bodyJsLe87 : Nat.ble PRE_first_tail_x15_r0_body.s833.next PRE_first_tail_x15_r0_body.s850.next = true
kernel_rfl bodyJsList87 : (PRE_first_tail_x15_r0_body.gjh87 ++ PRE_first_tail_x15_r0_body.cl87).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s850.next) PRE_first_tail_x15_r0_body.s852) = true
theorem bodyJs87 : JsHeapAbove PRE_first_tail_x15_r0_body.s850.next PRE_first_tail_x15_r0_body.s852 :=
  JsHeapAbove.glueSite bodyJs86 (Nat.le_of_ble_eq_true bodyJsLe87) PRE_first_tail_x15_r0_body.gjk87 PRE_first_tail_x15_r0_body.gjbd87 PRE_first_tail_x15_r0_body.cheap87 PRE_first_tail_x15_r0_body.zclbd87 bodyJsList87

end Host.Ts.Sim.Compose.VWFirst.VW15
