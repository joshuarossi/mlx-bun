import host.sim.compose.a4b.vw15.VWBodyJ67
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl68 : Conv.NClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s661.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl68 (PRE_first_tail_x15_r0_body.cncl67 bodyNcl67)

theorem bodyClean68 : Conv.JClean (⟨19533, 16633, 2727843, 2962⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s661 :=
  PRE_first_tail_x15_r0_body.gjcl68 (PRE_first_tail_x15_r0_body.cjcl67 bodyClean67)

kernel_rfl bodyJsLe68 : Nat.ble PRE_first_tail_x15_r0_body.s657.next PRE_first_tail_x15_r0_body.s661.next = true
kernel_rfl bodyJsList68 : (PRE_first_tail_x15_r0_body.gjh68 ++ PRE_first_tail_x15_r0_body.cl68).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s661.next) PRE_first_tail_x15_r0_body.s663) = true
theorem bodyJs68 : JsHeapAbove PRE_first_tail_x15_r0_body.s661.next PRE_first_tail_x15_r0_body.s663 :=
  JsHeapAbove.glueSite bodyJs67 (Nat.le_of_ble_eq_true bodyJsLe68) PRE_first_tail_x15_r0_body.gjk68 PRE_first_tail_x15_r0_body.gjbd68 PRE_first_tail_x15_r0_body.cheap68 PRE_first_tail_x15_r0_body.zclbd68 bodyJsList68

end Host.Ts.Sim.Compose.VWFirst.VW15
