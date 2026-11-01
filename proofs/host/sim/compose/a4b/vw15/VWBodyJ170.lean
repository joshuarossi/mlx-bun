import host.sim.compose.a4b.vw15.VWBodyJ169
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl170 : Conv.NClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1638.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl170 (PRE_first_tail_x15_r0_body.cncl169 bodyNcl169)

theorem bodyClean170 : Conv.JClean (⟨21543, 18640, 2808083, 7321⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1638 :=
  PRE_first_tail_x15_r0_body.gjcl170 (PRE_first_tail_x15_r0_body.cjcl169 bodyClean169)

kernel_rfl bodyJsLe170 : Nat.ble PRE_first_tail_x15_r0_body.s1634.next PRE_first_tail_x15_r0_body.s1638.next = true
kernel_rfl bodyJsList170 : (PRE_first_tail_x15_r0_body.gjh170 ++ PRE_first_tail_x15_r0_body.cl170).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1638.next) PRE_first_tail_x15_r0_body.s1640) = true
theorem bodyJs170 : JsHeapAbove PRE_first_tail_x15_r0_body.s1638.next PRE_first_tail_x15_r0_body.s1640 :=
  JsHeapAbove.glueSite bodyJs169 (Nat.le_of_ble_eq_true bodyJsLe170) PRE_first_tail_x15_r0_body.gjk170 PRE_first_tail_x15_r0_body.gjbd170 PRE_first_tail_x15_r0_body.cheap170 PRE_first_tail_x15_r0_body.zclbd170 bodyJsList170

end Host.Ts.Sim.Compose.VWFirst.VW15
