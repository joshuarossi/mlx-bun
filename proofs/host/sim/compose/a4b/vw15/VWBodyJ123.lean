import host.sim.compose.a4b.vw15.VWBodyJ122
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl123 : Conv.NClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1195.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl123 (PRE_first_tail_x15_r0_body.cncl122 bodyNcl122)

theorem bodyClean123 : Conv.JClean (⟨20633, 17711, 2771879, 5342⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1195 :=
  PRE_first_tail_x15_r0_body.gjcl123 (PRE_first_tail_x15_r0_body.cjcl122 bodyClean122)

kernel_rfl bodyJsLe123 : Nat.ble PRE_first_tail_x15_r0_body.s1178.next PRE_first_tail_x15_r0_body.s1195.next = true
kernel_rfl bodyJsList123 : (PRE_first_tail_x15_r0_body.gjh123 ++ PRE_first_tail_x15_r0_body.cl123).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1195.next) PRE_first_tail_x15_r0_body.s1197) = true
theorem bodyJs123 : JsHeapAbove PRE_first_tail_x15_r0_body.s1195.next PRE_first_tail_x15_r0_body.s1197 :=
  JsHeapAbove.glueSite bodyJs122 (Nat.le_of_ble_eq_true bodyJsLe123) PRE_first_tail_x15_r0_body.gjk123 PRE_first_tail_x15_r0_body.gjbd123 PRE_first_tail_x15_r0_body.cheap123 PRE_first_tail_x15_r0_body.zclbd123 bodyJsList123

end Host.Ts.Sim.Compose.VWFirst.VW15
