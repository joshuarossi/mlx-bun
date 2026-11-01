import host.sim.compose.a4b.vw15.VWBodyJ185
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl186 : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl186 (PRE_first_tail_x15_r0_body.cncl185 bodyNcl185)

theorem bodyClean186 : Conv.JClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1799 :=
  PRE_first_tail_x15_r0_body.gjcl186 (PRE_first_tail_x15_r0_body.cjcl185 bodyClean185)

kernel_rfl bodyJsLe186 : Nat.ble PRE_first_tail_x15_r0_body.s1782.next PRE_first_tail_x15_r0_body.s1799.next = true
kernel_rfl bodyJsList186 : (PRE_first_tail_x15_r0_body.gjh186 ++ PRE_first_tail_x15_r0_body.cl186).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1799.next) PRE_first_tail_x15_r0_body.s1801) = true
theorem bodyJs186 : JsHeapAbove PRE_first_tail_x15_r0_body.s1799.next PRE_first_tail_x15_r0_body.s1801 :=
  JsHeapAbove.glueSite bodyJs185 (Nat.le_of_ble_eq_true bodyJsLe186) PRE_first_tail_x15_r0_body.gjk186 PRE_first_tail_x15_r0_body.gjbd186 PRE_first_tail_x15_r0_body.cheap186 PRE_first_tail_x15_r0_body.zclbd186 bodyJsList186

end Host.Ts.Sim.Compose.VWFirst.VW15
