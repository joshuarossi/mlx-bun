import host.sim.compose.a4b.vw15.VWBodyJ3
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl4 : Conv.NClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s53.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl4 (PRE_first_tail_x15_r0_body.cncl3 bodyNcl3)

theorem bodyClean4 : Conv.JClean (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s53 :=
  PRE_first_tail_x15_r0_body.gjcl4 (PRE_first_tail_x15_r0_body.cjcl3 bodyClean3)

kernel_rfl bodyJsLe4 : Nat.ble PRE_first_tail_x15_r0_body.s45.next PRE_first_tail_x15_r0_body.s53.next = true
kernel_rfl bodyJsList4 : (PRE_first_tail_x15_r0_body.gjh4 ++ PRE_first_tail_x15_r0_body.cl4).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s53.next) PRE_first_tail_x15_r0_body.s55) = true
theorem bodyJs4 : JsHeapAbove PRE_first_tail_x15_r0_body.s53.next PRE_first_tail_x15_r0_body.s55 :=
  JsHeapAbove.glueSite bodyJs3 (Nat.le_of_ble_eq_true bodyJsLe4) PRE_first_tail_x15_r0_body.gjk4 PRE_first_tail_x15_r0_body.gjbd4 PRE_first_tail_x15_r0_body.cheap4 PRE_first_tail_x15_r0_body.zclbd4 bodyJsList4

end Host.Ts.Sim.Compose.VWFirst.VW15
