import host.sim.compose.a4b.vw15.VWBodyJ159
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl160 : Conv.NClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1548.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl160 (PRE_first_tail_x15_r0_body.cncl159 bodyNcl159)

theorem bodyClean160 : Conv.JClean (⟨21357, 18462, 2800631, 6920⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1548 :=
  PRE_first_tail_x15_r0_body.gjcl160 (PRE_first_tail_x15_r0_body.cjcl159 bodyClean159)

kernel_rfl bodyJsLe160 : Nat.ble PRE_first_tail_x15_r0_body.s1540.next PRE_first_tail_x15_r0_body.s1548.next = true
kernel_rfl bodyJsList160 : (PRE_first_tail_x15_r0_body.gjh160 ++ PRE_first_tail_x15_r0_body.cl160).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1548.next) PRE_first_tail_x15_r0_body.s1550) = true
theorem bodyJs160 : JsHeapAbove PRE_first_tail_x15_r0_body.s1548.next PRE_first_tail_x15_r0_body.s1550 :=
  JsHeapAbove.glueSite bodyJs159 (Nat.le_of_ble_eq_true bodyJsLe160) PRE_first_tail_x15_r0_body.gjk160 PRE_first_tail_x15_r0_body.gjbd160 PRE_first_tail_x15_r0_body.cheap160 PRE_first_tail_x15_r0_body.zclbd160 bodyJsList160

end Host.Ts.Sim.Compose.VWFirst.VW15
