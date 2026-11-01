import host.sim.compose.a4b.vw15.VWBodyJ88
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl89 : Conv.NClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl89 (PRE_first_tail_x15_r0_body.cncl88 bodyNcl88)

theorem bodyClean89 : Conv.JClean (⟨19948, 17044, 2744411, 3859⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s862 :=
  PRE_first_tail_x15_r0_body.gjcl89 (PRE_first_tail_x15_r0_body.cjcl88 bodyClean88)

kernel_rfl bodyJsLe89 : Nat.ble PRE_first_tail_x15_r0_body.s858.next PRE_first_tail_x15_r0_body.s862.next = true
kernel_rfl bodyJsList89 : (PRE_first_tail_x15_r0_body.gjh89 ++ PRE_first_tail_x15_r0_body.cl89).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s862.next) PRE_first_tail_x15_r0_body.s864) = true
theorem bodyJs89 : JsHeapAbove PRE_first_tail_x15_r0_body.s862.next PRE_first_tail_x15_r0_body.s864 :=
  JsHeapAbove.glueSite bodyJs88 (Nat.le_of_ble_eq_true bodyJsLe89) PRE_first_tail_x15_r0_body.gjk89 PRE_first_tail_x15_r0_body.gjbd89 PRE_first_tail_x15_r0_body.cheap89 PRE_first_tail_x15_r0_body.zclbd89 bodyJsList89

end Host.Ts.Sim.Compose.VWFirst.VW15
