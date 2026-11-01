import host.sim.compose.a4b.vw15.VWBodyJ81
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl82 : Conv.NClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s800.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl82 (PRE_first_tail_x15_r0_body.cncl81 bodyNcl81)

theorem bodyClean82 : Conv.JClean (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s800 :=
  PRE_first_tail_x15_r0_body.gjcl82 (PRE_first_tail_x15_r0_body.cjcl81 bodyClean81)

kernel_rfl bodyJsLe82 : Nat.ble PRE_first_tail_x15_r0_body.s792.next PRE_first_tail_x15_r0_body.s800.next = true
kernel_rfl bodyJsList82 : (PRE_first_tail_x15_r0_body.gjh82 ++ PRE_first_tail_x15_r0_body.cl82).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s800.next) PRE_first_tail_x15_r0_body.s802) = true
theorem bodyJs82 : JsHeapAbove PRE_first_tail_x15_r0_body.s800.next PRE_first_tail_x15_r0_body.s802 :=
  JsHeapAbove.glueSite bodyJs81 (Nat.le_of_ble_eq_true bodyJsLe82) PRE_first_tail_x15_r0_body.gjk82 PRE_first_tail_x15_r0_body.gjbd82 PRE_first_tail_x15_r0_body.cheap82 PRE_first_tail_x15_r0_body.zclbd82 bodyJsList82

end Host.Ts.Sim.Compose.VWFirst.VW15
