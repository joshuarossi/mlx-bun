import host.sim.compose.a4b.vw15.VWBodyJ58
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl59 : Conv.NClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl59 (PRE_first_tail_x15_r0_body.cncl58 bodyNcl58)

theorem bodyClean59 : Conv.JClean (⟨19361, 16444, 2721053, 2575⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s574 :=
  PRE_first_tail_x15_r0_body.gjcl59 (PRE_first_tail_x15_r0_body.cjcl58 bodyClean58)

kernel_rfl bodyJsLe59 : Nat.ble PRE_first_tail_x15_r0_body.s570.next PRE_first_tail_x15_r0_body.s574.next = true
kernel_rfl bodyJsList59 : (PRE_first_tail_x15_r0_body.gjh59 ++ PRE_first_tail_x15_r0_body.cl59).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s574.next) PRE_first_tail_x15_r0_body.s576) = true
theorem bodyJs59 : JsHeapAbove PRE_first_tail_x15_r0_body.s574.next PRE_first_tail_x15_r0_body.s576 :=
  JsHeapAbove.glueSite bodyJs58 (Nat.le_of_ble_eq_true bodyJsLe59) PRE_first_tail_x15_r0_body.gjk59 PRE_first_tail_x15_r0_body.gjbd59 PRE_first_tail_x15_r0_body.cheap59 PRE_first_tail_x15_r0_body.zclbd59 bodyJsList59

end Host.Ts.Sim.Compose.VWFirst.VW15
