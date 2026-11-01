import host.sim.compose.a4b.vw15.VWBodyJ19
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl20 : Conv.NClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl20 (PRE_first_tail_x15_r0_body.cncl19 bodyNcl19)

theorem bodyClean20 : Conv.JClean (⟨18589, 15685, 2690171, 910⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s201 :=
  PRE_first_tail_x15_r0_body.gjcl20 (PRE_first_tail_x15_r0_body.cjcl19 bodyClean19)

kernel_rfl bodyJsLe20 : Nat.ble PRE_first_tail_x15_r0_body.s197.next PRE_first_tail_x15_r0_body.s201.next = true
kernel_rfl bodyJsList20 : (PRE_first_tail_x15_r0_body.gjh20 ++ PRE_first_tail_x15_r0_body.cl20).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s201.next) PRE_first_tail_x15_r0_body.s203) = true
theorem bodyJs20 : JsHeapAbove PRE_first_tail_x15_r0_body.s201.next PRE_first_tail_x15_r0_body.s203 :=
  JsHeapAbove.glueSite bodyJs19 (Nat.le_of_ble_eq_true bodyJsLe20) PRE_first_tail_x15_r0_body.gjk20 PRE_first_tail_x15_r0_body.gjbd20 PRE_first_tail_x15_r0_body.cheap20 PRE_first_tail_x15_r0_body.zclbd20 bodyJsList20

end Host.Ts.Sim.Compose.VWFirst.VW15
