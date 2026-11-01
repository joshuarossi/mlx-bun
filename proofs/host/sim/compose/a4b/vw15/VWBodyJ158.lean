import host.sim.compose.a4b.vw15.VWBodyJ157
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl158 : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1523.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl158 (PRE_first_tail_x15_r0_body.cncl157 bodyNcl157)

theorem bodyClean158 : Conv.JClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1523 :=
  PRE_first_tail_x15_r0_body.gjcl158 (PRE_first_tail_x15_r0_body.cjcl157 bodyClean157)

kernel_rfl bodyJsLe158 : Nat.ble PRE_first_tail_x15_r0_body.s1519.next PRE_first_tail_x15_r0_body.s1523.next = true
kernel_rfl bodyJsList158 : (PRE_first_tail_x15_r0_body.gjh158 ++ PRE_first_tail_x15_r0_body.cl158).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1523.next) PRE_first_tail_x15_r0_body.s1525) = true
theorem bodyJs158 : JsHeapAbove PRE_first_tail_x15_r0_body.s1523.next PRE_first_tail_x15_r0_body.s1525 :=
  JsHeapAbove.glueSite bodyJs157 (Nat.le_of_ble_eq_true bodyJsLe158) PRE_first_tail_x15_r0_body.gjk158 PRE_first_tail_x15_r0_body.gjbd158 PRE_first_tail_x15_r0_body.cheap158 PRE_first_tail_x15_r0_body.zclbd158 bodyJsList158

end Host.Ts.Sim.Compose.VWFirst.VW15
