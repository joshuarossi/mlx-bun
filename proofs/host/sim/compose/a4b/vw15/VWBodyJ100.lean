import host.sim.compose.a4b.vw15.VWBodyJ99
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl100 : Conv.NClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s973.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl100 (PRE_first_tail_x15_r0_body.cncl99 bodyNcl99)

theorem bodyClean100 : Conv.JClean (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s973 :=
  PRE_first_tail_x15_r0_body.gjcl100 (PRE_first_tail_x15_r0_body.cjcl99 bodyClean99)

kernel_rfl bodyJsLe100 : Nat.ble PRE_first_tail_x15_r0_body.s965.next PRE_first_tail_x15_r0_body.s973.next = true
kernel_rfl bodyJsList100 : (PRE_first_tail_x15_r0_body.gjh100 ++ PRE_first_tail_x15_r0_body.cl100).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s973.next) PRE_first_tail_x15_r0_body.s975) = true
theorem bodyJs100 : JsHeapAbove PRE_first_tail_x15_r0_body.s973.next PRE_first_tail_x15_r0_body.s975 :=
  JsHeapAbove.glueSite bodyJs99 (Nat.le_of_ble_eq_true bodyJsLe100) PRE_first_tail_x15_r0_body.gjk100 PRE_first_tail_x15_r0_body.gjbd100 PRE_first_tail_x15_r0_body.cheap100 PRE_first_tail_x15_r0_body.zclbd100 bodyJsList100

end Host.Ts.Sim.Compose.VWFirst.VW15
