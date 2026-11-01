import host.sim.compose.a4b.vw15.VWBodyJ128
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl129 : Conv.NClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl129 (PRE_first_tail_x15_r0_body.cncl128 bodyNcl128)

theorem bodyClean129 : Conv.JClean (⟨20753, 17846, 2776656, 5604⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1252 :=
  PRE_first_tail_x15_r0_body.gjcl129 (PRE_first_tail_x15_r0_body.cjcl128 bodyClean128)

kernel_rfl bodyJsLe129 : Nat.ble PRE_first_tail_x15_r0_body.s1236.next PRE_first_tail_x15_r0_body.s1252.next = true
kernel_rfl bodyJsList129 : (PRE_first_tail_x15_r0_body.gjh129 ++ PRE_first_tail_x15_r0_body.cl129).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1252.next) PRE_first_tail_x15_r0_body.s1254) = true
theorem bodyJs129 : JsHeapAbove PRE_first_tail_x15_r0_body.s1252.next PRE_first_tail_x15_r0_body.s1254 :=
  JsHeapAbove.glueSite bodyJs128 (Nat.le_of_ble_eq_true bodyJsLe129) PRE_first_tail_x15_r0_body.gjk129 PRE_first_tail_x15_r0_body.gjbd129 PRE_first_tail_x15_r0_body.cheap129 PRE_first_tail_x15_r0_body.zclbd129 bodyJsList129

end Host.Ts.Sim.Compose.VWFirst.VW15
