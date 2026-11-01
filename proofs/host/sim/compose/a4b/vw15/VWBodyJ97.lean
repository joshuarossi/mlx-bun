import host.sim.compose.a4b.vw15.VWBodyJ96
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl97 : Conv.NClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s944.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl97 (PRE_first_tail_x15_r0_body.cncl96 bodyNcl96)

theorem bodyClean97 : Conv.JClean (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s944 :=
  PRE_first_tail_x15_r0_body.gjcl97 (PRE_first_tail_x15_r0_body.cjcl96 bodyClean96)

kernel_rfl bodyJsLe97 : Nat.ble PRE_first_tail_x15_r0_body.s936.next PRE_first_tail_x15_r0_body.s944.next = true
kernel_rfl bodyJsList97 : (PRE_first_tail_x15_r0_body.gjh97 ++ PRE_first_tail_x15_r0_body.cl97).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s944.next) PRE_first_tail_x15_r0_body.s946) = true
theorem bodyJs97 : JsHeapAbove PRE_first_tail_x15_r0_body.s944.next PRE_first_tail_x15_r0_body.s946 :=
  JsHeapAbove.glueSite bodyJs96 (Nat.le_of_ble_eq_true bodyJsLe97) PRE_first_tail_x15_r0_body.gjk97 PRE_first_tail_x15_r0_body.gjbd97 PRE_first_tail_x15_r0_body.cheap97 PRE_first_tail_x15_r0_body.zclbd97 bodyJsList97

end Host.Ts.Sim.Compose.VWFirst.VW15
