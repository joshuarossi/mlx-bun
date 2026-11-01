import host.sim.compose.a4b.vw15.VWBodyJ129
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl130 : Conv.NClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl130 (PRE_first_tail_x15_r0_body.cncl129 bodyNcl129)

theorem bodyClean130 : Conv.JClean (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1260 :=
  PRE_first_tail_x15_r0_body.gjcl130 (PRE_first_tail_x15_r0_body.cjcl129 bodyClean129)

kernel_rfl bodyJsLe130 : Nat.ble PRE_first_tail_x15_r0_body.s1252.next PRE_first_tail_x15_r0_body.s1260.next = true
kernel_rfl bodyJsList130 : (PRE_first_tail_x15_r0_body.gjh130 ++ PRE_first_tail_x15_r0_body.cl130).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1260.next) PRE_first_tail_x15_r0_body.s1262) = true
theorem bodyJs130 : JsHeapAbove PRE_first_tail_x15_r0_body.s1260.next PRE_first_tail_x15_r0_body.s1262 :=
  JsHeapAbove.glueSite bodyJs129 (Nat.le_of_ble_eq_true bodyJsLe130) PRE_first_tail_x15_r0_body.gjk130 PRE_first_tail_x15_r0_body.gjbd130 PRE_first_tail_x15_r0_body.cheap130 PRE_first_tail_x15_r0_body.zclbd130 bodyJsList130

end Host.Ts.Sim.Compose.VWFirst.VW15
