import host.sim.compose.a4b.vw15.VWBodyJ26
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl27 : Conv.NClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s275.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl27 (PRE_first_tail_x15_r0_body.cncl26 bodyNcl26)

theorem bodyClean27 : Conv.JClean (⟨18745, 15815, 2696543, 1238⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s275 :=
  PRE_first_tail_x15_r0_body.gjcl27 (PRE_first_tail_x15_r0_body.cjcl26 bodyClean26)

kernel_rfl bodyJsLe27 : Nat.ble PRE_first_tail_x15_r0_body.s258.next PRE_first_tail_x15_r0_body.s275.next = true
kernel_rfl bodyJsList27 : (PRE_first_tail_x15_r0_body.gjh27 ++ PRE_first_tail_x15_r0_body.cl27).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s275.next) PRE_first_tail_x15_r0_body.s277) = true
theorem bodyJs27 : JsHeapAbove PRE_first_tail_x15_r0_body.s275.next PRE_first_tail_x15_r0_body.s277 :=
  JsHeapAbove.glueSite bodyJs26 (Nat.le_of_ble_eq_true bodyJsLe27) PRE_first_tail_x15_r0_body.gjk27 PRE_first_tail_x15_r0_body.gjbd27 PRE_first_tail_x15_r0_body.cheap27 PRE_first_tail_x15_r0_body.zclbd27 bodyJsList27

end Host.Ts.Sim.Compose.VWFirst.VW15
