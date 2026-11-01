import host.sim.compose.a4b.vw15.VWBodyJ82
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl83 : Conv.NClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s804.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl83 (PRE_first_tail_x15_r0_body.cncl82 bodyNcl82)

theorem bodyClean83 : Conv.JClean (⟨19833, 16918, 2739877, 3601⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s804 :=
  PRE_first_tail_x15_r0_body.gjcl83 (PRE_first_tail_x15_r0_body.cjcl82 bodyClean82)

kernel_rfl bodyJsLe83 : Nat.ble PRE_first_tail_x15_r0_body.s800.next PRE_first_tail_x15_r0_body.s804.next = true
kernel_rfl bodyJsList83 : (PRE_first_tail_x15_r0_body.gjh83 ++ PRE_first_tail_x15_r0_body.cl83).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s804.next) PRE_first_tail_x15_r0_body.s806) = true
theorem bodyJs83 : JsHeapAbove PRE_first_tail_x15_r0_body.s804.next PRE_first_tail_x15_r0_body.s806 :=
  JsHeapAbove.glueSite bodyJs82 (Nat.le_of_ble_eq_true bodyJsLe83) PRE_first_tail_x15_r0_body.gjk83 PRE_first_tail_x15_r0_body.gjbd83 PRE_first_tail_x15_r0_body.cheap83 PRE_first_tail_x15_r0_body.zclbd83 bodyJsList83

end Host.Ts.Sim.Compose.VWFirst.VW15
