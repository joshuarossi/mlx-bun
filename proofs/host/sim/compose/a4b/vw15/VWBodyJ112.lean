import host.sim.compose.a4b.vw15.VWBodyJ111
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl112 : Conv.NClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1088.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl112 (PRE_first_tail_x15_r0_body.cncl111 bodyNcl111)

theorem bodyClean112 : Conv.JClean (⟨20413, 17514, 2762963, 4868⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1088 :=
  PRE_first_tail_x15_r0_body.gjcl112 (PRE_first_tail_x15_r0_body.cjcl111 bodyClean111)

kernel_rfl bodyJsLe112 : Nat.ble PRE_first_tail_x15_r0_body.s1080.next PRE_first_tail_x15_r0_body.s1088.next = true
kernel_rfl bodyJsList112 : (PRE_first_tail_x15_r0_body.gjh112 ++ PRE_first_tail_x15_r0_body.cl112).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1088.next) PRE_first_tail_x15_r0_body.s1090) = true
theorem bodyJs112 : JsHeapAbove PRE_first_tail_x15_r0_body.s1088.next PRE_first_tail_x15_r0_body.s1090 :=
  JsHeapAbove.glueSite bodyJs111 (Nat.le_of_ble_eq_true bodyJsLe112) PRE_first_tail_x15_r0_body.gjk112 PRE_first_tail_x15_r0_body.gjbd112 PRE_first_tail_x15_r0_body.cheap112 PRE_first_tail_x15_r0_body.zclbd112 bodyJsList112

end Host.Ts.Sim.Compose.VWFirst.VW15
