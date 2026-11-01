import host.sim.compose.a4b.vw15.VWBodyJ61
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl62 : Conv.NClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s603.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl62 (PRE_first_tail_x15_r0_body.cncl61 bodyNcl61)

theorem bodyClean62 : Conv.JClean (⟨19419, 16507, 2723331, 2704⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s603 :=
  PRE_first_tail_x15_r0_body.gjcl62 (PRE_first_tail_x15_r0_body.cjcl61 bodyClean61)

kernel_rfl bodyJsLe62 : Nat.ble PRE_first_tail_x15_r0_body.s599.next PRE_first_tail_x15_r0_body.s603.next = true
kernel_rfl bodyJsList62 : (PRE_first_tail_x15_r0_body.gjh62 ++ PRE_first_tail_x15_r0_body.cl62).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s603.next) PRE_first_tail_x15_r0_body.s605) = true
theorem bodyJs62 : JsHeapAbove PRE_first_tail_x15_r0_body.s603.next PRE_first_tail_x15_r0_body.s605 :=
  JsHeapAbove.glueSite bodyJs61 (Nat.le_of_ble_eq_true bodyJsLe62) PRE_first_tail_x15_r0_body.gjk62 PRE_first_tail_x15_r0_body.gjbd62 PRE_first_tail_x15_r0_body.cheap62 PRE_first_tail_x15_r0_body.zclbd62 bodyJsList62

end Host.Ts.Sim.Compose.VWFirst.VW15
