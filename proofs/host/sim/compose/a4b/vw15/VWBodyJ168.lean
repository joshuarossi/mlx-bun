import host.sim.compose.a4b.vw15.VWBodyJ167
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl168 : Conv.NClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl168 (PRE_first_tail_x15_r0_body.cncl167 bodyNcl167)

theorem bodyClean168 : Conv.JClean (⟨21520, 18596, 2807299, 7265⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1626 :=
  PRE_first_tail_x15_r0_body.gjcl168 (PRE_first_tail_x15_r0_body.cjcl167 bodyClean167)

kernel_rfl bodyJsLe168 : Nat.ble PRE_first_tail_x15_r0_body.s1609.next PRE_first_tail_x15_r0_body.s1626.next = true
kernel_rfl bodyJsList168 : (PRE_first_tail_x15_r0_body.gjh168 ++ PRE_first_tail_x15_r0_body.cl168).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1626.next) PRE_first_tail_x15_r0_body.s1628) = true
theorem bodyJs168 : JsHeapAbove PRE_first_tail_x15_r0_body.s1626.next PRE_first_tail_x15_r0_body.s1628 :=
  JsHeapAbove.glueSite bodyJs167 (Nat.le_of_ble_eq_true bodyJsLe168) PRE_first_tail_x15_r0_body.gjk168 PRE_first_tail_x15_r0_body.gjbd168 PRE_first_tail_x15_r0_body.cheap168 PRE_first_tail_x15_r0_body.zclbd168 bodyJsList168

end Host.Ts.Sim.Compose.VWFirst.VW15
