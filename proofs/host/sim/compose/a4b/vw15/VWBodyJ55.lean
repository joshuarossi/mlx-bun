import host.sim.compose.a4b.vw15.VWBodyJ54
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl55 : Conv.NClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s542.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl55 (PRE_first_tail_x15_r0_body.cncl54 bodyNcl54)

theorem bodyClean55 : Conv.JClean (⟨19290, 16392, 2718139, 2432⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s542 :=
  PRE_first_tail_x15_r0_body.gjcl55 (PRE_first_tail_x15_r0_body.cjcl54 bodyClean54)

kernel_rfl bodyJsLe55 : Nat.ble PRE_first_tail_x15_r0_body.s534.next PRE_first_tail_x15_r0_body.s542.next = true
kernel_rfl bodyJsList55 : (PRE_first_tail_x15_r0_body.gjh55 ++ PRE_first_tail_x15_r0_body.cl55).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s542.next) PRE_first_tail_x15_r0_body.s544) = true
theorem bodyJs55 : JsHeapAbove PRE_first_tail_x15_r0_body.s542.next PRE_first_tail_x15_r0_body.s544 :=
  JsHeapAbove.glueSite bodyJs54 (Nat.le_of_ble_eq_true bodyJsLe55) PRE_first_tail_x15_r0_body.gjk55 PRE_first_tail_x15_r0_body.gjbd55 PRE_first_tail_x15_r0_body.cheap55 PRE_first_tail_x15_r0_body.zclbd55 bodyJsList55

end Host.Ts.Sim.Compose.VWFirst.VW15
