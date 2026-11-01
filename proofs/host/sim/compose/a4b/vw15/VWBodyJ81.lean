import host.sim.compose.a4b.vw15.VWBodyJ80
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl81 : Conv.NClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s792.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl81 (PRE_first_tail_x15_r0_body.cncl80 bodyNcl80)

theorem bodyClean81 : Conv.JClean (⟨19809, 16898, 2738992, 3552⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s792 :=
  PRE_first_tail_x15_r0_body.gjcl81 (PRE_first_tail_x15_r0_body.cjcl80 bodyClean80)

kernel_rfl bodyJsLe81 : Nat.ble PRE_first_tail_x15_r0_body.s776.next PRE_first_tail_x15_r0_body.s792.next = true
kernel_rfl bodyJsList81 : (PRE_first_tail_x15_r0_body.gjh81 ++ PRE_first_tail_x15_r0_body.cl81).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s792.next) PRE_first_tail_x15_r0_body.s794) = true
theorem bodyJs81 : JsHeapAbove PRE_first_tail_x15_r0_body.s792.next PRE_first_tail_x15_r0_body.s794 :=
  JsHeapAbove.glueSite bodyJs80 (Nat.le_of_ble_eq_true bodyJsLe81) PRE_first_tail_x15_r0_body.gjk81 PRE_first_tail_x15_r0_body.gjbd81 PRE_first_tail_x15_r0_body.cheap81 PRE_first_tail_x15_r0_body.zclbd81 bodyJsList81

end Host.Ts.Sim.Compose.VWFirst.VW15
