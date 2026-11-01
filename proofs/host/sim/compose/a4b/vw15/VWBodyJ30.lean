import host.sim.compose.a4b.vw15.VWBodyJ29
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl30 : Conv.NClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl30 (PRE_first_tail_x15_r0_body.cncl29 bodyNcl29)

theorem bodyClean30 : Conv.JClean (⟨18802, 15878, 2698799, 1367⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s304 :=
  PRE_first_tail_x15_r0_body.gjcl30 (PRE_first_tail_x15_r0_body.cjcl29 bodyClean29)

kernel_rfl bodyJsLe30 : Nat.ble PRE_first_tail_x15_r0_body.s287.next PRE_first_tail_x15_r0_body.s304.next = true
kernel_rfl bodyJsList30 : (PRE_first_tail_x15_r0_body.gjh30 ++ PRE_first_tail_x15_r0_body.cl30).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s304.next) PRE_first_tail_x15_r0_body.s306) = true
theorem bodyJs30 : JsHeapAbove PRE_first_tail_x15_r0_body.s304.next PRE_first_tail_x15_r0_body.s306 :=
  JsHeapAbove.glueSite bodyJs29 (Nat.le_of_ble_eq_true bodyJsLe30) PRE_first_tail_x15_r0_body.gjk30 PRE_first_tail_x15_r0_body.gjbd30 PRE_first_tail_x15_r0_body.cheap30 PRE_first_tail_x15_r0_body.zclbd30 bodyJsList30

end Host.Ts.Sim.Compose.VWFirst.VW15
