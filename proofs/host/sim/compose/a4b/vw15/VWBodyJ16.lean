import host.sim.compose.a4b.vw15.VWBodyJ15
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl16 : Conv.NClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl16 (PRE_first_tail_x15_r0_body.cncl15 bodyNcl15)

theorem bodyClean16 : Conv.JClean (⟨18525, 15618, 2687627, 764⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s168 :=
  PRE_first_tail_x15_r0_body.gjcl16 (PRE_first_tail_x15_r0_body.cjcl15 bodyClean15)

kernel_rfl bodyJsLe16 : Nat.ble PRE_first_tail_x15_r0_body.s160.next PRE_first_tail_x15_r0_body.s168.next = true
kernel_rfl bodyJsList16 : (PRE_first_tail_x15_r0_body.gjh16 ++ PRE_first_tail_x15_r0_body.cl16).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s168.next) PRE_first_tail_x15_r0_body.s170) = true
theorem bodyJs16 : JsHeapAbove PRE_first_tail_x15_r0_body.s168.next PRE_first_tail_x15_r0_body.s170 :=
  JsHeapAbove.glueSite bodyJs15 (Nat.le_of_ble_eq_true bodyJsLe16) PRE_first_tail_x15_r0_body.gjk16 PRE_first_tail_x15_r0_body.gjbd16 PRE_first_tail_x15_r0_body.cheap16 PRE_first_tail_x15_r0_body.zclbd16 bodyJsList16

end Host.Ts.Sim.Compose.VWFirst.VW15
