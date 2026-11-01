import host.sim.compose.a4b.vw15.VWBodyJ145
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl146 : Conv.NClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl146 (PRE_first_tail_x15_r0_body.cncl145 bodyNcl145)

theorem bodyClean146 : Conv.JClean (⟨21071, 18166, 2789243, 6295⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1408 :=
  PRE_first_tail_x15_r0_body.gjcl146 (PRE_first_tail_x15_r0_body.cjcl145 bodyClean145)

kernel_rfl bodyJsLe146 : Nat.ble PRE_first_tail_x15_r0_body.s1404.next PRE_first_tail_x15_r0_body.s1408.next = true
kernel_rfl bodyJsList146 : (PRE_first_tail_x15_r0_body.gjh146 ++ PRE_first_tail_x15_r0_body.cl146).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1408.next) PRE_first_tail_x15_r0_body.s1410) = true
theorem bodyJs146 : JsHeapAbove PRE_first_tail_x15_r0_body.s1408.next PRE_first_tail_x15_r0_body.s1410 :=
  JsHeapAbove.glueSite bodyJs145 (Nat.le_of_ble_eq_true bodyJsLe146) PRE_first_tail_x15_r0_body.gjk146 PRE_first_tail_x15_r0_body.gjbd146 PRE_first_tail_x15_r0_body.cheap146 PRE_first_tail_x15_r0_body.zclbd146 bodyJsList146

end Host.Ts.Sim.Compose.VWFirst.VW15
