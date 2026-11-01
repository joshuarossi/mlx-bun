import host.sim.compose.a4b.vw15.VWBodyJ66
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl67 : Conv.NClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl67 (PRE_first_tail_x15_r0_body.cncl66 bodyNcl66)

theorem bodyClean67 : Conv.JClean (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s657 :=
  PRE_first_tail_x15_r0_body.gjcl67 (PRE_first_tail_x15_r0_body.cjcl66 bodyClean66)

kernel_rfl bodyJsLe67 : Nat.ble PRE_first_tail_x15_r0_body.s649.next PRE_first_tail_x15_r0_body.s657.next = true
kernel_rfl bodyJsList67 : (PRE_first_tail_x15_r0_body.gjh67 ++ PRE_first_tail_x15_r0_body.cl67).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s657.next) PRE_first_tail_x15_r0_body.s659) = true
theorem bodyJs67 : JsHeapAbove PRE_first_tail_x15_r0_body.s657.next PRE_first_tail_x15_r0_body.s659 :=
  JsHeapAbove.glueSite bodyJs66 (Nat.le_of_ble_eq_true bodyJsLe67) PRE_first_tail_x15_r0_body.gjk67 PRE_first_tail_x15_r0_body.gjbd67 PRE_first_tail_x15_r0_body.cheap67 PRE_first_tail_x15_r0_body.zclbd67 bodyJsList67

end Host.Ts.Sim.Compose.VWFirst.VW15
