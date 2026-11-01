import host.sim.compose.a4b.vw15.VWBodyJ70
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl71 : Conv.NClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl71 (PRE_first_tail_x15_r0_body.cncl70 bodyNcl70)

theorem bodyClean71 : Conv.JClean (⟨19597, 16681, 2730465, 3088⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s689 :=
  PRE_first_tail_x15_r0_body.gjcl71 (PRE_first_tail_x15_r0_body.cjcl70 bodyClean70)

kernel_rfl bodyJsLe71 : Nat.ble PRE_first_tail_x15_r0_body.s685.next PRE_first_tail_x15_r0_body.s689.next = true
kernel_rfl bodyJsList71 : (PRE_first_tail_x15_r0_body.gjh71 ++ PRE_first_tail_x15_r0_body.cl71).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s689.next) PRE_first_tail_x15_r0_body.s691) = true
theorem bodyJs71 : JsHeapAbove PRE_first_tail_x15_r0_body.s689.next PRE_first_tail_x15_r0_body.s691 :=
  JsHeapAbove.glueSite bodyJs70 (Nat.le_of_ble_eq_true bodyJsLe71) PRE_first_tail_x15_r0_body.gjk71 PRE_first_tail_x15_r0_body.gjbd71 PRE_first_tail_x15_r0_body.cheap71 PRE_first_tail_x15_r0_body.zclbd71 bodyJsList71

end Host.Ts.Sim.Compose.VWFirst.VW15
