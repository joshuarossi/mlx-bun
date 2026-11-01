import host.sim.compose.a4b.vw15.VWBodyJ177
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl178 : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1720.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl178 (PRE_first_tail_x15_r0_body.cncl177 bodyNcl177)

theorem bodyClean178 : Conv.JClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1720 :=
  PRE_first_tail_x15_r0_body.gjcl178 (PRE_first_tail_x15_r0_body.cjcl177 bodyClean177)

kernel_rfl bodyJsLe178 : Nat.ble PRE_first_tail_x15_r0_body.s1712.next PRE_first_tail_x15_r0_body.s1720.next = true
kernel_rfl bodyJsList178 : (PRE_first_tail_x15_r0_body.gjh178 ++ PRE_first_tail_x15_r0_body.cl178).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1720.next) PRE_first_tail_x15_r0_body.s1722) = true
theorem bodyJs178 : JsHeapAbove PRE_first_tail_x15_r0_body.s1720.next PRE_first_tail_x15_r0_body.s1722 :=
  JsHeapAbove.glueSite bodyJs177 (Nat.le_of_ble_eq_true bodyJsLe178) PRE_first_tail_x15_r0_body.gjk178 PRE_first_tail_x15_r0_body.gjbd178 PRE_first_tail_x15_r0_body.cheap178 PRE_first_tail_x15_r0_body.zclbd178 bodyJsList178

end Host.Ts.Sim.Compose.VWFirst.VW15
