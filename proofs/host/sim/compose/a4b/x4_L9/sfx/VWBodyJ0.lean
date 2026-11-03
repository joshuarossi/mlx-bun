import host.sim.compose.a4b.x4_L9.sfx.VWBodyChain
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B3
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl0 : Conv.NClean (⟨22174, 19265, 2834708, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x4_L9_r0_suffix.s2.ffi).mlx :=
  PRE_first_tail_x4_L9_r0_suffix.gncl0 PRE_first_tail_x4_L9_r0_suffix.ncl0

theorem bodyClean0 : Conv.JClean (⟨22174, 19265, 2834708, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0_suffix.s2 :=
  PRE_first_tail_x4_L9_r0_suffix.gjcl0 bodyStartClean

kernel_rfl bodyJsLe0 : Nat.ble PRE_first_tail_x4_L9_r0_body.s1416.next PRE_first_tail_x4_L9_r0_suffix.s2.next = true
kernel_rfl bodyJsList0 : (PRE_first_tail_x4_L9_r0_suffix.gjh0 ++ PRE_first_tail_x4_L9_r0_suffix.cl0).all (noBigAtP (jsAboveB PRE_first_tail_x4_L9_r0_suffix.s2.next) PRE_first_tail_x4_L9_r0_suffix.s4) = true
theorem bodyJs0 : JsHeapAbove PRE_first_tail_x4_L9_r0_suffix.s2.next PRE_first_tail_x4_L9_r0_suffix.s4 :=
  JsHeapAbove.glueSite bodyStartJs (Nat.le_of_ble_eq_true bodyJsLe0) PRE_first_tail_x4_L9_r0_suffix.gjk0 PRE_first_tail_x4_L9_r0_suffix.gjbd0 PRE_first_tail_x4_L9_r0_suffix.cheap0 PRE_first_tail_x4_L9_r0_suffix.zclbd0 bodyJsList0

end Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx
