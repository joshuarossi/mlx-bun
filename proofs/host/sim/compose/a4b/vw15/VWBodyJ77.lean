import host.sim.compose.a4b.vw15.VWBodyJ76
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl77 : Conv.NClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s747.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl77 (PRE_first_tail_x15_r0_body.cncl76 bodyNcl76)

theorem bodyClean77 : Conv.JClean (⟨19712, 16807, 2734999, 3346⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s747 :=
  PRE_first_tail_x15_r0_body.gjcl77 (PRE_first_tail_x15_r0_body.cjcl76 bodyClean76)

kernel_rfl bodyJsLe77 : Nat.ble PRE_first_tail_x15_r0_body.s743.next PRE_first_tail_x15_r0_body.s747.next = true
kernel_rfl bodyJsList77 : (PRE_first_tail_x15_r0_body.gjh77 ++ PRE_first_tail_x15_r0_body.cl77).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s747.next) PRE_first_tail_x15_r0_body.s749) = true
theorem bodyJs77 : JsHeapAbove PRE_first_tail_x15_r0_body.s747.next PRE_first_tail_x15_r0_body.s749 :=
  JsHeapAbove.glueSite bodyJs76 (Nat.le_of_ble_eq_true bodyJsLe77) PRE_first_tail_x15_r0_body.gjk77 PRE_first_tail_x15_r0_body.gjbd77 PRE_first_tail_x15_r0_body.cheap77 PRE_first_tail_x15_r0_body.zclbd77 bodyJsList77

end Host.Ts.Sim.Compose.VWFirst.VW15
