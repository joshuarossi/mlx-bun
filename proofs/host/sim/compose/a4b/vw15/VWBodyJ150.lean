import host.sim.compose.a4b.vw15.VWBodyJ149
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl150 : Conv.NClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1454.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl150 (PRE_first_tail_x15_r0_body.cncl149 bodyNcl149)

theorem bodyClean150 : Conv.JClean (⟨21162, 18248, 2792979, 6497⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1454 :=
  PRE_first_tail_x15_r0_body.gjcl150 (PRE_first_tail_x15_r0_body.cjcl149 bodyClean149)

kernel_rfl bodyJsLe150 : Nat.ble PRE_first_tail_x15_r0_body.s1437.next PRE_first_tail_x15_r0_body.s1454.next = true
kernel_rfl bodyJsList150 : (PRE_first_tail_x15_r0_body.gjh150 ++ PRE_first_tail_x15_r0_body.cl150).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1454.next) PRE_first_tail_x15_r0_body.s1456) = true
theorem bodyJs150 : JsHeapAbove PRE_first_tail_x15_r0_body.s1454.next PRE_first_tail_x15_r0_body.s1456 :=
  JsHeapAbove.glueSite bodyJs149 (Nat.le_of_ble_eq_true bodyJsLe150) PRE_first_tail_x15_r0_body.gjk150 PRE_first_tail_x15_r0_body.gjbd150 PRE_first_tail_x15_r0_body.cheap150 PRE_first_tail_x15_r0_body.zclbd150 bodyJsList150

end Host.Ts.Sim.Compose.VWFirst.VW15
