import host.sim.compose.a4b.vw15.VWBodyJ103
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl104 : Conv.NClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1006.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl104 (PRE_first_tail_x15_r0_body.cncl103 bodyNcl103)

theorem bodyClean104 : Conv.JClean (⟨20241, 17344, 2756095, 4501⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1006 :=
  PRE_first_tail_x15_r0_body.gjcl104 (PRE_first_tail_x15_r0_body.cjcl103 bodyClean103)

kernel_rfl bodyJsLe104 : Nat.ble PRE_first_tail_x15_r0_body.s1002.next PRE_first_tail_x15_r0_body.s1006.next = true
kernel_rfl bodyJsList104 : (PRE_first_tail_x15_r0_body.gjh104 ++ PRE_first_tail_x15_r0_body.cl104).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1006.next) PRE_first_tail_x15_r0_body.s1008) = true
theorem bodyJs104 : JsHeapAbove PRE_first_tail_x15_r0_body.s1006.next PRE_first_tail_x15_r0_body.s1008 :=
  JsHeapAbove.glueSite bodyJs103 (Nat.le_of_ble_eq_true bodyJsLe104) PRE_first_tail_x15_r0_body.gjk104 PRE_first_tail_x15_r0_body.gjbd104 PRE_first_tail_x15_r0_body.cheap104 PRE_first_tail_x15_r0_body.zclbd104 bodyJsList104

end Host.Ts.Sim.Compose.VWFirst.VW15
