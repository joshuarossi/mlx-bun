import host.sim.compose.a4b.vw15.VWBodyJ168
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl169 : Conv.NClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1634.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl169 (PRE_first_tail_x15_r0_body.cncl168 bodyNcl168)

theorem bodyClean169 : Conv.JClean (⟨21536, 18636, 2807795, 7304⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1634 :=
  PRE_first_tail_x15_r0_body.gjcl169 (PRE_first_tail_x15_r0_body.cjcl168 bodyClean168)

kernel_rfl bodyJsLe169 : Nat.ble PRE_first_tail_x15_r0_body.s1626.next PRE_first_tail_x15_r0_body.s1634.next = true
kernel_rfl bodyJsList169 : (PRE_first_tail_x15_r0_body.gjh169 ++ PRE_first_tail_x15_r0_body.cl169).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1634.next) PRE_first_tail_x15_r0_body.s1636) = true
theorem bodyJs169 : JsHeapAbove PRE_first_tail_x15_r0_body.s1634.next PRE_first_tail_x15_r0_body.s1636 :=
  JsHeapAbove.glueSite bodyJs168 (Nat.le_of_ble_eq_true bodyJsLe169) PRE_first_tail_x15_r0_body.gjk169 PRE_first_tail_x15_r0_body.gjbd169 PRE_first_tail_x15_r0_body.cheap169 PRE_first_tail_x15_r0_body.zclbd169 bodyJsList169

end Host.Ts.Sim.Compose.VWFirst.VW15
