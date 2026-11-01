import host.sim.compose.a4b.vw15.VWBodyJ148
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl149 : Conv.NClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1437.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl149 (PRE_first_tail_x15_r0_body.cncl148 bodyNcl148)

theorem bodyClean149 : Conv.JClean (⟨21128, 18229, 2791503, 6424⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1437 :=
  PRE_first_tail_x15_r0_body.gjcl149 (PRE_first_tail_x15_r0_body.cjcl148 bodyClean148)

kernel_rfl bodyJsLe149 : Nat.ble PRE_first_tail_x15_r0_body.s1433.next PRE_first_tail_x15_r0_body.s1437.next = true
kernel_rfl bodyJsList149 : (PRE_first_tail_x15_r0_body.gjh149 ++ PRE_first_tail_x15_r0_body.cl149).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1437.next) PRE_first_tail_x15_r0_body.s1439) = true
theorem bodyJs149 : JsHeapAbove PRE_first_tail_x15_r0_body.s1437.next PRE_first_tail_x15_r0_body.s1439 :=
  JsHeapAbove.glueSite bodyJs148 (Nat.le_of_ble_eq_true bodyJsLe149) PRE_first_tail_x15_r0_body.gjk149 PRE_first_tail_x15_r0_body.gjbd149 PRE_first_tail_x15_r0_body.cheap149 PRE_first_tail_x15_r0_body.zclbd149 bodyJsList149

end Host.Ts.Sim.Compose.VWFirst.VW15
