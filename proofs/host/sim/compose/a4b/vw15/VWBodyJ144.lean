import host.sim.compose.a4b.vw15.VWBodyJ143
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl144 : Conv.NClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl144 (PRE_first_tail_x15_r0_body.cncl143 bodyNcl143)

theorem bodyClean144 : Conv.JClean (⟨21048, 18122, 2788459, 6239⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1396 :=
  PRE_first_tail_x15_r0_body.gjcl144 (PRE_first_tail_x15_r0_body.cjcl143 bodyClean143)

kernel_rfl bodyJsLe144 : Nat.ble PRE_first_tail_x15_r0_body.s1379.next PRE_first_tail_x15_r0_body.s1396.next = true
kernel_rfl bodyJsList144 : (PRE_first_tail_x15_r0_body.gjh144 ++ PRE_first_tail_x15_r0_body.cl144).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1396.next) PRE_first_tail_x15_r0_body.s1398) = true
theorem bodyJs144 : JsHeapAbove PRE_first_tail_x15_r0_body.s1396.next PRE_first_tail_x15_r0_body.s1398 :=
  JsHeapAbove.glueSite bodyJs143 (Nat.le_of_ble_eq_true bodyJsLe144) PRE_first_tail_x15_r0_body.gjk144 PRE_first_tail_x15_r0_body.gjbd144 PRE_first_tail_x15_r0_body.cheap144 PRE_first_tail_x15_r0_body.zclbd144 bodyJsList144

end Host.Ts.Sim.Compose.VWFirst.VW15
