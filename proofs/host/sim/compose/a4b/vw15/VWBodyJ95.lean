import host.sim.compose.a4b.vw15.VWBodyJ94
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl95 : Conv.NClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl95 (PRE_first_tail_x15_r0_body.cncl94 bodyNcl94)

theorem bodyClean95 : Conv.JClean (⟨20069, 17155, 2749293, 4114⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s919 :=
  PRE_first_tail_x15_r0_body.gjcl95 (PRE_first_tail_x15_r0_body.cjcl94 bodyClean94)

kernel_rfl bodyJsLe95 : Nat.ble PRE_first_tail_x15_r0_body.s915.next PRE_first_tail_x15_r0_body.s919.next = true
kernel_rfl bodyJsList95 : (PRE_first_tail_x15_r0_body.gjh95 ++ PRE_first_tail_x15_r0_body.cl95).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s919.next) PRE_first_tail_x15_r0_body.s921) = true
theorem bodyJs95 : JsHeapAbove PRE_first_tail_x15_r0_body.s919.next PRE_first_tail_x15_r0_body.s921 :=
  JsHeapAbove.glueSite bodyJs94 (Nat.le_of_ble_eq_true bodyJsLe95) PRE_first_tail_x15_r0_body.gjk95 PRE_first_tail_x15_r0_body.gjbd95 PRE_first_tail_x15_r0_body.cheap95 PRE_first_tail_x15_r0_body.zclbd95 bodyJsList95

end Host.Ts.Sim.Compose.VWFirst.VW15
