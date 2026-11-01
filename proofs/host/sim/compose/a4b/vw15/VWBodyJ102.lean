import host.sim.compose.a4b.vw15.VWBodyJ101
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl102 : Conv.NClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s994.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl102 (PRE_first_tail_x15_r0_body.cncl101 bodyNcl101)

theorem bodyClean102 : Conv.JClean (⟨20218, 17300, 2755311, 4445⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s994 :=
  PRE_first_tail_x15_r0_body.gjcl102 (PRE_first_tail_x15_r0_body.cjcl101 bodyClean101)

kernel_rfl bodyJsLe102 : Nat.ble PRE_first_tail_x15_r0_body.s977.next PRE_first_tail_x15_r0_body.s994.next = true
kernel_rfl bodyJsList102 : (PRE_first_tail_x15_r0_body.gjh102 ++ PRE_first_tail_x15_r0_body.cl102).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s994.next) PRE_first_tail_x15_r0_body.s996) = true
theorem bodyJs102 : JsHeapAbove PRE_first_tail_x15_r0_body.s994.next PRE_first_tail_x15_r0_body.s996 :=
  JsHeapAbove.glueSite bodyJs101 (Nat.le_of_ble_eq_true bodyJsLe102) PRE_first_tail_x15_r0_body.gjk102 PRE_first_tail_x15_r0_body.gjbd102 PRE_first_tail_x15_r0_body.cheap102 PRE_first_tail_x15_r0_body.zclbd102 bodyJsList102

end Host.Ts.Sim.Compose.VWFirst.VW15
