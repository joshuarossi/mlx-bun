import host.sim.compose.a4b.vw15.VWBodyJ160
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl161 : Conv.NClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1552.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl161 (PRE_first_tail_x15_r0_body.cncl160 bodyNcl160)

theorem bodyClean161 : Conv.JClean (⟨21364, 18466, 2800919, 6937⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1552 :=
  PRE_first_tail_x15_r0_body.gjcl161 (PRE_first_tail_x15_r0_body.cjcl160 bodyClean160)

kernel_rfl bodyJsLe161 : Nat.ble PRE_first_tail_x15_r0_body.s1548.next PRE_first_tail_x15_r0_body.s1552.next = true
kernel_rfl bodyJsList161 : (PRE_first_tail_x15_r0_body.gjh161 ++ PRE_first_tail_x15_r0_body.cl161).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1552.next) PRE_first_tail_x15_r0_body.s1554) = true
theorem bodyJs161 : JsHeapAbove PRE_first_tail_x15_r0_body.s1552.next PRE_first_tail_x15_r0_body.s1554 :=
  JsHeapAbove.glueSite bodyJs160 (Nat.le_of_ble_eq_true bodyJsLe161) PRE_first_tail_x15_r0_body.gjk161 PRE_first_tail_x15_r0_body.gjbd161 PRE_first_tail_x15_r0_body.cheap161 PRE_first_tail_x15_r0_body.zclbd161 bodyJsList161

end Host.Ts.Sim.Compose.VWFirst.VW15
