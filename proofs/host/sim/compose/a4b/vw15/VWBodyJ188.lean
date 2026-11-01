import host.sim.compose.a4b.vw15.VWBodyJ187
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl188 : Conv.NClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1811.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl188 (PRE_first_tail_x15_r0_body.cncl187 bodyNcl187)

theorem bodyClean188 : Conv.JClean (⟨21893, 19003, 2822031, 8092⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1811 :=
  PRE_first_tail_x15_r0_body.gjcl188 (PRE_first_tail_x15_r0_body.cjcl187 bodyClean187)

kernel_rfl bodyJsLe188 : Nat.ble PRE_first_tail_x15_r0_body.s1807.next PRE_first_tail_x15_r0_body.s1811.next = true
kernel_rfl bodyJsList188 : (PRE_first_tail_x15_r0_body.gjh188 ++ PRE_first_tail_x15_r0_body.cl188).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1811.next) PRE_first_tail_x15_r0_body.s1813) = true
theorem bodyJs188 : JsHeapAbove PRE_first_tail_x15_r0_body.s1811.next PRE_first_tail_x15_r0_body.s1813 :=
  JsHeapAbove.glueSite bodyJs187 (Nat.le_of_ble_eq_true bodyJsLe188) PRE_first_tail_x15_r0_body.gjk188 PRE_first_tail_x15_r0_body.gjbd188 PRE_first_tail_x15_r0_body.cheap188 PRE_first_tail_x15_r0_body.zclbd188 bodyJsList188

end Host.Ts.Sim.Compose.VWFirst.VW15
