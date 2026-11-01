import host.sim.compose.a4b.vw15.VWBodyJ32
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl33 : Conv.NClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s332.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl33 (PRE_first_tail_x15_r0_body.cncl32 bodyNcl32)

theorem bodyClean33 : Conv.JClean (⟨18865, 15950, 2701320, 1500⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s332 :=
  PRE_first_tail_x15_r0_body.gjcl33 (PRE_first_tail_x15_r0_body.cjcl32 bodyClean32)

kernel_rfl bodyJsLe33 : Nat.ble PRE_first_tail_x15_r0_body.s316.next PRE_first_tail_x15_r0_body.s332.next = true
kernel_rfl bodyJsList33 : (PRE_first_tail_x15_r0_body.gjh33 ++ PRE_first_tail_x15_r0_body.cl33).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s332.next) PRE_first_tail_x15_r0_body.s334) = true
theorem bodyJs33 : JsHeapAbove PRE_first_tail_x15_r0_body.s332.next PRE_first_tail_x15_r0_body.s334 :=
  JsHeapAbove.glueSite bodyJs32 (Nat.le_of_ble_eq_true bodyJsLe33) PRE_first_tail_x15_r0_body.gjk33 PRE_first_tail_x15_r0_body.gjbd33 PRE_first_tail_x15_r0_body.cheap33 PRE_first_tail_x15_r0_body.zclbd33 bodyJsList33

end Host.Ts.Sim.Compose.VWFirst.VW15
