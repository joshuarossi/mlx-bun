import host.sim.compose.a4b.vw15.VWBodyJ51
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl52 : Conv.NClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl52 (PRE_first_tail_x15_r0_body.cncl51 bodyNcl51)

theorem bodyClean52 : Conv.JClean (⟨19233, 16329, 2715879, 2303⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s513 :=
  PRE_first_tail_x15_r0_body.gjcl52 (PRE_first_tail_x15_r0_body.cjcl51 bodyClean51)

kernel_rfl bodyJsLe52 : Nat.ble PRE_first_tail_x15_r0_body.s505.next PRE_first_tail_x15_r0_body.s513.next = true
kernel_rfl bodyJsList52 : (PRE_first_tail_x15_r0_body.gjh52 ++ PRE_first_tail_x15_r0_body.cl52).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s513.next) PRE_first_tail_x15_r0_body.s515) = true
theorem bodyJs52 : JsHeapAbove PRE_first_tail_x15_r0_body.s513.next PRE_first_tail_x15_r0_body.s515 :=
  JsHeapAbove.glueSite bodyJs51 (Nat.le_of_ble_eq_true bodyJsLe52) PRE_first_tail_x15_r0_body.gjk52 PRE_first_tail_x15_r0_body.gjbd52 PRE_first_tail_x15_r0_body.cheap52 PRE_first_tail_x15_r0_body.zclbd52 bodyJsList52

end Host.Ts.Sim.Compose.VWFirst.VW15
