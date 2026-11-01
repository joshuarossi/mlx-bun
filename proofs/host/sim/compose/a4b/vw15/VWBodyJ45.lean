import host.sim.compose.a4b.vw15.VWBodyJ44
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl45 : Conv.NClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s447.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl45 (PRE_first_tail_x15_r0_body.cncl44 bodyNcl44)

theorem bodyClean45 : Conv.JClean (⟨19101, 16187, 2710740, 2013⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s447 :=
  PRE_first_tail_x15_r0_body.gjcl45 (PRE_first_tail_x15_r0_body.cjcl44 bodyClean44)

kernel_rfl bodyJsLe45 : Nat.ble PRE_first_tail_x15_r0_body.s431.next PRE_first_tail_x15_r0_body.s447.next = true
kernel_rfl bodyJsList45 : (PRE_first_tail_x15_r0_body.gjh45 ++ PRE_first_tail_x15_r0_body.cl45).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s447.next) PRE_first_tail_x15_r0_body.s449) = true
theorem bodyJs45 : JsHeapAbove PRE_first_tail_x15_r0_body.s447.next PRE_first_tail_x15_r0_body.s449 :=
  JsHeapAbove.glueSite bodyJs44 (Nat.le_of_ble_eq_true bodyJsLe45) PRE_first_tail_x15_r0_body.gjk45 PRE_first_tail_x15_r0_body.gjbd45 PRE_first_tail_x15_r0_body.cheap45 PRE_first_tail_x15_r0_body.zclbd45 bodyJsList45

end Host.Ts.Sim.Compose.VWFirst.VW15
