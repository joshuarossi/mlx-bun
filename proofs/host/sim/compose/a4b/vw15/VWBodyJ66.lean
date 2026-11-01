import host.sim.compose.a4b.vw15.VWBodyJ65
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl66 : Conv.NClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s649.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl66 (PRE_first_tail_x15_r0_body.cncl65 bodyNcl65)

theorem bodyClean66 : Conv.JClean (⟨19510, 16589, 2727059, 2906⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s649 :=
  PRE_first_tail_x15_r0_body.gjcl66 (PRE_first_tail_x15_r0_body.cjcl65 bodyClean65)

kernel_rfl bodyJsLe66 : Nat.ble PRE_first_tail_x15_r0_body.s632.next PRE_first_tail_x15_r0_body.s649.next = true
kernel_rfl bodyJsList66 : (PRE_first_tail_x15_r0_body.gjh66 ++ PRE_first_tail_x15_r0_body.cl66).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s649.next) PRE_first_tail_x15_r0_body.s651) = true
theorem bodyJs66 : JsHeapAbove PRE_first_tail_x15_r0_body.s649.next PRE_first_tail_x15_r0_body.s651 :=
  JsHeapAbove.glueSite bodyJs65 (Nat.le_of_ble_eq_true bodyJsLe66) PRE_first_tail_x15_r0_body.gjk66 PRE_first_tail_x15_r0_body.gjbd66 PRE_first_tail_x15_r0_body.cheap66 PRE_first_tail_x15_r0_body.zclbd66 bodyJsList66

end Host.Ts.Sim.Compose.VWFirst.VW15
