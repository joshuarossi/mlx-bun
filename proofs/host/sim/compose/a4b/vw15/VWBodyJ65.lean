import host.sim.compose.a4b.vw15.VWBodyJ64
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl65 : Conv.NClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s632.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl65 (PRE_first_tail_x15_r0_body.cncl64 bodyNcl64)

theorem bodyClean65 : Conv.JClean (⟨19476, 16570, 2725587, 2833⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s632 :=
  PRE_first_tail_x15_r0_body.gjcl65 (PRE_first_tail_x15_r0_body.cjcl64 bodyClean64)

kernel_rfl bodyJsLe65 : Nat.ble PRE_first_tail_x15_r0_body.s628.next PRE_first_tail_x15_r0_body.s632.next = true
kernel_rfl bodyJsList65 : (PRE_first_tail_x15_r0_body.gjh65 ++ PRE_first_tail_x15_r0_body.cl65).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s632.next) PRE_first_tail_x15_r0_body.s634) = true
theorem bodyJs65 : JsHeapAbove PRE_first_tail_x15_r0_body.s632.next PRE_first_tail_x15_r0_body.s634 :=
  JsHeapAbove.glueSite bodyJs64 (Nat.le_of_ble_eq_true bodyJsLe65) PRE_first_tail_x15_r0_body.gjk65 PRE_first_tail_x15_r0_body.gjbd65 PRE_first_tail_x15_r0_body.cheap65 PRE_first_tail_x15_r0_body.zclbd65 bodyJsList65

end Host.Ts.Sim.Compose.VWFirst.VW15
