import host.sim.compose.a4b.vw15.VWBodyJ179
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl180 : Conv.NClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1741.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl180 (PRE_first_tail_x15_r0_body.cncl179 bodyNcl179)

theorem bodyClean180 : Conv.JClean (⟨21756, 18833, 2816727, 7778⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1741 :=
  PRE_first_tail_x15_r0_body.gjcl180 (PRE_first_tail_x15_r0_body.cjcl179 bodyClean179)

kernel_rfl bodyJsLe180 : Nat.ble PRE_first_tail_x15_r0_body.s1724.next PRE_first_tail_x15_r0_body.s1741.next = true
kernel_rfl bodyJsList180 : (PRE_first_tail_x15_r0_body.gjh180 ++ PRE_first_tail_x15_r0_body.cl180).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1741.next) PRE_first_tail_x15_r0_body.s1743) = true
theorem bodyJs180 : JsHeapAbove PRE_first_tail_x15_r0_body.s1741.next PRE_first_tail_x15_r0_body.s1743 :=
  JsHeapAbove.glueSite bodyJs179 (Nat.le_of_ble_eq_true bodyJsLe180) PRE_first_tail_x15_r0_body.gjk180 PRE_first_tail_x15_r0_body.gjbd180 PRE_first_tail_x15_r0_body.cheap180 PRE_first_tail_x15_r0_body.zclbd180 bodyJsList180

end Host.Ts.Sim.Compose.VWFirst.VW15
