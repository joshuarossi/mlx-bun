import host.sim.compose.a4b.vw15.VWBodyJ16
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl17 : Conv.NClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s172.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl17 (PRE_first_tail_x15_r0_body.cncl16 bodyNcl16)

theorem bodyClean17 : Conv.JClean (⟨18532, 15622, 2687915, 781⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s172 :=
  PRE_first_tail_x15_r0_body.gjcl17 (PRE_first_tail_x15_r0_body.cjcl16 bodyClean16)

kernel_rfl bodyJsLe17 : Nat.ble PRE_first_tail_x15_r0_body.s168.next PRE_first_tail_x15_r0_body.s172.next = true
kernel_rfl bodyJsList17 : (PRE_first_tail_x15_r0_body.gjh17 ++ PRE_first_tail_x15_r0_body.cl17).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s172.next) PRE_first_tail_x15_r0_body.s174) = true
theorem bodyJs17 : JsHeapAbove PRE_first_tail_x15_r0_body.s172.next PRE_first_tail_x15_r0_body.s174 :=
  JsHeapAbove.glueSite bodyJs16 (Nat.le_of_ble_eq_true bodyJsLe17) PRE_first_tail_x15_r0_body.gjk17 PRE_first_tail_x15_r0_body.gjbd17 PRE_first_tail_x15_r0_body.cheap17 PRE_first_tail_x15_r0_body.zclbd17 bodyJsList17

end Host.Ts.Sim.Compose.VWFirst.VW15
