import host.sim.compose.a4b.vw15.VWBodyJ18
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl19 : Conv.NClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s197.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl19 (PRE_first_tail_x15_r0_body.cncl18 bodyNcl18)

theorem bodyClean19 : Conv.JClean (⟨18582, 15681, 2689883, 893⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s197 :=
  PRE_first_tail_x15_r0_body.gjcl19 (PRE_first_tail_x15_r0_body.cjcl18 bodyClean18)

kernel_rfl bodyJsLe19 : Nat.ble PRE_first_tail_x15_r0_body.s189.next PRE_first_tail_x15_r0_body.s197.next = true
kernel_rfl bodyJsList19 : (PRE_first_tail_x15_r0_body.gjh19 ++ PRE_first_tail_x15_r0_body.cl19).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s197.next) PRE_first_tail_x15_r0_body.s199) = true
theorem bodyJs19 : JsHeapAbove PRE_first_tail_x15_r0_body.s197.next PRE_first_tail_x15_r0_body.s199 :=
  JsHeapAbove.glueSite bodyJs18 (Nat.le_of_ble_eq_true bodyJsLe19) PRE_first_tail_x15_r0_body.gjk19 PRE_first_tail_x15_r0_body.gjbd19 PRE_first_tail_x15_r0_body.cheap19 PRE_first_tail_x15_r0_body.zclbd19 bodyJsList19

end Host.Ts.Sim.Compose.VWFirst.VW15
