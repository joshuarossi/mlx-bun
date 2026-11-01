import host.sim.compose.a4b.vw15.VWBodyJ25
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl26 : Conv.NClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s258.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl26 (PRE_first_tail_x15_r0_body.cncl25 bodyNcl25)

theorem bodyClean26 : Conv.JClean (⟨18711, 15796, 2695071, 1165⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s258 :=
  PRE_first_tail_x15_r0_body.gjcl26 (PRE_first_tail_x15_r0_body.cjcl25 bodyClean25)

kernel_rfl bodyJsLe26 : Nat.ble PRE_first_tail_x15_r0_body.s254.next PRE_first_tail_x15_r0_body.s258.next = true
kernel_rfl bodyJsList26 : (PRE_first_tail_x15_r0_body.gjh26 ++ PRE_first_tail_x15_r0_body.cl26).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s258.next) PRE_first_tail_x15_r0_body.s260) = true
theorem bodyJs26 : JsHeapAbove PRE_first_tail_x15_r0_body.s258.next PRE_first_tail_x15_r0_body.s260 :=
  JsHeapAbove.glueSite bodyJs25 (Nat.le_of_ble_eq_true bodyJsLe26) PRE_first_tail_x15_r0_body.gjk26 PRE_first_tail_x15_r0_body.gjbd26 PRE_first_tail_x15_r0_body.cheap26 PRE_first_tail_x15_r0_body.zclbd26 bodyJsList26

end Host.Ts.Sim.Compose.VWFirst.VW15
