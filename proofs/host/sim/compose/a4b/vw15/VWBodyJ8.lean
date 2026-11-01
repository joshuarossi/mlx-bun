import host.sim.compose.a4b.vw15.VWBodyJ7
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl8 : Conv.NClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s86.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl8 (PRE_first_tail_x15_r0_body.cncl7 bodyNcl7)

theorem bodyClean8 : Conv.JClean (⟨18353, 15448, 2680757, 397⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s86 :=
  PRE_first_tail_x15_r0_body.gjcl8 (PRE_first_tail_x15_r0_body.cjcl7 bodyClean7)

kernel_rfl bodyJsLe8 : Nat.ble PRE_first_tail_x15_r0_body.s82.next PRE_first_tail_x15_r0_body.s86.next = true
kernel_rfl bodyJsList8 : (PRE_first_tail_x15_r0_body.gjh8 ++ PRE_first_tail_x15_r0_body.cl8).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s86.next) PRE_first_tail_x15_r0_body.s88) = true
theorem bodyJs8 : JsHeapAbove PRE_first_tail_x15_r0_body.s86.next PRE_first_tail_x15_r0_body.s88 :=
  JsHeapAbove.glueSite bodyJs7 (Nat.le_of_ble_eq_true bodyJsLe8) PRE_first_tail_x15_r0_body.gjk8 PRE_first_tail_x15_r0_body.gjbd8 PRE_first_tail_x15_r0_body.cheap8 PRE_first_tail_x15_r0_body.zclbd8 bodyJsList8

end Host.Ts.Sim.Compose.VWFirst.VW15
