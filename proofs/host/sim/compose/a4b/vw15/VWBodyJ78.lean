import host.sim.compose.a4b.vw15.VWBodyJ77
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl78 : Conv.NClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s764.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl78 (PRE_first_tail_x15_r0_body.cncl77 bodyNcl77)

theorem bodyClean78 : Conv.JClean (⟨19746, 16826, 2736471, 3419⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s764 :=
  PRE_first_tail_x15_r0_body.gjcl78 (PRE_first_tail_x15_r0_body.cjcl77 bodyClean77)

kernel_rfl bodyJsLe78 : Nat.ble PRE_first_tail_x15_r0_body.s747.next PRE_first_tail_x15_r0_body.s764.next = true
kernel_rfl bodyJsList78 : (PRE_first_tail_x15_r0_body.gjh78 ++ PRE_first_tail_x15_r0_body.cl78).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s764.next) PRE_first_tail_x15_r0_body.s766) = true
theorem bodyJs78 : JsHeapAbove PRE_first_tail_x15_r0_body.s764.next PRE_first_tail_x15_r0_body.s766 :=
  JsHeapAbove.glueSite bodyJs77 (Nat.le_of_ble_eq_true bodyJsLe78) PRE_first_tail_x15_r0_body.gjk78 PRE_first_tail_x15_r0_body.gjbd78 PRE_first_tail_x15_r0_body.cheap78 PRE_first_tail_x15_r0_body.zclbd78 bodyJsList78

end Host.Ts.Sim.Compose.VWFirst.VW15
