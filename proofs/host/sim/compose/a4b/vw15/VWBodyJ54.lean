import host.sim.compose.a4b.vw15.VWBodyJ53
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl54 : Conv.NClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s534.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl54 (PRE_first_tail_x15_r0_body.cncl53 bodyNcl53)

theorem bodyClean54 : Conv.JClean (⟨19274, 16352, 2717643, 2393⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s534 :=
  PRE_first_tail_x15_r0_body.gjcl54 (PRE_first_tail_x15_r0_body.cjcl53 bodyClean53)

kernel_rfl bodyJsLe54 : Nat.ble PRE_first_tail_x15_r0_body.s517.next PRE_first_tail_x15_r0_body.s534.next = true
kernel_rfl bodyJsList54 : (PRE_first_tail_x15_r0_body.gjh54 ++ PRE_first_tail_x15_r0_body.cl54).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s534.next) PRE_first_tail_x15_r0_body.s536) = true
theorem bodyJs54 : JsHeapAbove PRE_first_tail_x15_r0_body.s534.next PRE_first_tail_x15_r0_body.s536 :=
  JsHeapAbove.glueSite bodyJs53 (Nat.le_of_ble_eq_true bodyJsLe54) PRE_first_tail_x15_r0_body.gjk54 PRE_first_tail_x15_r0_body.gjbd54 PRE_first_tail_x15_r0_body.cheap54 PRE_first_tail_x15_r0_body.zclbd54 bodyJsList54

end Host.Ts.Sim.Compose.VWFirst.VW15
