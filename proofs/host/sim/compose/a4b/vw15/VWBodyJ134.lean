import host.sim.compose.a4b.vw15.VWBodyJ133
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl134 : Conv.NClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl134 (PRE_first_tail_x15_r0_body.cncl133 bodyNcl133)

theorem bodyClean134 : Conv.JClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1293 :=
  PRE_first_tail_x15_r0_body.gjcl134 (PRE_first_tail_x15_r0_body.cjcl133 bodyClean133)

kernel_rfl bodyJsLe134 : Nat.ble PRE_first_tail_x15_r0_body.s1289.next PRE_first_tail_x15_r0_body.s1293.next = true
kernel_rfl bodyJsList134 : (PRE_first_tail_x15_r0_body.gjh134 ++ PRE_first_tail_x15_r0_body.cl134).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1293.next) PRE_first_tail_x15_r0_body.s1295) = true
theorem bodyJs134 : JsHeapAbove PRE_first_tail_x15_r0_body.s1293.next PRE_first_tail_x15_r0_body.s1295 :=
  JsHeapAbove.glueSite bodyJs133 (Nat.le_of_ble_eq_true bodyJsLe134) PRE_first_tail_x15_r0_body.gjk134 PRE_first_tail_x15_r0_body.gjbd134 PRE_first_tail_x15_r0_body.cheap134 PRE_first_tail_x15_r0_body.zclbd134 bodyJsList134

end Host.Ts.Sim.Compose.VWFirst.VW15
