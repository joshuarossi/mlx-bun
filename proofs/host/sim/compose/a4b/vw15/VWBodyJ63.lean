import host.sim.compose.a4b.vw15.VWBodyJ62
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl63 : Conv.NClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s620.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl63 (PRE_first_tail_x15_r0_body.cncl62 bodyNcl62)

theorem bodyClean63 : Conv.JClean (⟨19453, 16526, 2724803, 2777⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s620 :=
  PRE_first_tail_x15_r0_body.gjcl63 (PRE_first_tail_x15_r0_body.cjcl62 bodyClean62)

kernel_rfl bodyJsLe63 : Nat.ble PRE_first_tail_x15_r0_body.s603.next PRE_first_tail_x15_r0_body.s620.next = true
kernel_rfl bodyJsList63 : (PRE_first_tail_x15_r0_body.gjh63 ++ PRE_first_tail_x15_r0_body.cl63).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s620.next) PRE_first_tail_x15_r0_body.s622) = true
theorem bodyJs63 : JsHeapAbove PRE_first_tail_x15_r0_body.s620.next PRE_first_tail_x15_r0_body.s622 :=
  JsHeapAbove.glueSite bodyJs62 (Nat.le_of_ble_eq_true bodyJsLe63) PRE_first_tail_x15_r0_body.gjk63 PRE_first_tail_x15_r0_body.gjbd63 PRE_first_tail_x15_r0_body.cheap63 PRE_first_tail_x15_r0_body.zclbd63 bodyJsList63

end Host.Ts.Sim.Compose.VWFirst.VW15
