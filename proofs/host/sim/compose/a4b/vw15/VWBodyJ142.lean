import host.sim.compose.a4b.vw15.VWBodyJ141
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl142 : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl142 (PRE_first_tail_x15_r0_body.cncl141 bodyNcl141)

theorem bodyClean142 : Conv.JClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1375 :=
  PRE_first_tail_x15_r0_body.gjcl142 (PRE_first_tail_x15_r0_body.cjcl141 bodyClean141)

kernel_rfl bodyJsLe142 : Nat.ble PRE_first_tail_x15_r0_body.s1367.next PRE_first_tail_x15_r0_body.s1375.next = true
kernel_rfl bodyJsList142 : (PRE_first_tail_x15_r0_body.gjh142 ++ PRE_first_tail_x15_r0_body.cl142).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1375.next) PRE_first_tail_x15_r0_body.s1377) = true
theorem bodyJs142 : JsHeapAbove PRE_first_tail_x15_r0_body.s1375.next PRE_first_tail_x15_r0_body.s1377 :=
  JsHeapAbove.glueSite bodyJs141 (Nat.le_of_ble_eq_true bodyJsLe142) PRE_first_tail_x15_r0_body.gjk142 PRE_first_tail_x15_r0_body.gjbd142 PRE_first_tail_x15_r0_body.cheap142 PRE_first_tail_x15_r0_body.zclbd142 bodyJsList142

end Host.Ts.Sim.Compose.VWFirst.VW15
