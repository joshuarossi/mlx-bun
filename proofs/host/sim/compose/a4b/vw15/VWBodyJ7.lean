import host.sim.compose.a4b.vw15.VWBodyJ6
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl7 : Conv.NClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s82.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl7 (PRE_first_tail_x15_r0_body.cncl6 bodyNcl6)

theorem bodyClean7 : Conv.JClean (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s82 :=
  PRE_first_tail_x15_r0_body.gjcl7 (PRE_first_tail_x15_r0_body.cjcl6 bodyClean6)

kernel_rfl bodyJsLe7 : Nat.ble PRE_first_tail_x15_r0_body.s74.next PRE_first_tail_x15_r0_body.s82.next = true
kernel_rfl bodyJsList7 : (PRE_first_tail_x15_r0_body.gjh7 ++ PRE_first_tail_x15_r0_body.cl7).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s82.next) PRE_first_tail_x15_r0_body.s84) = true
theorem bodyJs7 : JsHeapAbove PRE_first_tail_x15_r0_body.s82.next PRE_first_tail_x15_r0_body.s84 :=
  JsHeapAbove.glueSite bodyJs6 (Nat.le_of_ble_eq_true bodyJsLe7) PRE_first_tail_x15_r0_body.gjk7 PRE_first_tail_x15_r0_body.gjbd7 PRE_first_tail_x15_r0_body.cheap7 PRE_first_tail_x15_r0_body.zclbd7 bodyJsList7

end Host.Ts.Sim.Compose.VWFirst.VW15
