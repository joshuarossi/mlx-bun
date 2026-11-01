import host.sim.compose.a4b.vw15.VWBodyJ104
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl105 : Conv.NClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl105 (PRE_first_tail_x15_r0_body.cncl104 bodyNcl104)

theorem bodyClean105 : Conv.JClean (⟨20281, 17372, 2757832, 4578⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1022 :=
  PRE_first_tail_x15_r0_body.gjcl105 (PRE_first_tail_x15_r0_body.cjcl104 bodyClean104)

kernel_rfl bodyJsLe105 : Nat.ble PRE_first_tail_x15_r0_body.s1006.next PRE_first_tail_x15_r0_body.s1022.next = true
kernel_rfl bodyJsList105 : (PRE_first_tail_x15_r0_body.gjh105 ++ PRE_first_tail_x15_r0_body.cl105).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1022.next) PRE_first_tail_x15_r0_body.s1024) = true
theorem bodyJs105 : JsHeapAbove PRE_first_tail_x15_r0_body.s1022.next PRE_first_tail_x15_r0_body.s1024 :=
  JsHeapAbove.glueSite bodyJs104 (Nat.le_of_ble_eq_true bodyJsLe105) PRE_first_tail_x15_r0_body.gjk105 PRE_first_tail_x15_r0_body.gjbd105 PRE_first_tail_x15_r0_body.cheap105 PRE_first_tail_x15_r0_body.zclbd105 bodyJsList105

end Host.Ts.Sim.Compose.VWFirst.VW15
