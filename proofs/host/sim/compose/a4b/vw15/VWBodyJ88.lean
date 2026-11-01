import host.sim.compose.a4b.vw15.VWBodyJ87
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl88 : Conv.NClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s858.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl88 (PRE_first_tail_x15_r0_body.cncl87 bodyNcl87)

theorem bodyClean88 : Conv.JClean (⟨19941, 17040, 2744123, 3842⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s858 :=
  PRE_first_tail_x15_r0_body.gjcl88 (PRE_first_tail_x15_r0_body.cjcl87 bodyClean87)

kernel_rfl bodyJsLe88 : Nat.ble PRE_first_tail_x15_r0_body.s850.next PRE_first_tail_x15_r0_body.s858.next = true
kernel_rfl bodyJsList88 : (PRE_first_tail_x15_r0_body.gjh88 ++ PRE_first_tail_x15_r0_body.cl88).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s858.next) PRE_first_tail_x15_r0_body.s860) = true
theorem bodyJs88 : JsHeapAbove PRE_first_tail_x15_r0_body.s858.next PRE_first_tail_x15_r0_body.s860 :=
  JsHeapAbove.glueSite bodyJs87 (Nat.le_of_ble_eq_true bodyJsLe88) PRE_first_tail_x15_r0_body.gjk88 PRE_first_tail_x15_r0_body.gjbd88 PRE_first_tail_x15_r0_body.cheap88 PRE_first_tail_x15_r0_body.zclbd88 bodyJsList88

end Host.Ts.Sim.Compose.VWFirst.VW15
