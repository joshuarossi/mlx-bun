import host.sim.compose.a4b.vw15.VWBodyJ118
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl119 : Conv.NClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1149.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl119 (PRE_first_tail_x15_r0_body.cncl118 bodyNcl118)

theorem bodyClean119 : Conv.JClean (⟨20541, 17629, 2768129, 5140⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1149 :=
  PRE_first_tail_x15_r0_body.gjcl119 (PRE_first_tail_x15_r0_body.cjcl118 bodyClean118)

kernel_rfl bodyJsLe119 : Nat.ble PRE_first_tail_x15_r0_body.s1145.next PRE_first_tail_x15_r0_body.s1149.next = true
kernel_rfl bodyJsList119 : (PRE_first_tail_x15_r0_body.gjh119 ++ PRE_first_tail_x15_r0_body.cl119).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1149.next) PRE_first_tail_x15_r0_body.s1151) = true
theorem bodyJs119 : JsHeapAbove PRE_first_tail_x15_r0_body.s1149.next PRE_first_tail_x15_r0_body.s1151 :=
  JsHeapAbove.glueSite bodyJs118 (Nat.le_of_ble_eq_true bodyJsLe119) PRE_first_tail_x15_r0_body.gjk119 PRE_first_tail_x15_r0_body.gjbd119 PRE_first_tail_x15_r0_body.cheap119 PRE_first_tail_x15_r0_body.zclbd119 bodyJsList119

end Host.Ts.Sim.Compose.VWFirst.VW15
