import host.sim.compose.a4b.vw15.VWBodyJ124
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl125 : Conv.NClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1207.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl125 (PRE_first_tail_x15_r0_body.cncl124 bodyNcl124)

theorem bodyClean125 : Conv.JClean (⟨20656, 17755, 2772663, 5398⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1207 :=
  PRE_first_tail_x15_r0_body.gjcl125 (PRE_first_tail_x15_r0_body.cjcl124 bodyClean124)

kernel_rfl bodyJsLe125 : Nat.ble PRE_first_tail_x15_r0_body.s1203.next PRE_first_tail_x15_r0_body.s1207.next = true
kernel_rfl bodyJsList125 : (PRE_first_tail_x15_r0_body.gjh125 ++ PRE_first_tail_x15_r0_body.cl125).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1207.next) PRE_first_tail_x15_r0_body.s1209) = true
theorem bodyJs125 : JsHeapAbove PRE_first_tail_x15_r0_body.s1207.next PRE_first_tail_x15_r0_body.s1209 :=
  JsHeapAbove.glueSite bodyJs124 (Nat.le_of_ble_eq_true bodyJsLe125) PRE_first_tail_x15_r0_body.gjk125 PRE_first_tail_x15_r0_body.gjbd125 PRE_first_tail_x15_r0_body.cheap125 PRE_first_tail_x15_r0_body.zclbd125 bodyJsList125

end Host.Ts.Sim.Compose.VWFirst.VW15
