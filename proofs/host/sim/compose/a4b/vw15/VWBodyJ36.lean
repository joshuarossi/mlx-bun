import host.sim.compose.a4b.vw15.VWBodyJ35
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl36 : Conv.NClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s361.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl36 (PRE_first_tail_x15_r0_body.cncl35 bodyNcl35)

theorem bodyClean36 : Conv.JClean (⟨18924, 15989, 2703703, 1622⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s361 :=
  PRE_first_tail_x15_r0_body.gjcl36 (PRE_first_tail_x15_r0_body.cjcl35 bodyClean35)

kernel_rfl bodyJsLe36 : Nat.ble PRE_first_tail_x15_r0_body.s344.next PRE_first_tail_x15_r0_body.s361.next = true
kernel_rfl bodyJsList36 : (PRE_first_tail_x15_r0_body.gjh36 ++ PRE_first_tail_x15_r0_body.cl36).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s361.next) PRE_first_tail_x15_r0_body.s363) = true
theorem bodyJs36 : JsHeapAbove PRE_first_tail_x15_r0_body.s361.next PRE_first_tail_x15_r0_body.s363 :=
  JsHeapAbove.glueSite bodyJs35 (Nat.le_of_ble_eq_true bodyJsLe36) PRE_first_tail_x15_r0_body.gjk36 PRE_first_tail_x15_r0_body.gjbd36 PRE_first_tail_x15_r0_body.cheap36 PRE_first_tail_x15_r0_body.zclbd36 bodyJsList36

end Host.Ts.Sim.Compose.VWFirst.VW15
