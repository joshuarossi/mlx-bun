import host.sim.compose.a4b.vw15.VWBodyJ50
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl51 : Conv.NClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s505.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl51 (PRE_first_tail_x15_r0_body.cncl50 bodyNcl50)

theorem bodyClean51 : Conv.JClean (⟨19217, 16289, 2715383, 2264⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s505 :=
  PRE_first_tail_x15_r0_body.gjcl51 (PRE_first_tail_x15_r0_body.cjcl50 bodyClean50)

kernel_rfl bodyJsLe51 : Nat.ble PRE_first_tail_x15_r0_body.s488.next PRE_first_tail_x15_r0_body.s505.next = true
kernel_rfl bodyJsList51 : (PRE_first_tail_x15_r0_body.gjh51 ++ PRE_first_tail_x15_r0_body.cl51).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s505.next) PRE_first_tail_x15_r0_body.s507) = true
theorem bodyJs51 : JsHeapAbove PRE_first_tail_x15_r0_body.s505.next PRE_first_tail_x15_r0_body.s507 :=
  JsHeapAbove.glueSite bodyJs50 (Nat.le_of_ble_eq_true bodyJsLe51) PRE_first_tail_x15_r0_body.gjk51 PRE_first_tail_x15_r0_body.gjbd51 PRE_first_tail_x15_r0_body.cheap51 PRE_first_tail_x15_r0_body.zclbd51 bodyJsList51

end Host.Ts.Sim.Compose.VWFirst.VW15
