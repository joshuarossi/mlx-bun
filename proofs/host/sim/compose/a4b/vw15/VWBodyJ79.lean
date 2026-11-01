import host.sim.compose.a4b.vw15.VWBodyJ78
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl79 : Conv.NClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s772.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl79 (PRE_first_tail_x15_r0_body.cncl78 bodyNcl78)

theorem bodyClean79 : Conv.JClean (⟨19762, 16866, 2736967, 3458⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s772 :=
  PRE_first_tail_x15_r0_body.gjcl79 (PRE_first_tail_x15_r0_body.cjcl78 bodyClean78)

kernel_rfl bodyJsLe79 : Nat.ble PRE_first_tail_x15_r0_body.s764.next PRE_first_tail_x15_r0_body.s772.next = true
kernel_rfl bodyJsList79 : (PRE_first_tail_x15_r0_body.gjh79 ++ PRE_first_tail_x15_r0_body.cl79).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s772.next) PRE_first_tail_x15_r0_body.s774) = true
theorem bodyJs79 : JsHeapAbove PRE_first_tail_x15_r0_body.s772.next PRE_first_tail_x15_r0_body.s774 :=
  JsHeapAbove.glueSite bodyJs78 (Nat.le_of_ble_eq_true bodyJsLe79) PRE_first_tail_x15_r0_body.gjk79 PRE_first_tail_x15_r0_body.gjbd79 PRE_first_tail_x15_r0_body.cheap79 PRE_first_tail_x15_r0_body.zclbd79 bodyJsList79

end Host.Ts.Sim.Compose.VWFirst.VW15
