import host.sim.compose.a4b.vw15.VWBodyJ171
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl172 : Conv.NClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1663.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl172 (PRE_first_tail_x15_r0_body.cncl171 bodyNcl171)

theorem bodyClean172 : Conv.JClean (⟨21593, 18699, 2810055, 7433⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1663 :=
  PRE_first_tail_x15_r0_body.gjcl172 (PRE_first_tail_x15_r0_body.cjcl171 bodyClean171)

kernel_rfl bodyJsLe172 : Nat.ble PRE_first_tail_x15_r0_body.s1655.next PRE_first_tail_x15_r0_body.s1663.next = true
kernel_rfl bodyJsList172 : (PRE_first_tail_x15_r0_body.gjh172 ++ PRE_first_tail_x15_r0_body.cl172).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1663.next) PRE_first_tail_x15_r0_body.s1665) = true
theorem bodyJs172 : JsHeapAbove PRE_first_tail_x15_r0_body.s1663.next PRE_first_tail_x15_r0_body.s1665 :=
  JsHeapAbove.glueSite bodyJs171 (Nat.le_of_ble_eq_true bodyJsLe172) PRE_first_tail_x15_r0_body.gjk172 PRE_first_tail_x15_r0_body.gjbd172 PRE_first_tail_x15_r0_body.cheap172 PRE_first_tail_x15_r0_body.zclbd172 bodyJsList172

end Host.Ts.Sim.Compose.VWFirst.VW15
