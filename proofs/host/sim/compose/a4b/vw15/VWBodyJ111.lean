import host.sim.compose.a4b.vw15.VWBodyJ110
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl111 : Conv.NClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1080.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl111 (PRE_first_tail_x15_r0_body.cncl110 bodyNcl110)

theorem bodyClean111 : Conv.JClean (⟨20397, 17474, 2762467, 4829⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1080 :=
  PRE_first_tail_x15_r0_body.gjcl111 (PRE_first_tail_x15_r0_body.cjcl110 bodyClean110)

kernel_rfl bodyJsLe111 : Nat.ble PRE_first_tail_x15_r0_body.s1063.next PRE_first_tail_x15_r0_body.s1080.next = true
kernel_rfl bodyJsList111 : (PRE_first_tail_x15_r0_body.gjh111 ++ PRE_first_tail_x15_r0_body.cl111).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1080.next) PRE_first_tail_x15_r0_body.s1082) = true
theorem bodyJs111 : JsHeapAbove PRE_first_tail_x15_r0_body.s1080.next PRE_first_tail_x15_r0_body.s1082 :=
  JsHeapAbove.glueSite bodyJs110 (Nat.le_of_ble_eq_true bodyJsLe111) PRE_first_tail_x15_r0_body.gjk111 PRE_first_tail_x15_r0_body.gjbd111 PRE_first_tail_x15_r0_body.cheap111 PRE_first_tail_x15_r0_body.zclbd111 bodyJsList111

end Host.Ts.Sim.Compose.VWFirst.VW15
