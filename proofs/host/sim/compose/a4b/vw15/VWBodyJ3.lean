import host.sim.compose.a4b.vw15.VWBodyJ2
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl3 : Conv.NClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s45.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl3 (PRE_first_tail_x15_r0_body.cncl2 bodyNcl2)

theorem bodyClean3 : Conv.JClean (⟨18270, 15341, 2677623, 212⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s45 :=
  PRE_first_tail_x15_r0_body.gjcl3 (PRE_first_tail_x15_r0_body.cjcl2 bodyClean2)

kernel_rfl bodyJsLe3 : Nat.ble PRE_first_tail_x15_r0_body.s28.next PRE_first_tail_x15_r0_body.s45.next = true
kernel_rfl bodyJsList3 : (PRE_first_tail_x15_r0_body.gjh3 ++ PRE_first_tail_x15_r0_body.cl3).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s45.next) PRE_first_tail_x15_r0_body.s47) = true
theorem bodyJs3 : JsHeapAbove PRE_first_tail_x15_r0_body.s45.next PRE_first_tail_x15_r0_body.s47 :=
  JsHeapAbove.glueSite bodyJs2 (Nat.le_of_ble_eq_true bodyJsLe3) PRE_first_tail_x15_r0_body.gjk3 PRE_first_tail_x15_r0_body.gjbd3 PRE_first_tail_x15_r0_body.cheap3 PRE_first_tail_x15_r0_body.zclbd3 bodyJsList3

end Host.Ts.Sim.Compose.VWFirst.VW15
