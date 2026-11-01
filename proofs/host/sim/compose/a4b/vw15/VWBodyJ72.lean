import host.sim.compose.a4b.vw15.VWBodyJ71
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl72 : Conv.NClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl72 (PRE_first_tail_x15_r0_body.cncl71 bodyNcl71)

theorem bodyClean72 : Conv.JClean (⟨19632, 16700, 2731959, 3161⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s706 :=
  PRE_first_tail_x15_r0_body.gjcl72 (PRE_first_tail_x15_r0_body.cjcl71 bodyClean71)

kernel_rfl bodyJsLe72 : Nat.ble PRE_first_tail_x15_r0_body.s689.next PRE_first_tail_x15_r0_body.s706.next = true
kernel_rfl bodyJsList72 : (PRE_first_tail_x15_r0_body.gjh72 ++ PRE_first_tail_x15_r0_body.cl72).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s706.next) PRE_first_tail_x15_r0_body.s708) = true
theorem bodyJs72 : JsHeapAbove PRE_first_tail_x15_r0_body.s706.next PRE_first_tail_x15_r0_body.s708 :=
  JsHeapAbove.glueSite bodyJs71 (Nat.le_of_ble_eq_true bodyJsLe72) PRE_first_tail_x15_r0_body.gjk72 PRE_first_tail_x15_r0_body.gjbd72 PRE_first_tail_x15_r0_body.cheap72 PRE_first_tail_x15_r0_body.zclbd72 bodyJsList72

end Host.Ts.Sim.Compose.VWFirst.VW15
