import host.sim.compose.a4b.vw15.VWBodyJ48
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl49 : Conv.NClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl49 (PRE_first_tail_x15_r0_body.cncl48 bodyNcl48)

theorem bodyClean49 : Conv.JClean (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s484 :=
  PRE_first_tail_x15_r0_body.gjcl49 (PRE_first_tail_x15_r0_body.cjcl48 bodyClean48)

kernel_rfl bodyJsLe49 : Nat.ble PRE_first_tail_x15_r0_body.s476.next PRE_first_tail_x15_r0_body.s484.next = true
kernel_rfl bodyJsList49 : (PRE_first_tail_x15_r0_body.gjh49 ++ PRE_first_tail_x15_r0_body.cl49).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s484.next) PRE_first_tail_x15_r0_body.s486) = true
theorem bodyJs49 : JsHeapAbove PRE_first_tail_x15_r0_body.s484.next PRE_first_tail_x15_r0_body.s486 :=
  JsHeapAbove.glueSite bodyJs48 (Nat.le_of_ble_eq_true bodyJsLe49) PRE_first_tail_x15_r0_body.gjk49 PRE_first_tail_x15_r0_body.gjbd49 PRE_first_tail_x15_r0_body.cheap49 PRE_first_tail_x15_r0_body.zclbd49 bodyJsList49

end Host.Ts.Sim.Compose.VWFirst.VW15
