import host.sim.compose.a4b.vw15.VWBodyJ33
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl34 : Conv.NClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl34 (PRE_first_tail_x15_r0_body.cncl33 bodyNcl33)

theorem bodyClean34 : Conv.JClean (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s340 :=
  PRE_first_tail_x15_r0_body.gjcl34 (PRE_first_tail_x15_r0_body.cjcl33 bodyClean33)

kernel_rfl bodyJsLe34 : Nat.ble PRE_first_tail_x15_r0_body.s332.next PRE_first_tail_x15_r0_body.s340.next = true
kernel_rfl bodyJsList34 : (PRE_first_tail_x15_r0_body.gjh34 ++ PRE_first_tail_x15_r0_body.cl34).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s340.next) PRE_first_tail_x15_r0_body.s342) = true
theorem bodyJs34 : JsHeapAbove PRE_first_tail_x15_r0_body.s340.next PRE_first_tail_x15_r0_body.s342 :=
  JsHeapAbove.glueSite bodyJs33 (Nat.le_of_ble_eq_true bodyJsLe34) PRE_first_tail_x15_r0_body.gjk34 PRE_first_tail_x15_r0_body.gjbd34 PRE_first_tail_x15_r0_body.cheap34 PRE_first_tail_x15_r0_body.zclbd34 bodyJsList34

end Host.Ts.Sim.Compose.VWFirst.VW15
