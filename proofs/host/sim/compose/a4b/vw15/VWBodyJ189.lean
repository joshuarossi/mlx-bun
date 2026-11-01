import host.sim.compose.a4b.vw15.VWBodyJ188
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl189 : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl189 (PRE_first_tail_x15_r0_body.cncl188 bodyNcl188)

theorem bodyClean189 : Conv.JClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1827 :=
  PRE_first_tail_x15_r0_body.gjcl189 (PRE_first_tail_x15_r0_body.cjcl188 bodyClean188)

kernel_rfl bodyJsLe189 : Nat.ble PRE_first_tail_x15_r0_body.s1811.next PRE_first_tail_x15_r0_body.s1827.next = true
kernel_rfl bodyJsList189 : (PRE_first_tail_x15_r0_body.gjh189 ++ PRE_first_tail_x15_r0_body.cl189).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1827.next) PRE_first_tail_x15_r0_body.s1829) = true
theorem bodyJs189 : JsHeapAbove PRE_first_tail_x15_r0_body.s1827.next PRE_first_tail_x15_r0_body.s1829 :=
  JsHeapAbove.glueSite bodyJs188 (Nat.le_of_ble_eq_true bodyJsLe189) PRE_first_tail_x15_r0_body.gjk189 PRE_first_tail_x15_r0_body.gjbd189 PRE_first_tail_x15_r0_body.cheap189 PRE_first_tail_x15_r0_body.zclbd189 bodyJsList189

end Host.Ts.Sim.Compose.VWFirst.VW15
