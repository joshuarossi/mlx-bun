import host.sim.compose.a4b.vw15.VWBodyJ59
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl60 : Conv.NClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s591.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl60 (PRE_first_tail_x15_r0_body.cncl59 bodyNcl59)

theorem bodyClean60 : Conv.JClean (⟨19396, 16463, 2722547, 2648⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s591 :=
  PRE_first_tail_x15_r0_body.gjcl60 (PRE_first_tail_x15_r0_body.cjcl59 bodyClean59)

kernel_rfl bodyJsLe60 : Nat.ble PRE_first_tail_x15_r0_body.s574.next PRE_first_tail_x15_r0_body.s591.next = true
kernel_rfl bodyJsList60 : (PRE_first_tail_x15_r0_body.gjh60 ++ PRE_first_tail_x15_r0_body.cl60).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s591.next) PRE_first_tail_x15_r0_body.s593) = true
theorem bodyJs60 : JsHeapAbove PRE_first_tail_x15_r0_body.s591.next PRE_first_tail_x15_r0_body.s593 :=
  JsHeapAbove.glueSite bodyJs59 (Nat.le_of_ble_eq_true bodyJsLe60) PRE_first_tail_x15_r0_body.gjk60 PRE_first_tail_x15_r0_body.gjbd60 PRE_first_tail_x15_r0_body.cheap60 PRE_first_tail_x15_r0_body.zclbd60 bodyJsList60

end Host.Ts.Sim.Compose.VWFirst.VW15
