import host.sim.compose.a4b.vw15.VWBodyJ181
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl182 : Conv.NClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1753.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl182 (PRE_first_tail_x15_r0_body.cncl181 bodyNcl181)

theorem bodyClean182 : Conv.JClean (⟨21779, 18877, 2817511, 7834⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1753 :=
  PRE_first_tail_x15_r0_body.gjcl182 (PRE_first_tail_x15_r0_body.cjcl181 bodyClean181)

kernel_rfl bodyJsLe182 : Nat.ble PRE_first_tail_x15_r0_body.s1749.next PRE_first_tail_x15_r0_body.s1753.next = true
kernel_rfl bodyJsList182 : (PRE_first_tail_x15_r0_body.gjh182 ++ PRE_first_tail_x15_r0_body.cl182).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1753.next) PRE_first_tail_x15_r0_body.s1755) = true
theorem bodyJs182 : JsHeapAbove PRE_first_tail_x15_r0_body.s1753.next PRE_first_tail_x15_r0_body.s1755 :=
  JsHeapAbove.glueSite bodyJs181 (Nat.le_of_ble_eq_true bodyJsLe182) PRE_first_tail_x15_r0_body.gjk182 PRE_first_tail_x15_r0_body.gjbd182 PRE_first_tail_x15_r0_body.cheap182 PRE_first_tail_x15_r0_body.zclbd182 bodyJsList182

end Host.Ts.Sim.Compose.VWFirst.VW15
