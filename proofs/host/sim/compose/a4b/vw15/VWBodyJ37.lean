import host.sim.compose.a4b.vw15.VWBodyJ36
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl37 : Conv.NClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl37 (PRE_first_tail_x15_r0_body.cncl36 bodyNcl36)

theorem bodyClean37 : Conv.JClean (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s369 :=
  PRE_first_tail_x15_r0_body.gjcl37 (PRE_first_tail_x15_r0_body.cjcl36 bodyClean36)

kernel_rfl bodyJsLe37 : Nat.ble PRE_first_tail_x15_r0_body.s361.next PRE_first_tail_x15_r0_body.s369.next = true
kernel_rfl bodyJsList37 : (PRE_first_tail_x15_r0_body.gjh37 ++ PRE_first_tail_x15_r0_body.cl37).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s369.next) PRE_first_tail_x15_r0_body.s371) = true
theorem bodyJs37 : JsHeapAbove PRE_first_tail_x15_r0_body.s369.next PRE_first_tail_x15_r0_body.s371 :=
  JsHeapAbove.glueSite bodyJs36 (Nat.le_of_ble_eq_true bodyJsLe37) PRE_first_tail_x15_r0_body.gjk37 PRE_first_tail_x15_r0_body.gjbd37 PRE_first_tail_x15_r0_body.cheap37 PRE_first_tail_x15_r0_body.zclbd37 bodyJsList37

end Host.Ts.Sim.Compose.VWFirst.VW15
