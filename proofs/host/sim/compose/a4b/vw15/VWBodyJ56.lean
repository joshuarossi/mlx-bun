import host.sim.compose.a4b.vw15.VWBodyJ55
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl56 : Conv.NClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s546.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl56 (PRE_first_tail_x15_r0_body.cncl55 bodyNcl55)

theorem bodyClean56 : Conv.JClean (⟨19297, 16396, 2718427, 2449⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s546 :=
  PRE_first_tail_x15_r0_body.gjcl56 (PRE_first_tail_x15_r0_body.cjcl55 bodyClean55)

kernel_rfl bodyJsLe56 : Nat.ble PRE_first_tail_x15_r0_body.s542.next PRE_first_tail_x15_r0_body.s546.next = true
kernel_rfl bodyJsList56 : (PRE_first_tail_x15_r0_body.gjh56 ++ PRE_first_tail_x15_r0_body.cl56).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s546.next) PRE_first_tail_x15_r0_body.s548) = true
theorem bodyJs56 : JsHeapAbove PRE_first_tail_x15_r0_body.s546.next PRE_first_tail_x15_r0_body.s548 :=
  JsHeapAbove.glueSite bodyJs55 (Nat.le_of_ble_eq_true bodyJsLe56) PRE_first_tail_x15_r0_body.gjk56 PRE_first_tail_x15_r0_body.gjbd56 PRE_first_tail_x15_r0_body.cheap56 PRE_first_tail_x15_r0_body.zclbd56 bodyJsList56

end Host.Ts.Sim.Compose.VWFirst.VW15
