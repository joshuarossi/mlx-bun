import host.sim.compose.a4b.vw15.VWBodyJ68
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl69 : Conv.NClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s677.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl69 (PRE_first_tail_x15_r0_body.cncl68 bodyNcl68)

theorem bodyClean69 : Conv.JClean (⟨19573, 16661, 2729580, 3039⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s677 :=
  PRE_first_tail_x15_r0_body.gjcl69 (PRE_first_tail_x15_r0_body.cjcl68 bodyClean68)

kernel_rfl bodyJsLe69 : Nat.ble PRE_first_tail_x15_r0_body.s661.next PRE_first_tail_x15_r0_body.s677.next = true
kernel_rfl bodyJsList69 : (PRE_first_tail_x15_r0_body.gjh69 ++ PRE_first_tail_x15_r0_body.cl69).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s677.next) PRE_first_tail_x15_r0_body.s679) = true
theorem bodyJs69 : JsHeapAbove PRE_first_tail_x15_r0_body.s677.next PRE_first_tail_x15_r0_body.s679 :=
  JsHeapAbove.glueSite bodyJs68 (Nat.le_of_ble_eq_true bodyJsLe69) PRE_first_tail_x15_r0_body.gjk69 PRE_first_tail_x15_r0_body.gjbd69 PRE_first_tail_x15_r0_body.cheap69 PRE_first_tail_x15_r0_body.zclbd69 bodyJsList69

end Host.Ts.Sim.Compose.VWFirst.VW15
