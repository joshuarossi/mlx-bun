import host.sim.compose.a4b.vw15.VWBodyJ106
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl107 : Conv.NClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl107 (PRE_first_tail_x15_r0_body.cncl106 bodyNcl106)

theorem bodyClean107 : Conv.JClean (⟨20305, 17392, 2758717, 4627⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1034 :=
  PRE_first_tail_x15_r0_body.gjcl107 (PRE_first_tail_x15_r0_body.cjcl106 bodyClean106)

kernel_rfl bodyJsLe107 : Nat.ble PRE_first_tail_x15_r0_body.s1030.next PRE_first_tail_x15_r0_body.s1034.next = true
kernel_rfl bodyJsList107 : (PRE_first_tail_x15_r0_body.gjh107 ++ PRE_first_tail_x15_r0_body.cl107).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1034.next) PRE_first_tail_x15_r0_body.s1036) = true
theorem bodyJs107 : JsHeapAbove PRE_first_tail_x15_r0_body.s1034.next PRE_first_tail_x15_r0_body.s1036 :=
  JsHeapAbove.glueSite bodyJs106 (Nat.le_of_ble_eq_true bodyJsLe107) PRE_first_tail_x15_r0_body.gjk107 PRE_first_tail_x15_r0_body.gjbd107 PRE_first_tail_x15_r0_body.cheap107 PRE_first_tail_x15_r0_body.zclbd107 bodyJsList107

end Host.Ts.Sim.Compose.VWFirst.VW15
