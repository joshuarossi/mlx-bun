import host.sim.compose.a4b.vw15.VWBodyJ34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl35 : Conv.NClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s344.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl35 (PRE_first_tail_x15_r0_body.cncl34 bodyNcl34)

theorem bodyClean35 : Conv.JClean (⟨18889, 15970, 2702205, 1549⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s344 :=
  PRE_first_tail_x15_r0_body.gjcl35 (PRE_first_tail_x15_r0_body.cjcl34 bodyClean34)

kernel_rfl bodyJsLe35 : Nat.ble PRE_first_tail_x15_r0_body.s340.next PRE_first_tail_x15_r0_body.s344.next = true
kernel_rfl bodyJsList35 : (PRE_first_tail_x15_r0_body.gjh35 ++ PRE_first_tail_x15_r0_body.cl35).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s344.next) PRE_first_tail_x15_r0_body.s346) = true
theorem bodyJs35 : JsHeapAbove PRE_first_tail_x15_r0_body.s344.next PRE_first_tail_x15_r0_body.s346 :=
  JsHeapAbove.glueSite bodyJs34 (Nat.le_of_ble_eq_true bodyJsLe35) PRE_first_tail_x15_r0_body.gjk35 PRE_first_tail_x15_r0_body.gjbd35 PRE_first_tail_x15_r0_body.cheap35 PRE_first_tail_x15_r0_body.zclbd35 bodyJsList35

end Host.Ts.Sim.Compose.VWFirst.VW15
