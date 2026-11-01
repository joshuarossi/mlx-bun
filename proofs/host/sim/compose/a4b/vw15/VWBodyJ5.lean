import host.sim.compose.a4b.vw15.VWBodyJ4
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl5 : Conv.NClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl5 (PRE_first_tail_x15_r0_body.cncl4 bodyNcl4)

theorem bodyClean5 : Conv.JClean (⟨18293, 15385, 2678407, 268⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s57 :=
  PRE_first_tail_x15_r0_body.gjcl5 (PRE_first_tail_x15_r0_body.cjcl4 bodyClean4)

kernel_rfl bodyJsLe5 : Nat.ble PRE_first_tail_x15_r0_body.s53.next PRE_first_tail_x15_r0_body.s57.next = true
kernel_rfl bodyJsList5 : (PRE_first_tail_x15_r0_body.gjh5 ++ PRE_first_tail_x15_r0_body.cl5).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s57.next) PRE_first_tail_x15_r0_body.s59) = true
theorem bodyJs5 : JsHeapAbove PRE_first_tail_x15_r0_body.s57.next PRE_first_tail_x15_r0_body.s59 :=
  JsHeapAbove.glueSite bodyJs4 (Nat.le_of_ble_eq_true bodyJsLe5) PRE_first_tail_x15_r0_body.gjk5 PRE_first_tail_x15_r0_body.gjbd5 PRE_first_tail_x15_r0_body.cheap5 PRE_first_tail_x15_r0_body.zclbd5 bodyJsList5

end Host.Ts.Sim.Compose.VWFirst.VW15
