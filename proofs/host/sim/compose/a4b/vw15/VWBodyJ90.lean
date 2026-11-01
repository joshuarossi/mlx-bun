import host.sim.compose.a4b.vw15.VWBodyJ89
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl90 : Conv.NClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s879.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl90 (PRE_first_tail_x15_r0_body.cncl89 bodyNcl89)

theorem bodyClean90 : Conv.JClean (⟨19982, 17063, 2745887, 3932⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s879 :=
  PRE_first_tail_x15_r0_body.gjcl90 (PRE_first_tail_x15_r0_body.cjcl89 bodyClean89)

kernel_rfl bodyJsLe90 : Nat.ble PRE_first_tail_x15_r0_body.s862.next PRE_first_tail_x15_r0_body.s879.next = true
kernel_rfl bodyJsList90 : (PRE_first_tail_x15_r0_body.gjh90 ++ PRE_first_tail_x15_r0_body.cl90).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s879.next) PRE_first_tail_x15_r0_body.s881) = true
theorem bodyJs90 : JsHeapAbove PRE_first_tail_x15_r0_body.s879.next PRE_first_tail_x15_r0_body.s881 :=
  JsHeapAbove.glueSite bodyJs89 (Nat.le_of_ble_eq_true bodyJsLe90) PRE_first_tail_x15_r0_body.gjk90 PRE_first_tail_x15_r0_body.gjbd90 PRE_first_tail_x15_r0_body.cheap90 PRE_first_tail_x15_r0_body.zclbd90 bodyJsList90

end Host.Ts.Sim.Compose.VWFirst.VW15
