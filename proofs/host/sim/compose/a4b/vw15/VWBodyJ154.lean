import host.sim.compose.a4b.vw15.VWBodyJ153
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl154 : Conv.NClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1490.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl154 (PRE_first_tail_x15_r0_body.cncl153 bodyNcl153)

theorem bodyClean154 : Conv.JClean (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1490 :=
  PRE_first_tail_x15_r0_body.gjcl154 (PRE_first_tail_x15_r0_body.cjcl153 bodyClean153)

kernel_rfl bodyJsLe154 : Nat.ble PRE_first_tail_x15_r0_body.s1482.next PRE_first_tail_x15_r0_body.s1490.next = true
kernel_rfl bodyJsList154 : (PRE_first_tail_x15_r0_body.gjh154 ++ PRE_first_tail_x15_r0_body.cl154).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1490.next) PRE_first_tail_x15_r0_body.s1492) = true
theorem bodyJs154 : JsHeapAbove PRE_first_tail_x15_r0_body.s1490.next PRE_first_tail_x15_r0_body.s1492 :=
  JsHeapAbove.glueSite bodyJs153 (Nat.le_of_ble_eq_true bodyJsLe154) PRE_first_tail_x15_r0_body.gjk154 PRE_first_tail_x15_r0_body.gjbd154 PRE_first_tail_x15_r0_body.cheap154 PRE_first_tail_x15_r0_body.zclbd154 bodyJsList154

end Host.Ts.Sim.Compose.VWFirst.VW15
