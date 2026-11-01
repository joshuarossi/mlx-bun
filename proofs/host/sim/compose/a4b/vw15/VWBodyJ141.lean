import host.sim.compose.a4b.vw15.VWBodyJ140
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl141 : Conv.NClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl141 (PRE_first_tail_x15_r0_body.cncl140 bodyNcl140)

theorem bodyClean141 : Conv.JClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1367 :=
  PRE_first_tail_x15_r0_body.gjcl141 (PRE_first_tail_x15_r0_body.cjcl140 bodyClean140)

kernel_rfl bodyJsLe141 : Nat.ble PRE_first_tail_x15_r0_body.s1351.next PRE_first_tail_x15_r0_body.s1367.next = true
kernel_rfl bodyJsList141 : (PRE_first_tail_x15_r0_body.gjh141 ++ PRE_first_tail_x15_r0_body.cl141).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1367.next) PRE_first_tail_x15_r0_body.s1369) = true
theorem bodyJs141 : JsHeapAbove PRE_first_tail_x15_r0_body.s1367.next PRE_first_tail_x15_r0_body.s1369 :=
  JsHeapAbove.glueSite bodyJs140 (Nat.le_of_ble_eq_true bodyJsLe141) PRE_first_tail_x15_r0_body.gjk141 PRE_first_tail_x15_r0_body.gjbd141 PRE_first_tail_x15_r0_body.cheap141 PRE_first_tail_x15_r0_body.zclbd141 bodyJsList141

end Host.Ts.Sim.Compose.VWFirst.VW15
