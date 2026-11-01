import host.sim.compose.a4b.vw15.VWBodyJ107
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl108 : Conv.NClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl108 (PRE_first_tail_x15_r0_body.cncl107 bodyNcl107)

theorem bodyClean108 : Conv.JClean (⟨20340, 17411, 2760211, 4700⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1051 :=
  PRE_first_tail_x15_r0_body.gjcl108 (PRE_first_tail_x15_r0_body.cjcl107 bodyClean107)

kernel_rfl bodyJsLe108 : Nat.ble PRE_first_tail_x15_r0_body.s1034.next PRE_first_tail_x15_r0_body.s1051.next = true
kernel_rfl bodyJsList108 : (PRE_first_tail_x15_r0_body.gjh108 ++ PRE_first_tail_x15_r0_body.cl108).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1051.next) PRE_first_tail_x15_r0_body.s1053) = true
theorem bodyJs108 : JsHeapAbove PRE_first_tail_x15_r0_body.s1051.next PRE_first_tail_x15_r0_body.s1053 :=
  JsHeapAbove.glueSite bodyJs107 (Nat.le_of_ble_eq_true bodyJsLe108) PRE_first_tail_x15_r0_body.gjk108 PRE_first_tail_x15_r0_body.gjbd108 PRE_first_tail_x15_r0_body.cheap108 PRE_first_tail_x15_r0_body.zclbd108 bodyJsList108

end Host.Ts.Sim.Compose.VWFirst.VW15
