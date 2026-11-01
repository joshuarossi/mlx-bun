import host.sim.compose.a4b.vw15.VWBodyJ164
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl165 : Conv.NClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1597.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl165 (PRE_first_tail_x15_r0_body.cncl164 bodyNcl164)

theorem bodyClean165 : Conv.JClean (⟨21461, 18557, 2804916, 7143⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1597 :=
  PRE_first_tail_x15_r0_body.gjcl165 (PRE_first_tail_x15_r0_body.cjcl164 bodyClean164)

kernel_rfl bodyJsLe165 : Nat.ble PRE_first_tail_x15_r0_body.s1581.next PRE_first_tail_x15_r0_body.s1597.next = true
kernel_rfl bodyJsList165 : (PRE_first_tail_x15_r0_body.gjh165 ++ PRE_first_tail_x15_r0_body.cl165).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1597.next) PRE_first_tail_x15_r0_body.s1599) = true
theorem bodyJs165 : JsHeapAbove PRE_first_tail_x15_r0_body.s1597.next PRE_first_tail_x15_r0_body.s1599 :=
  JsHeapAbove.glueSite bodyJs164 (Nat.le_of_ble_eq_true bodyJsLe165) PRE_first_tail_x15_r0_body.gjk165 PRE_first_tail_x15_r0_body.gjbd165 PRE_first_tail_x15_r0_body.cheap165 PRE_first_tail_x15_r0_body.zclbd165 bodyJsList165

end Host.Ts.Sim.Compose.VWFirst.VW15
