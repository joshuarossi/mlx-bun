import host.sim.compose.a4b.vw15.VWBodyJ151
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl152 : Conv.NClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1466.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl152 (PRE_first_tail_x15_r0_body.cncl151 bodyNcl151)

theorem bodyClean152 : Conv.JClean (⟨21185, 18292, 2793763, 6553⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1466 :=
  PRE_first_tail_x15_r0_body.gjcl152 (PRE_first_tail_x15_r0_body.cjcl151 bodyClean151)

kernel_rfl bodyJsLe152 : Nat.ble PRE_first_tail_x15_r0_body.s1462.next PRE_first_tail_x15_r0_body.s1466.next = true
kernel_rfl bodyJsList152 : (PRE_first_tail_x15_r0_body.gjh152 ++ PRE_first_tail_x15_r0_body.cl152).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1466.next) PRE_first_tail_x15_r0_body.s1468) = true
theorem bodyJs152 : JsHeapAbove PRE_first_tail_x15_r0_body.s1466.next PRE_first_tail_x15_r0_body.s1468 :=
  JsHeapAbove.glueSite bodyJs151 (Nat.le_of_ble_eq_true bodyJsLe152) PRE_first_tail_x15_r0_body.gjk152 PRE_first_tail_x15_r0_body.gjbd152 PRE_first_tail_x15_r0_body.cheap152 PRE_first_tail_x15_r0_body.zclbd152 bodyJsList152

end Host.Ts.Sim.Compose.VWFirst.VW15
