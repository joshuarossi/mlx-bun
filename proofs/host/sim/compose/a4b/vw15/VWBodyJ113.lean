import host.sim.compose.a4b.vw15.VWBodyJ112
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl113 : Conv.NClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1092.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl113 (PRE_first_tail_x15_r0_body.cncl112 bodyNcl112)

theorem bodyClean113 : Conv.JClean (⟨20420, 17518, 2763251, 4885⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1092 :=
  PRE_first_tail_x15_r0_body.gjcl113 (PRE_first_tail_x15_r0_body.cjcl112 bodyClean112)

kernel_rfl bodyJsLe113 : Nat.ble PRE_first_tail_x15_r0_body.s1088.next PRE_first_tail_x15_r0_body.s1092.next = true
kernel_rfl bodyJsList113 : (PRE_first_tail_x15_r0_body.gjh113 ++ PRE_first_tail_x15_r0_body.cl113).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1092.next) PRE_first_tail_x15_r0_body.s1094) = true
theorem bodyJs113 : JsHeapAbove PRE_first_tail_x15_r0_body.s1092.next PRE_first_tail_x15_r0_body.s1094 :=
  JsHeapAbove.glueSite bodyJs112 (Nat.le_of_ble_eq_true bodyJsLe113) PRE_first_tail_x15_r0_body.gjk113 PRE_first_tail_x15_r0_body.gjbd113 PRE_first_tail_x15_r0_body.cheap113 PRE_first_tail_x15_r0_body.zclbd113 bodyJsList113

end Host.Ts.Sim.Compose.VWFirst.VW15
