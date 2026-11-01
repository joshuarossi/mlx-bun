import host.sim.compose.a4b.vw15.VWBodyJ10
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl11 : Conv.NClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl11 (PRE_first_tail_x15_r0_body.cncl10 bodyNcl10)

theorem bodyClean11 : Conv.JClean (⟨18417, 15496, 2683381, 523⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s114 :=
  PRE_first_tail_x15_r0_body.gjcl11 (PRE_first_tail_x15_r0_body.cjcl10 bodyClean10)

kernel_rfl bodyJsLe11 : Nat.ble PRE_first_tail_x15_r0_body.s110.next PRE_first_tail_x15_r0_body.s114.next = true
kernel_rfl bodyJsList11 : (PRE_first_tail_x15_r0_body.gjh11 ++ PRE_first_tail_x15_r0_body.cl11).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s114.next) PRE_first_tail_x15_r0_body.s116) = true
theorem bodyJs11 : JsHeapAbove PRE_first_tail_x15_r0_body.s114.next PRE_first_tail_x15_r0_body.s116 :=
  JsHeapAbove.glueSite bodyJs10 (Nat.le_of_ble_eq_true bodyJsLe11) PRE_first_tail_x15_r0_body.gjk11 PRE_first_tail_x15_r0_body.gjbd11 PRE_first_tail_x15_r0_body.cheap11 PRE_first_tail_x15_r0_body.zclbd11 bodyJsList11

end Host.Ts.Sim.Compose.VWFirst.VW15
