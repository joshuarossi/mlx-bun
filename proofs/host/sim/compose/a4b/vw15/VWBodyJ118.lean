import host.sim.compose.a4b.vw15.VWBodyJ117
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl118 : Conv.NClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1145.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl118 (PRE_first_tail_x15_r0_body.cncl117 bodyNcl117)

theorem bodyClean118 : Conv.JClean (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1145 :=
  PRE_first_tail_x15_r0_body.gjcl118 (PRE_first_tail_x15_r0_body.cjcl117 bodyClean117)

kernel_rfl bodyJsLe118 : Nat.ble PRE_first_tail_x15_r0_body.s1137.next PRE_first_tail_x15_r0_body.s1145.next = true
kernel_rfl bodyJsList118 : (PRE_first_tail_x15_r0_body.gjh118 ++ PRE_first_tail_x15_r0_body.cl118).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1145.next) PRE_first_tail_x15_r0_body.s1147) = true
theorem bodyJs118 : JsHeapAbove PRE_first_tail_x15_r0_body.s1145.next PRE_first_tail_x15_r0_body.s1147 :=
  JsHeapAbove.glueSite bodyJs117 (Nat.le_of_ble_eq_true bodyJsLe118) PRE_first_tail_x15_r0_body.gjk118 PRE_first_tail_x15_r0_body.gjbd118 PRE_first_tail_x15_r0_body.cheap118 PRE_first_tail_x15_r0_body.zclbd118 bodyJsList118

end Host.Ts.Sim.Compose.VWFirst.VW15
