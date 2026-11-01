import host.sim.compose.a4b.vw15.VWBodyJ47
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl48 : Conv.NClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s476.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl48 (PRE_first_tail_x15_r0_body.cncl47 bodyNcl47)

theorem bodyClean48 : Conv.JClean (⟨19160, 16226, 2713123, 2135⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s476 :=
  PRE_first_tail_x15_r0_body.gjcl48 (PRE_first_tail_x15_r0_body.cjcl47 bodyClean47)

kernel_rfl bodyJsLe48 : Nat.ble PRE_first_tail_x15_r0_body.s459.next PRE_first_tail_x15_r0_body.s476.next = true
kernel_rfl bodyJsList48 : (PRE_first_tail_x15_r0_body.gjh48 ++ PRE_first_tail_x15_r0_body.cl48).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s476.next) PRE_first_tail_x15_r0_body.s478) = true
theorem bodyJs48 : JsHeapAbove PRE_first_tail_x15_r0_body.s476.next PRE_first_tail_x15_r0_body.s478 :=
  JsHeapAbove.glueSite bodyJs47 (Nat.le_of_ble_eq_true bodyJsLe48) PRE_first_tail_x15_r0_body.gjk48 PRE_first_tail_x15_r0_body.gjbd48 PRE_first_tail_x15_r0_body.cheap48 PRE_first_tail_x15_r0_body.zclbd48 bodyJsList48

end Host.Ts.Sim.Compose.VWFirst.VW15
