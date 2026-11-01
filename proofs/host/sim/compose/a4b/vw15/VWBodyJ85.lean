import host.sim.compose.a4b.vw15.VWBodyJ84
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl85 : Conv.NClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl85 (PRE_first_tail_x15_r0_body.cncl84 bodyNcl84)

theorem bodyClean85 : Conv.JClean (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s829 :=
  PRE_first_tail_x15_r0_body.gjcl85 (PRE_first_tail_x15_r0_body.cjcl84 bodyClean84)

kernel_rfl bodyJsLe85 : Nat.ble PRE_first_tail_x15_r0_body.s821.next PRE_first_tail_x15_r0_body.s829.next = true
kernel_rfl bodyJsList85 : (PRE_first_tail_x15_r0_body.gjh85 ++ PRE_first_tail_x15_r0_body.cl85).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s829.next) PRE_first_tail_x15_r0_body.s831) = true
theorem bodyJs85 : JsHeapAbove PRE_first_tail_x15_r0_body.s829.next PRE_first_tail_x15_r0_body.s831 :=
  JsHeapAbove.glueSite bodyJs84 (Nat.le_of_ble_eq_true bodyJsLe85) PRE_first_tail_x15_r0_body.gjk85 PRE_first_tail_x15_r0_body.gjbd85 PRE_first_tail_x15_r0_body.cheap85 PRE_first_tail_x15_r0_body.zclbd85 bodyJsList85

end Host.Ts.Sim.Compose.VWFirst.VW15
