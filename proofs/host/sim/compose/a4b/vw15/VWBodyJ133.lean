import host.sim.compose.a4b.vw15.VWBodyJ132
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl133 : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl133 (PRE_first_tail_x15_r0_body.cncl132 bodyNcl132)

theorem bodyClean133 : Conv.JClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1289 :=
  PRE_first_tail_x15_r0_body.gjcl133 (PRE_first_tail_x15_r0_body.cjcl132 bodyClean132)

kernel_rfl bodyJsLe133 : Nat.ble PRE_first_tail_x15_r0_body.s1281.next PRE_first_tail_x15_r0_body.s1289.next = true
kernel_rfl bodyJsList133 : (PRE_first_tail_x15_r0_body.gjh133 ++ PRE_first_tail_x15_r0_body.cl133).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1289.next) PRE_first_tail_x15_r0_body.s1291) = true
theorem bodyJs133 : JsHeapAbove PRE_first_tail_x15_r0_body.s1289.next PRE_first_tail_x15_r0_body.s1291 :=
  JsHeapAbove.glueSite bodyJs132 (Nat.le_of_ble_eq_true bodyJsLe133) PRE_first_tail_x15_r0_body.gjk133 PRE_first_tail_x15_r0_body.gjbd133 PRE_first_tail_x15_r0_body.cheap133 PRE_first_tail_x15_r0_body.zclbd133 bodyJsList133

end Host.Ts.Sim.Compose.VWFirst.VW15
