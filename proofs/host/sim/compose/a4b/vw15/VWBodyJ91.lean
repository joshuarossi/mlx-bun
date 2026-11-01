import host.sim.compose.a4b.vw15.VWBodyJ90
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl91 : Conv.NClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s887.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl91 (PRE_first_tail_x15_r0_body.cncl90 bodyNcl90)

theorem bodyClean91 : Conv.JClean (⟨19998, 17103, 2746383, 3971⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s887 :=
  PRE_first_tail_x15_r0_body.gjcl91 (PRE_first_tail_x15_r0_body.cjcl90 bodyClean90)

kernel_rfl bodyJsLe91 : Nat.ble PRE_first_tail_x15_r0_body.s879.next PRE_first_tail_x15_r0_body.s887.next = true
kernel_rfl bodyJsList91 : (PRE_first_tail_x15_r0_body.gjh91 ++ PRE_first_tail_x15_r0_body.cl91).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s887.next) PRE_first_tail_x15_r0_body.s889) = true
theorem bodyJs91 : JsHeapAbove PRE_first_tail_x15_r0_body.s887.next PRE_first_tail_x15_r0_body.s889 :=
  JsHeapAbove.glueSite bodyJs90 (Nat.le_of_ble_eq_true bodyJsLe91) PRE_first_tail_x15_r0_body.gjk91 PRE_first_tail_x15_r0_body.gjbd91 PRE_first_tail_x15_r0_body.cheap91 PRE_first_tail_x15_r0_body.zclbd91 bodyJsList91

end Host.Ts.Sim.Compose.VWFirst.VW15
