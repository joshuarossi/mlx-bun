import host.sim.compose.a4b.vw15.VWBodyJ11
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl12 : Conv.NClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s131.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl12 (PRE_first_tail_x15_r0_body.cncl11 bodyNcl11)

theorem bodyClean12 : Conv.JClean (⟨18452, 15515, 2684875, 596⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s131 :=
  PRE_first_tail_x15_r0_body.gjcl12 (PRE_first_tail_x15_r0_body.cjcl11 bodyClean11)

kernel_rfl bodyJsLe12 : Nat.ble PRE_first_tail_x15_r0_body.s114.next PRE_first_tail_x15_r0_body.s131.next = true
kernel_rfl bodyJsList12 : (PRE_first_tail_x15_r0_body.gjh12 ++ PRE_first_tail_x15_r0_body.cl12).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s131.next) PRE_first_tail_x15_r0_body.s133) = true
theorem bodyJs12 : JsHeapAbove PRE_first_tail_x15_r0_body.s131.next PRE_first_tail_x15_r0_body.s133 :=
  JsHeapAbove.glueSite bodyJs11 (Nat.le_of_ble_eq_true bodyJsLe12) PRE_first_tail_x15_r0_body.gjk12 PRE_first_tail_x15_r0_body.gjbd12 PRE_first_tail_x15_r0_body.cheap12 PRE_first_tail_x15_r0_body.zclbd12 bodyJsList12

end Host.Ts.Sim.Compose.VWFirst.VW15
