import host.sim.compose.a4b.vw15.VWBodyJ147
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl148 : Conv.NClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl148 (PRE_first_tail_x15_r0_body.cncl147 bodyNcl147)

theorem bodyClean148 : Conv.JClean (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1433 :=
  PRE_first_tail_x15_r0_body.gjcl148 (PRE_first_tail_x15_r0_body.cjcl147 bodyClean147)

kernel_rfl bodyJsLe148 : Nat.ble PRE_first_tail_x15_r0_body.s1425.next PRE_first_tail_x15_r0_body.s1433.next = true
kernel_rfl bodyJsList148 : (PRE_first_tail_x15_r0_body.gjh148 ++ PRE_first_tail_x15_r0_body.cl148).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1433.next) PRE_first_tail_x15_r0_body.s1435) = true
theorem bodyJs148 : JsHeapAbove PRE_first_tail_x15_r0_body.s1433.next PRE_first_tail_x15_r0_body.s1435 :=
  JsHeapAbove.glueSite bodyJs147 (Nat.le_of_ble_eq_true bodyJsLe148) PRE_first_tail_x15_r0_body.gjk148 PRE_first_tail_x15_r0_body.gjbd148 PRE_first_tail_x15_r0_body.cheap148 PRE_first_tail_x15_r0_body.zclbd148 bodyJsList148

end Host.Ts.Sim.Compose.VWFirst.VW15
