import host.sim.compose.a4b.vw15.VWBodyJ75
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl76 : Conv.NClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s743.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl76 (PRE_first_tail_x15_r0_body.cncl75 bodyNcl75)

theorem bodyClean76 : Conv.JClean (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s743 :=
  PRE_first_tail_x15_r0_body.gjcl76 (PRE_first_tail_x15_r0_body.cjcl75 bodyClean75)

kernel_rfl bodyJsLe76 : Nat.ble PRE_first_tail_x15_r0_body.s735.next PRE_first_tail_x15_r0_body.s743.next = true
kernel_rfl bodyJsList76 : (PRE_first_tail_x15_r0_body.gjh76 ++ PRE_first_tail_x15_r0_body.cl76).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s743.next) PRE_first_tail_x15_r0_body.s745) = true
theorem bodyJs76 : JsHeapAbove PRE_first_tail_x15_r0_body.s743.next PRE_first_tail_x15_r0_body.s745 :=
  JsHeapAbove.glueSite bodyJs75 (Nat.le_of_ble_eq_true bodyJsLe76) PRE_first_tail_x15_r0_body.gjk76 PRE_first_tail_x15_r0_body.gjbd76 PRE_first_tail_x15_r0_body.cheap76 PRE_first_tail_x15_r0_body.zclbd76 bodyJsList76

end Host.Ts.Sim.Compose.VWFirst.VW15
