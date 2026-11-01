import host.sim.compose.a4b.vw15.VWBodyJ22
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl23 : Conv.NClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s229.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl23 (PRE_first_tail_x15_r0_body.cncl22 bodyNcl22)

theorem bodyClean23 : Conv.JClean (⟨18653, 15733, 2692793, 1036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s229 :=
  PRE_first_tail_x15_r0_body.gjcl23 (PRE_first_tail_x15_r0_body.cjcl22 bodyClean22)

kernel_rfl bodyJsLe23 : Nat.ble PRE_first_tail_x15_r0_body.s225.next PRE_first_tail_x15_r0_body.s229.next = true
kernel_rfl bodyJsList23 : (PRE_first_tail_x15_r0_body.gjh23 ++ PRE_first_tail_x15_r0_body.cl23).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s229.next) PRE_first_tail_x15_r0_body.s231) = true
theorem bodyJs23 : JsHeapAbove PRE_first_tail_x15_r0_body.s229.next PRE_first_tail_x15_r0_body.s231 :=
  JsHeapAbove.glueSite bodyJs22 (Nat.le_of_ble_eq_true bodyJsLe23) PRE_first_tail_x15_r0_body.gjk23 PRE_first_tail_x15_r0_body.gjbd23 PRE_first_tail_x15_r0_body.cheap23 PRE_first_tail_x15_r0_body.zclbd23 bodyJsList23

end Host.Ts.Sim.Compose.VWFirst.VW15
