import host.sim.compose.a4b.vw15.VWBodyJ98
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl99 : Conv.NClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl99 (PRE_first_tail_x15_r0_body.cncl98 bodyNcl98)

theorem bodyClean99 : Conv.JClean (⟨20161, 17237, 2753051, 4316⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s965 :=
  PRE_first_tail_x15_r0_body.gjcl99 (PRE_first_tail_x15_r0_body.cjcl98 bodyClean98)

kernel_rfl bodyJsLe99 : Nat.ble PRE_first_tail_x15_r0_body.s948.next PRE_first_tail_x15_r0_body.s965.next = true
kernel_rfl bodyJsList99 : (PRE_first_tail_x15_r0_body.gjh99 ++ PRE_first_tail_x15_r0_body.cl99).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s965.next) PRE_first_tail_x15_r0_body.s967) = true
theorem bodyJs99 : JsHeapAbove PRE_first_tail_x15_r0_body.s965.next PRE_first_tail_x15_r0_body.s967 :=
  JsHeapAbove.glueSite bodyJs98 (Nat.le_of_ble_eq_true bodyJsLe99) PRE_first_tail_x15_r0_body.gjk99 PRE_first_tail_x15_r0_body.gjbd99 PRE_first_tail_x15_r0_body.cheap99 PRE_first_tail_x15_r0_body.zclbd99 bodyJsList99

end Host.Ts.Sim.Compose.VWFirst.VW15
