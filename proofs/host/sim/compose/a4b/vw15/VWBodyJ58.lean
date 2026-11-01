import host.sim.compose.a4b.vw15.VWBodyJ57
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl58 : Conv.NClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s570.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl58 (PRE_first_tail_x15_r0_body.cncl57 bodyNcl57)

theorem bodyClean58 : Conv.JClean (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s570 :=
  PRE_first_tail_x15_r0_body.gjcl58 (PRE_first_tail_x15_r0_body.cjcl57 bodyClean57)

kernel_rfl bodyJsLe58 : Nat.ble PRE_first_tail_x15_r0_body.s562.next PRE_first_tail_x15_r0_body.s570.next = true
kernel_rfl bodyJsList58 : (PRE_first_tail_x15_r0_body.gjh58 ++ PRE_first_tail_x15_r0_body.cl58).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s570.next) PRE_first_tail_x15_r0_body.s572) = true
theorem bodyJs58 : JsHeapAbove PRE_first_tail_x15_r0_body.s570.next PRE_first_tail_x15_r0_body.s572 :=
  JsHeapAbove.glueSite bodyJs57 (Nat.le_of_ble_eq_true bodyJsLe58) PRE_first_tail_x15_r0_body.gjk58 PRE_first_tail_x15_r0_body.gjbd58 PRE_first_tail_x15_r0_body.cheap58 PRE_first_tail_x15_r0_body.zclbd58 bodyJsList58

end Host.Ts.Sim.Compose.VWFirst.VW15
