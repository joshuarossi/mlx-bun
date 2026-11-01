import host.sim.compose.a4b.vw15.VWBodyJ146
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl147 : Conv.NClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl147 (PRE_first_tail_x15_r0_body.cncl146 bodyNcl146)

theorem bodyClean147 : Conv.JClean (⟨21105, 18185, 2790719, 6368⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1425 :=
  PRE_first_tail_x15_r0_body.gjcl147 (PRE_first_tail_x15_r0_body.cjcl146 bodyClean146)

kernel_rfl bodyJsLe147 : Nat.ble PRE_first_tail_x15_r0_body.s1408.next PRE_first_tail_x15_r0_body.s1425.next = true
kernel_rfl bodyJsList147 : (PRE_first_tail_x15_r0_body.gjh147 ++ PRE_first_tail_x15_r0_body.cl147).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1425.next) PRE_first_tail_x15_r0_body.s1427) = true
theorem bodyJs147 : JsHeapAbove PRE_first_tail_x15_r0_body.s1425.next PRE_first_tail_x15_r0_body.s1427 :=
  JsHeapAbove.glueSite bodyJs146 (Nat.le_of_ble_eq_true bodyJsLe147) PRE_first_tail_x15_r0_body.gjk147 PRE_first_tail_x15_r0_body.gjbd147 PRE_first_tail_x15_r0_body.cheap147 PRE_first_tail_x15_r0_body.zclbd147 bodyJsList147

end Host.Ts.Sim.Compose.VWFirst.VW15
