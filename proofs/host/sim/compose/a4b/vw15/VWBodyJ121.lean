import host.sim.compose.a4b.vw15.VWBodyJ120
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl121 : Conv.NClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1174.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl121 (PRE_first_tail_x15_r0_body.cncl120 bodyNcl120)

theorem bodyClean121 : Conv.JClean (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1174 :=
  PRE_first_tail_x15_r0_body.gjcl121 (PRE_first_tail_x15_r0_body.cjcl120 bodyClean120)

kernel_rfl bodyJsLe121 : Nat.ble PRE_first_tail_x15_r0_body.s1166.next PRE_first_tail_x15_r0_body.s1174.next = true
kernel_rfl bodyJsList121 : (PRE_first_tail_x15_r0_body.gjh121 ++ PRE_first_tail_x15_r0_body.cl121).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1174.next) PRE_first_tail_x15_r0_body.s1176) = true
theorem bodyJs121 : JsHeapAbove PRE_first_tail_x15_r0_body.s1174.next PRE_first_tail_x15_r0_body.s1176 :=
  JsHeapAbove.glueSite bodyJs120 (Nat.le_of_ble_eq_true bodyJsLe121) PRE_first_tail_x15_r0_body.gjk121 PRE_first_tail_x15_r0_body.gjbd121 PRE_first_tail_x15_r0_body.cheap121 PRE_first_tail_x15_r0_body.zclbd121 bodyJsList121

end Host.Ts.Sim.Compose.VWFirst.VW15
