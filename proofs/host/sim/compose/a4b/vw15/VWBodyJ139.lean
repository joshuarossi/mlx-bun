import host.sim.compose.a4b.vw15.VWBodyJ138
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl139 : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl139 (PRE_first_tail_x15_r0_body.cncl138 bodyNcl138)

theorem bodyClean139 : Conv.JClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1347 :=
  PRE_first_tail_x15_r0_body.gjcl139 (PRE_first_tail_x15_r0_body.cjcl138 bodyClean138)

kernel_rfl bodyJsLe139 : Nat.ble PRE_first_tail_x15_r0_body.s1339.next PRE_first_tail_x15_r0_body.s1347.next = true
kernel_rfl bodyJsList139 : (PRE_first_tail_x15_r0_body.gjh139 ++ PRE_first_tail_x15_r0_body.cl139).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1347.next) PRE_first_tail_x15_r0_body.s1349) = true
theorem bodyJs139 : JsHeapAbove PRE_first_tail_x15_r0_body.s1347.next PRE_first_tail_x15_r0_body.s1349 :=
  JsHeapAbove.glueSite bodyJs138 (Nat.le_of_ble_eq_true bodyJsLe139) PRE_first_tail_x15_r0_body.gjk139 PRE_first_tail_x15_r0_body.gjbd139 PRE_first_tail_x15_r0_body.cheap139 PRE_first_tail_x15_r0_body.zclbd139 bodyJsList139

end Host.Ts.Sim.Compose.VWFirst.VW15
