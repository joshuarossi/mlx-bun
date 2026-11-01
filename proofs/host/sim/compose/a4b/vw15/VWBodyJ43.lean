import host.sim.compose.a4b.vw15.VWBodyJ42
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl43 : Conv.NClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s427.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl43 (PRE_first_tail_x15_r0_body.cncl42 bodyNcl42)

theorem bodyClean43 : Conv.JClean (⟨19054, 16155, 2708715, 1919⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s427 :=
  PRE_first_tail_x15_r0_body.gjcl43 (PRE_first_tail_x15_r0_body.cjcl42 bodyClean42)

kernel_rfl bodyJsLe43 : Nat.ble PRE_first_tail_x15_r0_body.s419.next PRE_first_tail_x15_r0_body.s427.next = true
kernel_rfl bodyJsList43 : (PRE_first_tail_x15_r0_body.gjh43 ++ PRE_first_tail_x15_r0_body.cl43).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s427.next) PRE_first_tail_x15_r0_body.s429) = true
theorem bodyJs43 : JsHeapAbove PRE_first_tail_x15_r0_body.s427.next PRE_first_tail_x15_r0_body.s429 :=
  JsHeapAbove.glueSite bodyJs42 (Nat.le_of_ble_eq_true bodyJsLe43) PRE_first_tail_x15_r0_body.gjk43 PRE_first_tail_x15_r0_body.gjbd43 PRE_first_tail_x15_r0_body.cheap43 PRE_first_tail_x15_r0_body.zclbd43 bodyJsList43

end Host.Ts.Sim.Compose.VWFirst.VW15
