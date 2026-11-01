import host.sim.compose.a4b.vw15.VWBodyJ40
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl41 : Conv.NClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl41 (PRE_first_tail_x15_r0_body.cncl40 bodyNcl40)

theorem bodyClean41 : Conv.JClean (⟨19004, 16096, 2706743, 1807⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s402 :=
  PRE_first_tail_x15_r0_body.gjcl41 (PRE_first_tail_x15_r0_body.cjcl40 bodyClean40)

kernel_rfl bodyJsLe41 : Nat.ble PRE_first_tail_x15_r0_body.s398.next PRE_first_tail_x15_r0_body.s402.next = true
kernel_rfl bodyJsList41 : (PRE_first_tail_x15_r0_body.gjh41 ++ PRE_first_tail_x15_r0_body.cl41).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s402.next) PRE_first_tail_x15_r0_body.s404) = true
theorem bodyJs41 : JsHeapAbove PRE_first_tail_x15_r0_body.s402.next PRE_first_tail_x15_r0_body.s404 :=
  JsHeapAbove.glueSite bodyJs40 (Nat.le_of_ble_eq_true bodyJsLe41) PRE_first_tail_x15_r0_body.gjk41 PRE_first_tail_x15_r0_body.gjbd41 PRE_first_tail_x15_r0_body.cheap41 PRE_first_tail_x15_r0_body.zclbd41 bodyJsList41

end Host.Ts.Sim.Compose.VWFirst.VW15
