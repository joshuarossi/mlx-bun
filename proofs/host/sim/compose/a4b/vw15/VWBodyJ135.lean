import host.sim.compose.a4b.vw15.VWBodyJ134
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl135 : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl135 (PRE_first_tail_x15_r0_body.cncl134 bodyNcl134)

theorem bodyClean135 : Conv.JClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1310 :=
  PRE_first_tail_x15_r0_body.gjcl135 (PRE_first_tail_x15_r0_body.cjcl134 bodyClean134)

kernel_rfl bodyJsLe135 : Nat.ble PRE_first_tail_x15_r0_body.s1293.next PRE_first_tail_x15_r0_body.s1310.next = true
kernel_rfl bodyJsList135 : (PRE_first_tail_x15_r0_body.gjh135 ++ PRE_first_tail_x15_r0_body.cl135).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1310.next) PRE_first_tail_x15_r0_body.s1312) = true
theorem bodyJs135 : JsHeapAbove PRE_first_tail_x15_r0_body.s1310.next PRE_first_tail_x15_r0_body.s1312 :=
  JsHeapAbove.glueSite bodyJs134 (Nat.le_of_ble_eq_true bodyJsLe135) PRE_first_tail_x15_r0_body.gjk135 PRE_first_tail_x15_r0_body.gjbd135 PRE_first_tail_x15_r0_body.cheap135 PRE_first_tail_x15_r0_body.zclbd135 bodyJsList135

end Host.Ts.Sim.Compose.VWFirst.VW15
