import host.sim.compose.a4b.vw15.VWBodyJ92
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl93 : Conv.NClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl93 (PRE_first_tail_x15_r0_body.cncl92 bodyNcl92)

theorem bodyClean93 : Conv.JClean (⟨20045, 17135, 2748408, 4065⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s907 :=
  PRE_first_tail_x15_r0_body.gjcl93 (PRE_first_tail_x15_r0_body.cjcl92 bodyClean92)

kernel_rfl bodyJsLe93 : Nat.ble PRE_first_tail_x15_r0_body.s891.next PRE_first_tail_x15_r0_body.s907.next = true
kernel_rfl bodyJsList93 : (PRE_first_tail_x15_r0_body.gjh93 ++ PRE_first_tail_x15_r0_body.cl93).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s907.next) PRE_first_tail_x15_r0_body.s909) = true
theorem bodyJs93 : JsHeapAbove PRE_first_tail_x15_r0_body.s907.next PRE_first_tail_x15_r0_body.s909 :=
  JsHeapAbove.glueSite bodyJs92 (Nat.le_of_ble_eq_true bodyJsLe93) PRE_first_tail_x15_r0_body.gjk93 PRE_first_tail_x15_r0_body.gjbd93 PRE_first_tail_x15_r0_body.cheap93 PRE_first_tail_x15_r0_body.zclbd93 bodyJsList93

end Host.Ts.Sim.Compose.VWFirst.VW15
