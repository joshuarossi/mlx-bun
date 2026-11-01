import host.sim.compose.a4b.vw15.VWBodyJ30
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl31 : Conv.NClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s312.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl31 (PRE_first_tail_x15_r0_body.cncl30 bodyNcl30)

theorem bodyClean31 : Conv.JClean (⟨18818, 15918, 2699295, 1406⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s312 :=
  PRE_first_tail_x15_r0_body.gjcl31 (PRE_first_tail_x15_r0_body.cjcl30 bodyClean30)

kernel_rfl bodyJsLe31 : Nat.ble PRE_first_tail_x15_r0_body.s304.next PRE_first_tail_x15_r0_body.s312.next = true
kernel_rfl bodyJsList31 : (PRE_first_tail_x15_r0_body.gjh31 ++ PRE_first_tail_x15_r0_body.cl31).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s312.next) PRE_first_tail_x15_r0_body.s314) = true
theorem bodyJs31 : JsHeapAbove PRE_first_tail_x15_r0_body.s312.next PRE_first_tail_x15_r0_body.s314 :=
  JsHeapAbove.glueSite bodyJs30 (Nat.le_of_ble_eq_true bodyJsLe31) PRE_first_tail_x15_r0_body.gjk31 PRE_first_tail_x15_r0_body.gjbd31 PRE_first_tail_x15_r0_body.cheap31 PRE_first_tail_x15_r0_body.zclbd31 bodyJsList31

end Host.Ts.Sim.Compose.VWFirst.VW15
