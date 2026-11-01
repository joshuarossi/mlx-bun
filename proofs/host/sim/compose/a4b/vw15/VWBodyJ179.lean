import host.sim.compose.a4b.vw15.VWBodyJ178
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl179 : Conv.NClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1724.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl179 (PRE_first_tail_x15_r0_body.cncl178 bodyNcl178)

theorem bodyClean179 : Conv.JClean (⟨21721, 18814, 2815229, 7705⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1724 :=
  PRE_first_tail_x15_r0_body.gjcl179 (PRE_first_tail_x15_r0_body.cjcl178 bodyClean178)

kernel_rfl bodyJsLe179 : Nat.ble PRE_first_tail_x15_r0_body.s1720.next PRE_first_tail_x15_r0_body.s1724.next = true
kernel_rfl bodyJsList179 : (PRE_first_tail_x15_r0_body.gjh179 ++ PRE_first_tail_x15_r0_body.cl179).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1724.next) PRE_first_tail_x15_r0_body.s1726) = true
theorem bodyJs179 : JsHeapAbove PRE_first_tail_x15_r0_body.s1724.next PRE_first_tail_x15_r0_body.s1726 :=
  JsHeapAbove.glueSite bodyJs178 (Nat.le_of_ble_eq_true bodyJsLe179) PRE_first_tail_x15_r0_body.gjk179 PRE_first_tail_x15_r0_body.gjbd179 PRE_first_tail_x15_r0_body.cheap179 PRE_first_tail_x15_r0_body.zclbd179 bodyJsList179

end Host.Ts.Sim.Compose.VWFirst.VW15
