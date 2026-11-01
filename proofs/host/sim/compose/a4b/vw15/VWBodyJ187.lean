import host.sim.compose.a4b.vw15.VWBodyJ186
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl187 : Conv.NClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl187 (PRE_first_tail_x15_r0_body.cncl186 bodyNcl186)

theorem bodyClean187 : Conv.JClean (⟨21886, 18999, 2821743, 8075⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1807 :=
  PRE_first_tail_x15_r0_body.gjcl187 (PRE_first_tail_x15_r0_body.cjcl186 bodyClean186)

kernel_rfl bodyJsLe187 : Nat.ble PRE_first_tail_x15_r0_body.s1799.next PRE_first_tail_x15_r0_body.s1807.next = true
kernel_rfl bodyJsList187 : (PRE_first_tail_x15_r0_body.gjh187 ++ PRE_first_tail_x15_r0_body.cl187).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1807.next) PRE_first_tail_x15_r0_body.s1809) = true
theorem bodyJs187 : JsHeapAbove PRE_first_tail_x15_r0_body.s1807.next PRE_first_tail_x15_r0_body.s1809 :=
  JsHeapAbove.glueSite bodyJs186 (Nat.le_of_ble_eq_true bodyJsLe187) PRE_first_tail_x15_r0_body.gjk187 PRE_first_tail_x15_r0_body.gjbd187 PRE_first_tail_x15_r0_body.cheap187 PRE_first_tail_x15_r0_body.zclbd187 bodyJsList187

end Host.Ts.Sim.Compose.VWFirst.VW15
