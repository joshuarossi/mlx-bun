import host.sim.compose.a4b.vw15.VWBodyJ1
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl2 : Conv.NClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s28.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl2 (PRE_first_tail_x15_r0_body.cncl1 bodyNcl1)

theorem bodyClean2 : Conv.JClean (⟨18233, 15322, 2676053, 139⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s28 :=
  PRE_first_tail_x15_r0_body.gjcl2 (PRE_first_tail_x15_r0_body.cjcl1 bodyClean1)

kernel_rfl bodyJsLe2 : Nat.ble PRE_first_tail_x15_r0_body.s24.next PRE_first_tail_x15_r0_body.s28.next = true
kernel_rfl bodyJsList2 : (PRE_first_tail_x15_r0_body.gjh2 ++ PRE_first_tail_x15_r0_body.cl2).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s28.next) PRE_first_tail_x15_r0_body.s30) = true
theorem bodyJs2 : JsHeapAbove PRE_first_tail_x15_r0_body.s28.next PRE_first_tail_x15_r0_body.s30 :=
  JsHeapAbove.glueSite bodyJs1 (Nat.le_of_ble_eq_true bodyJsLe2) PRE_first_tail_x15_r0_body.gjk2 PRE_first_tail_x15_r0_body.gjbd2 PRE_first_tail_x15_r0_body.cheap2 PRE_first_tail_x15_r0_body.zclbd2 bodyJsList2

end Host.Ts.Sim.Compose.VWFirst.VW15
