import host.sim.compose.a4b.vw15.VWBodyJ83
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl84 : Conv.NClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s821.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl84 (PRE_first_tail_x15_r0_body.cncl83 bodyNcl83)

theorem bodyClean84 : Conv.JClean (⟨19868, 16937, 2741371, 3674⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s821 :=
  PRE_first_tail_x15_r0_body.gjcl84 (PRE_first_tail_x15_r0_body.cjcl83 bodyClean83)

kernel_rfl bodyJsLe84 : Nat.ble PRE_first_tail_x15_r0_body.s804.next PRE_first_tail_x15_r0_body.s821.next = true
kernel_rfl bodyJsList84 : (PRE_first_tail_x15_r0_body.gjh84 ++ PRE_first_tail_x15_r0_body.cl84).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s821.next) PRE_first_tail_x15_r0_body.s823) = true
theorem bodyJs84 : JsHeapAbove PRE_first_tail_x15_r0_body.s821.next PRE_first_tail_x15_r0_body.s823 :=
  JsHeapAbove.glueSite bodyJs83 (Nat.le_of_ble_eq_true bodyJsLe84) PRE_first_tail_x15_r0_body.gjk84 PRE_first_tail_x15_r0_body.gjbd84 PRE_first_tail_x15_r0_body.cheap84 PRE_first_tail_x15_r0_body.zclbd84 bodyJsList84

end Host.Ts.Sim.Compose.VWFirst.VW15
