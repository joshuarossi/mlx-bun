import host.sim.compose.a4b.vw15.VWBodyJ156
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl157 : Conv.NClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1519.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl157 (PRE_first_tail_x15_r0_body.cncl156 bodyNcl156)

theorem bodyClean157 : Conv.JClean (⟨21300, 18399, 2798375, 6791⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1519 :=
  PRE_first_tail_x15_r0_body.gjcl157 (PRE_first_tail_x15_r0_body.cjcl156 bodyClean156)

kernel_rfl bodyJsLe157 : Nat.ble PRE_first_tail_x15_r0_body.s1511.next PRE_first_tail_x15_r0_body.s1519.next = true
kernel_rfl bodyJsList157 : (PRE_first_tail_x15_r0_body.gjh157 ++ PRE_first_tail_x15_r0_body.cl157).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1519.next) PRE_first_tail_x15_r0_body.s1521) = true
theorem bodyJs157 : JsHeapAbove PRE_first_tail_x15_r0_body.s1519.next PRE_first_tail_x15_r0_body.s1521 :=
  JsHeapAbove.glueSite bodyJs156 (Nat.le_of_ble_eq_true bodyJsLe157) PRE_first_tail_x15_r0_body.gjk157 PRE_first_tail_x15_r0_body.gjbd157 PRE_first_tail_x15_r0_body.cheap157 PRE_first_tail_x15_r0_body.zclbd157 bodyJsList157

end Host.Ts.Sim.Compose.VWFirst.VW15
