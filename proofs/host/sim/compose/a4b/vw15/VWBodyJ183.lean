import host.sim.compose.a4b.vw15.VWBodyJ182
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl183 : Conv.NClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl183 (PRE_first_tail_x15_r0_body.cncl182 bodyNcl182)

theorem bodyClean183 : Conv.JClean (⟨21813, 18896, 2818987, 7907⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1770 :=
  PRE_first_tail_x15_r0_body.gjcl183 (PRE_first_tail_x15_r0_body.cjcl182 bodyClean182)

kernel_rfl bodyJsLe183 : Nat.ble PRE_first_tail_x15_r0_body.s1753.next PRE_first_tail_x15_r0_body.s1770.next = true
kernel_rfl bodyJsList183 : (PRE_first_tail_x15_r0_body.gjh183 ++ PRE_first_tail_x15_r0_body.cl183).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1770.next) PRE_first_tail_x15_r0_body.s1772) = true
theorem bodyJs183 : JsHeapAbove PRE_first_tail_x15_r0_body.s1770.next PRE_first_tail_x15_r0_body.s1772 :=
  JsHeapAbove.glueSite bodyJs182 (Nat.le_of_ble_eq_true bodyJsLe183) PRE_first_tail_x15_r0_body.gjk183 PRE_first_tail_x15_r0_body.gjbd183 PRE_first_tail_x15_r0_body.cheap183 PRE_first_tail_x15_r0_body.zclbd183 bodyJsList183

end Host.Ts.Sim.Compose.VWFirst.VW15
