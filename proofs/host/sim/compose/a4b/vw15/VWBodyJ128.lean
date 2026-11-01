import host.sim.compose.a4b.vw15.VWBodyJ127
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl128 : Conv.NClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl128 (PRE_first_tail_x15_r0_body.cncl127 bodyNcl127)

theorem bodyClean128 : Conv.JClean (⟨20713, 17818, 2774919, 5527⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1236 :=
  PRE_first_tail_x15_r0_body.gjcl128 (PRE_first_tail_x15_r0_body.cjcl127 bodyClean127)

kernel_rfl bodyJsLe128 : Nat.ble PRE_first_tail_x15_r0_body.s1232.next PRE_first_tail_x15_r0_body.s1236.next = true
kernel_rfl bodyJsList128 : (PRE_first_tail_x15_r0_body.gjh128 ++ PRE_first_tail_x15_r0_body.cl128).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1236.next) PRE_first_tail_x15_r0_body.s1238) = true
theorem bodyJs128 : JsHeapAbove PRE_first_tail_x15_r0_body.s1236.next PRE_first_tail_x15_r0_body.s1238 :=
  JsHeapAbove.glueSite bodyJs127 (Nat.le_of_ble_eq_true bodyJsLe128) PRE_first_tail_x15_r0_body.gjk128 PRE_first_tail_x15_r0_body.gjbd128 PRE_first_tail_x15_r0_body.cheap128 PRE_first_tail_x15_r0_body.zclbd128 bodyJsList128

end Host.Ts.Sim.Compose.VWFirst.VW15
