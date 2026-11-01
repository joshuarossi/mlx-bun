import host.sim.compose.a4b.vw15.VWBodyJ150
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl151 : Conv.NClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1462.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl151 (PRE_first_tail_x15_r0_body.cncl150 bodyNcl150)

theorem bodyClean151 : Conv.JClean (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1462 :=
  PRE_first_tail_x15_r0_body.gjcl151 (PRE_first_tail_x15_r0_body.cjcl150 bodyClean150)

kernel_rfl bodyJsLe151 : Nat.ble PRE_first_tail_x15_r0_body.s1454.next PRE_first_tail_x15_r0_body.s1462.next = true
kernel_rfl bodyJsList151 : (PRE_first_tail_x15_r0_body.gjh151 ++ PRE_first_tail_x15_r0_body.cl151).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1462.next) PRE_first_tail_x15_r0_body.s1464) = true
theorem bodyJs151 : JsHeapAbove PRE_first_tail_x15_r0_body.s1462.next PRE_first_tail_x15_r0_body.s1464 :=
  JsHeapAbove.glueSite bodyJs150 (Nat.le_of_ble_eq_true bodyJsLe151) PRE_first_tail_x15_r0_body.gjk151 PRE_first_tail_x15_r0_body.gjbd151 PRE_first_tail_x15_r0_body.cheap151 PRE_first_tail_x15_r0_body.zclbd151 bodyJsList151

end Host.Ts.Sim.Compose.VWFirst.VW15
