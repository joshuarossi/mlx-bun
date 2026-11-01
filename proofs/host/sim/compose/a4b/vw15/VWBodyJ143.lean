import host.sim.compose.a4b.vw15.VWBodyJ142
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl143 : Conv.NClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl143 (PRE_first_tail_x15_r0_body.cncl142 bodyNcl142)

theorem bodyClean143 : Conv.JClean (⟨21013, 18103, 2786961, 6166⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1379 :=
  PRE_first_tail_x15_r0_body.gjcl143 (PRE_first_tail_x15_r0_body.cjcl142 bodyClean142)

kernel_rfl bodyJsLe143 : Nat.ble PRE_first_tail_x15_r0_body.s1375.next PRE_first_tail_x15_r0_body.s1379.next = true
kernel_rfl bodyJsList143 : (PRE_first_tail_x15_r0_body.gjh143 ++ PRE_first_tail_x15_r0_body.cl143).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1379.next) PRE_first_tail_x15_r0_body.s1381) = true
theorem bodyJs143 : JsHeapAbove PRE_first_tail_x15_r0_body.s1379.next PRE_first_tail_x15_r0_body.s1381 :=
  JsHeapAbove.glueSite bodyJs142 (Nat.le_of_ble_eq_true bodyJsLe143) PRE_first_tail_x15_r0_body.gjk143 PRE_first_tail_x15_r0_body.gjbd143 PRE_first_tail_x15_r0_body.cheap143 PRE_first_tail_x15_r0_body.zclbd143 bodyJsList143

end Host.Ts.Sim.Compose.VWFirst.VW15
