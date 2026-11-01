import host.sim.compose.a4b.vw15.VWBodyJ91
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl92 : Conv.NClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s891.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl92 (PRE_first_tail_x15_r0_body.cncl91 bodyNcl91)

theorem bodyClean92 : Conv.JClean (⟨20005, 17107, 2746671, 3988⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s891 :=
  PRE_first_tail_x15_r0_body.gjcl92 (PRE_first_tail_x15_r0_body.cjcl91 bodyClean91)

kernel_rfl bodyJsLe92 : Nat.ble PRE_first_tail_x15_r0_body.s887.next PRE_first_tail_x15_r0_body.s891.next = true
kernel_rfl bodyJsList92 : (PRE_first_tail_x15_r0_body.gjh92 ++ PRE_first_tail_x15_r0_body.cl92).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s891.next) PRE_first_tail_x15_r0_body.s893) = true
theorem bodyJs92 : JsHeapAbove PRE_first_tail_x15_r0_body.s891.next PRE_first_tail_x15_r0_body.s893 :=
  JsHeapAbove.glueSite bodyJs91 (Nat.le_of_ble_eq_true bodyJsLe92) PRE_first_tail_x15_r0_body.gjk92 PRE_first_tail_x15_r0_body.gjbd92 PRE_first_tail_x15_r0_body.cheap92 PRE_first_tail_x15_r0_body.zclbd92 bodyJsList92

end Host.Ts.Sim.Compose.VWFirst.VW15
