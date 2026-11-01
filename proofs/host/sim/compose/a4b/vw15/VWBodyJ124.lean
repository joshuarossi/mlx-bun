import host.sim.compose.a4b.vw15.VWBodyJ123
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl124 : Conv.NClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1203.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl124 (PRE_first_tail_x15_r0_body.cncl123 bodyNcl123)

theorem bodyClean124 : Conv.JClean (⟨20649, 17751, 2772375, 5381⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1203 :=
  PRE_first_tail_x15_r0_body.gjcl124 (PRE_first_tail_x15_r0_body.cjcl123 bodyClean123)

kernel_rfl bodyJsLe124 : Nat.ble PRE_first_tail_x15_r0_body.s1195.next PRE_first_tail_x15_r0_body.s1203.next = true
kernel_rfl bodyJsList124 : (PRE_first_tail_x15_r0_body.gjh124 ++ PRE_first_tail_x15_r0_body.cl124).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1203.next) PRE_first_tail_x15_r0_body.s1205) = true
theorem bodyJs124 : JsHeapAbove PRE_first_tail_x15_r0_body.s1203.next PRE_first_tail_x15_r0_body.s1205 :=
  JsHeapAbove.glueSite bodyJs123 (Nat.le_of_ble_eq_true bodyJsLe124) PRE_first_tail_x15_r0_body.gjk124 PRE_first_tail_x15_r0_body.gjbd124 PRE_first_tail_x15_r0_body.cheap124 PRE_first_tail_x15_r0_body.zclbd124 bodyJsList124

end Host.Ts.Sim.Compose.VWFirst.VW15
