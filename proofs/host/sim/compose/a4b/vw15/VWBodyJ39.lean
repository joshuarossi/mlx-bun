import host.sim.compose.a4b.vw15.VWBodyJ38
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl39 : Conv.NClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s390.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl39 (PRE_first_tail_x15_r0_body.cncl38 bodyNcl38)

theorem bodyClean39 : Conv.JClean (⟨18981, 16052, 2705959, 1751⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s390 :=
  PRE_first_tail_x15_r0_body.gjcl39 (PRE_first_tail_x15_r0_body.cjcl38 bodyClean38)

kernel_rfl bodyJsLe39 : Nat.ble PRE_first_tail_x15_r0_body.s373.next PRE_first_tail_x15_r0_body.s390.next = true
kernel_rfl bodyJsList39 : (PRE_first_tail_x15_r0_body.gjh39 ++ PRE_first_tail_x15_r0_body.cl39).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s390.next) PRE_first_tail_x15_r0_body.s392) = true
theorem bodyJs39 : JsHeapAbove PRE_first_tail_x15_r0_body.s390.next PRE_first_tail_x15_r0_body.s392 :=
  JsHeapAbove.glueSite bodyJs38 (Nat.le_of_ble_eq_true bodyJsLe39) PRE_first_tail_x15_r0_body.gjk39 PRE_first_tail_x15_r0_body.gjbd39 PRE_first_tail_x15_r0_body.cheap39 PRE_first_tail_x15_r0_body.zclbd39 bodyJsList39

end Host.Ts.Sim.Compose.VWFirst.VW15
