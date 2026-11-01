import host.sim.compose.a4b.vw15.VWBodyJ79
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl80 : Conv.NClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s776.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl80 (PRE_first_tail_x15_r0_body.cncl79 bodyNcl79)

theorem bodyClean80 : Conv.JClean (⟨19769, 16870, 2737255, 3475⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s776 :=
  PRE_first_tail_x15_r0_body.gjcl80 (PRE_first_tail_x15_r0_body.cjcl79 bodyClean79)

kernel_rfl bodyJsLe80 : Nat.ble PRE_first_tail_x15_r0_body.s772.next PRE_first_tail_x15_r0_body.s776.next = true
kernel_rfl bodyJsList80 : (PRE_first_tail_x15_r0_body.gjh80 ++ PRE_first_tail_x15_r0_body.cl80).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s776.next) PRE_first_tail_x15_r0_body.s778) = true
theorem bodyJs80 : JsHeapAbove PRE_first_tail_x15_r0_body.s776.next PRE_first_tail_x15_r0_body.s778 :=
  JsHeapAbove.glueSite bodyJs79 (Nat.le_of_ble_eq_true bodyJsLe80) PRE_first_tail_x15_r0_body.gjk80 PRE_first_tail_x15_r0_body.gjbd80 PRE_first_tail_x15_r0_body.cheap80 PRE_first_tail_x15_r0_body.zclbd80 bodyJsList80

end Host.Ts.Sim.Compose.VWFirst.VW15
