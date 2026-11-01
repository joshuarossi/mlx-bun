import host.sim.compose.a4b.vw15.VWBodyJ113
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl114 : Conv.NClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1109.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl114 (PRE_first_tail_x15_r0_body.cncl113 bodyNcl113)

theorem bodyClean114 : Conv.JClean (⟨20454, 17537, 2764723, 4958⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1109 :=
  PRE_first_tail_x15_r0_body.gjcl114 (PRE_first_tail_x15_r0_body.cjcl113 bodyClean113)

kernel_rfl bodyJsLe114 : Nat.ble PRE_first_tail_x15_r0_body.s1092.next PRE_first_tail_x15_r0_body.s1109.next = true
kernel_rfl bodyJsList114 : (PRE_first_tail_x15_r0_body.gjh114 ++ PRE_first_tail_x15_r0_body.cl114).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1109.next) PRE_first_tail_x15_r0_body.s1111) = true
theorem bodyJs114 : JsHeapAbove PRE_first_tail_x15_r0_body.s1109.next PRE_first_tail_x15_r0_body.s1111 :=
  JsHeapAbove.glueSite bodyJs113 (Nat.le_of_ble_eq_true bodyJsLe114) PRE_first_tail_x15_r0_body.gjk114 PRE_first_tail_x15_r0_body.gjbd114 PRE_first_tail_x15_r0_body.cheap114 PRE_first_tail_x15_r0_body.zclbd114 bodyJsList114

end Host.Ts.Sim.Compose.VWFirst.VW15
