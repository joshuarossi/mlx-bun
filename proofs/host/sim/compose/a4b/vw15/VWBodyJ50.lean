import host.sim.compose.a4b.vw15.VWBodyJ49
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl50 : Conv.NClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl50 (PRE_first_tail_x15_r0_body.cncl49 bodyNcl49)

theorem bodyClean50 : Conv.JClean (⟨19183, 16270, 2713907, 2191⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s488 :=
  PRE_first_tail_x15_r0_body.gjcl50 (PRE_first_tail_x15_r0_body.cjcl49 bodyClean49)

kernel_rfl bodyJsLe50 : Nat.ble PRE_first_tail_x15_r0_body.s484.next PRE_first_tail_x15_r0_body.s488.next = true
kernel_rfl bodyJsList50 : (PRE_first_tail_x15_r0_body.gjh50 ++ PRE_first_tail_x15_r0_body.cl50).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s488.next) PRE_first_tail_x15_r0_body.s490) = true
theorem bodyJs50 : JsHeapAbove PRE_first_tail_x15_r0_body.s488.next PRE_first_tail_x15_r0_body.s490 :=
  JsHeapAbove.glueSite bodyJs49 (Nat.le_of_ble_eq_true bodyJsLe50) PRE_first_tail_x15_r0_body.gjk50 PRE_first_tail_x15_r0_body.gjbd50 PRE_first_tail_x15_r0_body.cheap50 PRE_first_tail_x15_r0_body.zclbd50 bodyJsList50

end Host.Ts.Sim.Compose.VWFirst.VW15
