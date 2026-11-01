import host.sim.compose.a4b.vw15.VWBodyJ12
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl13 : Conv.NClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s139.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl13 (PRE_first_tail_x15_r0_body.cncl12 bodyNcl12)

theorem bodyClean13 : Conv.JClean (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s139 :=
  PRE_first_tail_x15_r0_body.gjcl13 (PRE_first_tail_x15_r0_body.cjcl12 bodyClean12)

kernel_rfl bodyJsLe13 : Nat.ble PRE_first_tail_x15_r0_body.s131.next PRE_first_tail_x15_r0_body.s139.next = true
kernel_rfl bodyJsList13 : (PRE_first_tail_x15_r0_body.gjh13 ++ PRE_first_tail_x15_r0_body.cl13).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s139.next) PRE_first_tail_x15_r0_body.s141) = true
theorem bodyJs13 : JsHeapAbove PRE_first_tail_x15_r0_body.s139.next PRE_first_tail_x15_r0_body.s141 :=
  JsHeapAbove.glueSite bodyJs12 (Nat.le_of_ble_eq_true bodyJsLe13) PRE_first_tail_x15_r0_body.gjk13 PRE_first_tail_x15_r0_body.gjbd13 PRE_first_tail_x15_r0_body.cheap13 PRE_first_tail_x15_r0_body.zclbd13 bodyJsList13

end Host.Ts.Sim.Compose.VWFirst.VW15
