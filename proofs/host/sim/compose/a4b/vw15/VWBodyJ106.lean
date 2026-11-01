import host.sim.compose.a4b.vw15.VWBodyJ105
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl106 : Conv.NClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl106 (PRE_first_tail_x15_r0_body.cncl105 bodyNcl105)

theorem bodyClean106 : Conv.JClean (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1030 :=
  PRE_first_tail_x15_r0_body.gjcl106 (PRE_first_tail_x15_r0_body.cjcl105 bodyClean105)

kernel_rfl bodyJsLe106 : Nat.ble PRE_first_tail_x15_r0_body.s1022.next PRE_first_tail_x15_r0_body.s1030.next = true
kernel_rfl bodyJsList106 : (PRE_first_tail_x15_r0_body.gjh106 ++ PRE_first_tail_x15_r0_body.cl106).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1030.next) PRE_first_tail_x15_r0_body.s1032) = true
theorem bodyJs106 : JsHeapAbove PRE_first_tail_x15_r0_body.s1030.next PRE_first_tail_x15_r0_body.s1032 :=
  JsHeapAbove.glueSite bodyJs105 (Nat.le_of_ble_eq_true bodyJsLe106) PRE_first_tail_x15_r0_body.gjk106 PRE_first_tail_x15_r0_body.gjbd106 PRE_first_tail_x15_r0_body.cheap106 PRE_first_tail_x15_r0_body.zclbd106 bodyJsList106

end Host.Ts.Sim.Compose.VWFirst.VW15
