import host.sim.compose.a4b.vw15.VWBodyJ39
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl40 : Conv.NClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s398.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl40 (PRE_first_tail_x15_r0_body.cncl39 bodyNcl39)

theorem bodyClean40 : Conv.JClean (⟨18997, 16092, 2706455, 1790⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s398 :=
  PRE_first_tail_x15_r0_body.gjcl40 (PRE_first_tail_x15_r0_body.cjcl39 bodyClean39)

kernel_rfl bodyJsLe40 : Nat.ble PRE_first_tail_x15_r0_body.s390.next PRE_first_tail_x15_r0_body.s398.next = true
kernel_rfl bodyJsList40 : (PRE_first_tail_x15_r0_body.gjh40 ++ PRE_first_tail_x15_r0_body.cl40).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s398.next) PRE_first_tail_x15_r0_body.s400) = true
theorem bodyJs40 : JsHeapAbove PRE_first_tail_x15_r0_body.s398.next PRE_first_tail_x15_r0_body.s400 :=
  JsHeapAbove.glueSite bodyJs39 (Nat.le_of_ble_eq_true bodyJsLe40) PRE_first_tail_x15_r0_body.gjk40 PRE_first_tail_x15_r0_body.gjbd40 PRE_first_tail_x15_r0_body.cheap40 PRE_first_tail_x15_r0_body.zclbd40 bodyJsList40

end Host.Ts.Sim.Compose.VWFirst.VW15
